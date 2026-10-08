"""Read-only raw GLB audit; proves portability and baked endpoints before import.

Ordinary Python (no bpy). Optional --output writes a fresh evidence report.
"""
import argparse
import hashlib
import json
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def audit():
    path = ROOT / 'game/assets/models/npcs/npc-08.glb'
    blob = path.read_bytes()
    assert struct.unpack_from('<4sII',blob) == (b'glTF',2,len(blob))
    size, kind = struct.unpack_from('<I4s',blob,12)
    assert kind == b'JSON'
    document = json.loads(blob[20:20+size])
    start = 20+size
    length, kind = struct.unpack_from('<I4s',blob,start)
    assert kind == b'BIN\0'
    binary = blob[start+8:start+8+length]
    assert 'cameras' not in document
    assert not document.get('extensionsUsed')
    assert len(document['skins']) == 1 and len(document['skins'][0]['joints']) == 16
    assert len(document['materials']) == 1
    assert len(document['images']) == 1
    assert all('uri' not in item for item in document['buffers']+document['images'])
    image = document['images'][0]
    assert image['mimeType'] == 'image/png' and 'bufferView' in image

    def values(index):
        a = document['accessors'][index]
        assert a['componentType'] == 5126 and 'sparse' not in a
        count = {'SCALAR':1,'VEC3':3,'VEC4':4}[a['type']]
        view = document['bufferViews'][a['bufferView']]
        offset = view.get('byteOffset',0)+a.get('byteOffset',0)
        stride = view.get('byteStride',4*count)
        return [struct.unpack_from('<'+'f'*count,binary,offset+i*stride) for i in range(a['count'])]

    clips = {}
    for animation in document['animations']:
        name = animation['name']
        assert name in ('idle','walk') and name not in clips
        maximum_seam = 0
        end_time = 0
        for sampler in animation['samplers']:
            times, poses = values(sampler['input']), values(sampler['output'])
            assert times[0][0] == 0 and sampler['interpolation'] in ('LINEAR','STEP')
            if sampler['interpolation'] == 'STEP':
                assert all(p == poses[0] for p in poses), 'Only immutable channels may use STEP'
            assert all(times[i][0] < times[i+1][0] for i in range(len(times)-1))
            assert len(times) == len(poses) and all(all(abs(v) < 1e5 for v in pose) for pose in poses)
            seam = max(abs(a-b) for a,b in zip(poses[0],poses[-1]))
            maximum_seam = max(maximum_seam,seam)
            end_time = max(end_time,times[-1][0])
        assert abs(end_time-({'idle':4,'walk':.8}[name])) < 1e-6
        assert maximum_seam < 1e-5
        for channel in animation['channels']:
            assert channel['target']['path'] in ('translation','rotation','scale')
            node = document['nodes'][channel['target']['node']]
            if node['name'] == 'root':
                data = values(animation['samplers'][channel['sampler']]['output'])
                assert all(p == data[0] for p in data), 'Root motion must stay outside exported clip'
        clips[name] = {'seconds':end_time,'raw_endpoint_max_error':maximum_seam,'channels':len(animation['channels'])}
    assert set(clips) == {'idle','walk'}
    triangles = sum(document['accessors'][p['indices']]['count']//3 for mesh in document['meshes'] for p in mesh['primitives'])
    assert 4000 <= triangles <= 12000
    result = {'status':'PASS','glb_sha256':hashlib.sha256(blob).hexdigest(),'glb_bytes':len(blob),'triangles':triangles,'clips':clips,'embedded_png':True,'external_uris':0,
        'blend_sha256':hashlib.sha256((ROOT/'art/source/npc-08.blend').read_bytes()).hexdigest()}
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output',type=Path)
    args = parser.parse_args()
    result = audit()
    if args.output:
        assert not args.output.exists(), 'Evidence output already exists'
        args.output.parent.mkdir(parents=True,exist_ok=True)
        args.output.write_text(json.dumps(result,indent=2)+'\n')
    print('N014_RAW_GLB '+json.dumps(result))
