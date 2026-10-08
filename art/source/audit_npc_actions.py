"""Portable raw GLB checks; no Blender/source checkout needed at runtime."""
import json,struct,hashlib,math,argparse
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]

def read(path):
    blob=path.read_bytes(); assert struct.unpack_from('<4sII',blob)==(b'glTF',2,len(blob))
    size,kind=struct.unpack_from('<I4s',blob,12); assert kind==b'JSON'
    doc=json.loads(blob[20:20+size]); offset=20+size
    length,kind=struct.unpack_from('<I4s',blob,offset); assert kind==b'BIN\0'
    binary=blob[offset+8:offset+8+length]
    def values(index):
        a=doc['accessors'][index]; assert 'sparse' not in a
        components={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4,'MAT4':16}[a['type']]
        code,size={5126:('f',4),5125:('I',4),5123:('H',2),5121:('B',1)}[a['componentType']]
        view=doc['bufferViews'][a['bufferView']]; start=view.get('byteOffset',0)+a.get('byteOffset',0)
        stride=view.get('byteStride',size*components)
        return [struct.unpack_from('<'+code*components,binary,start+i*stride) for i in range(a['count'])]
    return blob,doc,values

def audit():
    reports=[]
    for who,clip in [('01','action_river_fishing'),('02','action_archive_work')]:
        path=ROOT/f'game/assets/models/npcs/npc-{who}-actions.glb'
        blob,doc,values=read(path)
        assert not doc.get('extensionsUsed') and not doc.get('cameras')
        assert len(doc['skins'])==1 and len(doc['skins'][0]['joints'])==16
        assert len(doc['meshes'])==2 and len(doc['materials'])==1 and len(doc['images'])==1
        assert all('uri' not in b for b in doc['buffers']+doc['images'])
        assert doc['images'][0]['mimeType']=='image/png'
        _,old,oldvalues=read(ROOT/f'game/assets/models/npcs/npc-{who}.glb')
        body=doc['meshes'][0]['primitives'][0]; original=old['meshes'][0]['primitives'][0]
        for key in original['attributes']:
            assert values(body['attributes'][key])==oldvalues(original['attributes'][key]),'Original body changed: '+key
        assert values(body['indices'])==oldvalues(original['indices'])
        clips={}
        for anim in doc['animations']:
            name=anim['name']; assert name in ['idle','walk',clip] and name not in clips
            seam=0; duration=0
            for sampler in anim['samplers']:
                times,poses=values(sampler['input']),values(sampler['output'])
                assert times[0][0]==0 and len(times)==len(poses)
                assert sampler['interpolation'] in ['LINEAR','STEP']
                if sampler['interpolation']=='STEP': assert all(v==poses[0] for v in poses)
                assert all(times[i][0]<times[i+1][0] for i in range(len(times)-1))
                assert all(math.isfinite(x) for p in poses for x in p)
                seam=max(seam,max(abs(x-y) for x,y in zip(poses[0],poses[-1])))
                duration=max(duration,times[-1][0])
            assert seam<1e-5 and abs(duration-(.8 if name=='walk' else 4))<1e-6
            for channel in anim['channels']:
                assert channel['target']['path'] in ['translation','rotation','scale']
                if doc['nodes'][channel['target']['node']]['name']=='root':
                    poses=values(anim['samplers'][channel['sampler']]['output'])
                    assert all(p==poses[0] for p in poses),'Root motion'
            clips[name]={'seconds':duration,'endpoint_error':seam,'channels':len(anim['channels'])}
        assert set(clips)=={'idle','walk',clip}
        triangles=sum(doc['accessors'][p['indices']]['count']//3 for m in doc['meshes'] for p in m['primitives'])
        assert triangles<=12000
        report={'npc_id':'npc-'+who,'status':'PASS','triangles':triangles,'body_byte_values_unchanged':True,
            'bones':16,'material_surfaces':2,'embedded_png':True,'external_uris':0,'clips':clips,
            'glb_sha256':hashlib.sha256(blob).hexdigest(),
            'blend_sha256':hashlib.sha256((ROOT/f'art/source/npc-{who}-actions.blend').read_bytes()).hexdigest(),
            'reference_sha256':hashlib.sha256((ROOT/('tools/npc_migration/reference/assets/images/actors/npcs/npc_'+who+'_'+('river_fishing' if who=='01' else 'archive_work')+'_sheet.png')).read_bytes()).hexdigest()}
        reports.append(report)
    return reports
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--output',type=Path);args=p.parse_args()
    reports=audit()
    if args.output:
        assert not args.output.exists(); args.output.write_text(json.dumps(reports,indent=2)+'\n')
    print(json.dumps(reports,indent=2))
