"""Review native schema-2 evidence without driving input or changing game state.

Successful metadata checks never establish pause, focus, gameplay or pixel review.
Failed requests and captures completed before a failure remain visible.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import re
from pathlib import Path
from uuid import uuid4
from PIL import Image, ImageDraw

PROJECT = Path(__file__).resolve().parents[1]


def guarded(path, evidence):
    """Confine reading/writing to evidence children, refuse existing reparse paths."""
    path = Path(path).absolute()
    evidence = Path(evidence).absolute()
    if not path.is_relative_to(evidence) or path == evidence:
        raise ValueError('Evidence child required: ' + str(path))
    for item in (path, *path.parents):
        if item.is_symlink() or item.is_junction():
            raise ValueError('Reparse path refused: ' + str(item))
        if item == evidence:
            break
    if not path.resolve().is_relative_to(evidence.resolve()):
        raise ValueError('Evidence traversal refused')
    return path


def read(path):
    def unique(pairs):
        result = {}
        for key, value in pairs:
            if key in result:
                raise ValueError('Duplicate JSON key: ' + key)
            result[key] = value
        return result
    return json.loads(path.read_text(encoding='utf-8-sig'), object_pairs_hook=unique)


def collect(folders, evidence, pid=None, executable=None):
    folders = [guarded(folder, evidence) for folder in folders]
    if len(set(folders)) != len(folders):
        raise ValueError('Duplicate source folder')
    if (pid is None) != (executable is None) or (pid is not None and (len(folders) != 1 or type(pid) is not int or pid <= 0)):
        raise ValueError('Explicit positive PID and executable require one source folder')
    captures, requests, failures, identities = [], [], [], set()
    for folder in folders:
        launch = read(guarded(folder/'launch.json', evidence)) if (folder/'launch.json').exists() else None
        if launch is not None and not isinstance(launch, dict):
            raise ValueError('Invalid launch metadata: ' + str(folder))
        if launch is not None and pid is not None and (launch.get('pid') != pid or launch.get('exe') != executable):
            raise ValueError('Explicit identity contradicts launch metadata')
        expected_pid = pid if pid is not None else (launch or {}).get('pid')
        expected_exe = executable if executable is not None else (launch or {}).get('exe')
        if type(expected_pid) is not int or expected_pid <= 0 or not isinstance(expected_exe, str) or not expected_exe:
            raise ValueError('Launch identity or explicit --pid/--executable required: ' + str(folder))
        seen = set()
        for path in sorted(folder.glob('*.json')):
            guarded(path, evidence)
            try:
                row = read(path)
            except (ValueError, OSError) as error:
                failures.append({'path': str(path), 'error': str(error)})
                continue
            if not isinstance(row, dict) or ('target_pid' not in row and not re.fullmatch(r'[0-9a-f]{32}', path.stem)):
                continue  # Input command files, GUI saves and navigation observations.
            errors = []
            if type(row.get('schema_version')) is not int or row['schema_version'] != 2:
                errors.append('Native schema2 required')
            if type(row.get('target_pid')) is not int or row['target_pid'] != expected_pid or row.get('executable') != expected_exe:
                errors.append('Request/launch identity mismatch')
            if not re.fullmatch(r'[0-9a-f]{32}', path.stem) or row.get('id') != path.stem:
                errors.append('Request identity/filename mismatch')
            if path.stem in identities:
                errors.append('Request identity reused across source folders')
            identities.add(path.stem)
            if type(row.get('ok')) is not bool:
                errors.append('Boolean request outcome required')
            if row.get('cleanup_errors') != [] or row.get('unreleased_keys') != [] or row.get('mouse_unreleased') is not False:
                errors.append('Missing or failed input cleanup')
            if row.get('ok') is not True:
                errors.append('Failed request retained: ' + str(row.get('error')))
            elif row.get('error') is not None or row.get('failed_step') is not None:
                errors.append('Successful request has contradictory failure fields')
            steps = row.get('steps')
            if not isinstance(steps, list):
                errors.append('Missing step array')
                steps = []
            request = {'path': str(path), 'id': row.get('id'), 'pid': row.get('target_pid'),
                       'ok': row.get('ok'), 'failed_step': row.get('failed_step'), 'errors': errors}
            requests.append(request)
            for index, step in enumerate(steps):
                if not isinstance(step, dict) or type(step.get('index')) is not int or step['index'] != index or type(step.get('ok')) is not bool:
                    errors.append('Invalid step identity/outcome')
                    continue
                if step['ok'] is not True:
                    errors.append('Failed native step: ' + str(index))
                    continue
                command = step.get('step')
                if not isinstance(command, dict):
                    errors.append('Missing executed command')
                    continue
                if command.get('op') not in {'hold','wait','pointer','click','drag','capture','quit'}:
                    errors.append('Unknown native operation')
                    continue
                if command.get('op') != 'capture':
                    continue
                label = command.get('label')
                if not isinstance(label, str) or not re.fullmatch(r'[A-Za-z0-9_-]{1,64}', label):
                    errors.append('Unsafe capture label')
                    continue
                image_path = folder/(label+'.png')
                try:
                    guarded(image_path, evidence)
                    if image_path in seen:
                        raise ValueError('Capture claimed twice')
                    seen.add(image_path)
                    stamp = step.get('completed_utc')
                    moment = datetime.fromisoformat(stamp.replace('Z','+00:00'))
                    if moment.utcoffset() is None:
                        raise ValueError('Capture timestamp requires timezone')
                    with Image.open(image_path) as image:
                        image.load()
                        if image.format != 'PNG':
                            raise ValueError('PNG pixels required')
                        size = list(image.size)
                    captures.append({'path': str(image_path), 'label': label, 'pid': expected_pid,
                                     'request': str(path), 'request_ok': row.get('ok'), 'step': index,
                                     'completed_utc': stamp, 'order_utc': moment.astimezone(timezone.utc).isoformat(),
                                     'size': size, 'sha256': hashlib.sha256(image_path.read_bytes()).hexdigest()})
                except (ValueError, OSError, TypeError, AttributeError) as error:
                    errors.append('Capture ' + label + ': ' + str(error))
            failures.extend({'path': str(path), 'error': error} for error in errors)
        for path in folder.glob('*.png'):
            guarded(path, evidence)
            if path not in seen:
                failures.append({'path': str(path), 'error': 'Orphan PNG: no successful capture step'})
    if not requests:
        failures.append({'error': 'No native requests found'})
    captures.sort(key=lambda row: (row['order_utc'], row['request'], row['step']))
    return {'status': 'failed' if failures else 'passed', 'requests': requests, 'captures': captures,
            'failures': failures, 'visual_review': 'Required separately; no pause/focus/gameplay outcome inferred'}


def build(report, output, evidence, last=None):
    output = guarded(output, evidence)
    selected = report['captures'][-last:] if last else report['captures']
    output.mkdir(parents=True, exist_ok=False)
    sheets = []
    for offset in range(0, len(selected), 6):
        page = selected[offset:offset+6]
        sheet = Image.new('RGB', (960, 3*350), '#152022')
        draw = ImageDraw.Draw(sheet)
        for index, row in enumerate(page):
            x, y = (index % 2)*480, (index//2)*350
            with Image.open(row['path']) as image:
                thumb = image.convert('RGB'); thumb.thumbnail((474,316))
                sheet.paste(thumb, (x+3,y))
            caption = f"{offset+index+1}: {Path(row['path']).parent.name}/{row['label']}"
            draw.text((x+3,y+317), caption[:70], fill='white')
            draw.text((x+3,y+331), 'FAILED REQUEST' if not row['request_ok'] else row['completed_utc'], fill='#ffd280')
        path = output/f'sheet-{offset//6+1:02}.png'
        sheet.save(path); sheets.append(str(path))
    report = {**report, 'selected_count': len(selected), 'sheets': sheets}
    (output/'index.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run', nargs='+', required=True, type=Path, help='Native request/capture folders, no recursive scan')
    parser.add_argument('--pid', type=int, help='Explicit historical identity when launch.json absent; one folder only')
    parser.add_argument('--executable', help='Exact matching executable string recorded by native input')
    parser.add_argument('--last', type=int, help='Review only the latest N images; audit still checks every request/image')
    args = parser.parse_args()
    if args.last is not None and args.last <= 0:
        parser.error('--last must be positive')
    evidence = PROJECT/'docs/evidence'
    report = collect(args.run, evidence, args.pid, args.executable)
    output = evidence/'testing-tools'/('native-review-'+datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')+'-'+uuid4().hex[:8])
    report = build(report, output, evidence, args.last)
    print(json.dumps({'status': report['status'], 'requests': len(report['requests']),
                      'captures': len(report['captures']), 'selected': report['selected_count'],
                      'failures': len(report['failures']), 'index': str(output/'index.json'),
                      'sheets': report['sheets'], 'visual_review': report['visual_review']}))
    return int(bool(report['failures']))


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (ValueError, OSError) as error:
        print(json.dumps({'status':'failed','error':str(error)}))
        raise SystemExit(1)
