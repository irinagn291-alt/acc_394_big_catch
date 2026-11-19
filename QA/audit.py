from pathlib import Path
import json,re,plistlib,hashlib,os
r=Path(__file__).resolve().parent.parent
p=r/'Nacre.xcodeproj/project.pbxproj'
s=p.read_text();ids=set(re.findall(r'\b[A-F0-9]{24}\b',s))
root=r.parents[2]
collisions=[];compared=0
projects=[]
for directory,dirs,files in os.walk(root):
 dirs[:]=[d for d in dirs if not d.lower().startswith(('build','deriveddata')) and d not in {'.git','.artifacts','node_modules'}]
 if 'project.pbxproj' in files:projects.append(Path(directory)/'project.pbxproj')
for other in projects:
 if other==p or 'DerivedData' in str(other) or 'Build/' in str(other):continue
 compared+=1
 shared=ids & set(re.findall(r'\b[A-F0-9]{24}\b',other.read_text(errors='ignore')))
 if shared:collisions.append({'project':str(other.relative_to(root)),'count':len(shared)})
source=[*r.glob('Harbor/*.swift'),*r.glob('Widgets/*.swift'),*r.glob('Checks/*.swift')]
files=[p,*source,*r.glob('Harbor/*.plist'),*r.glob('Widgets/*.plist'),*r.glob('Harbor/*.xcstrings'),*r.glob('Harbor/*.entitlements'),*r.glob('Widgets/*.entitlements')]
leaks=[str(f.relative_to(r)) for f in files if re.search(r'/Users/|@gmail\.',f.read_text(errors='ignore'))]
cat=json.loads((r/'Harbor/Localizable.xcstrings').read_text())
missing=[k for k,v in cat['strings'].items() if set(v['localizations']) != {'en','de','fr','pt-BR'}]
ui='\n'.join(f.read_text() for f in source)
keys=set(re.findall(r'z\("([^"\\]+)"\)',ui));unlocalized=list(keys-set(cat['strings']))
terms=re.compile(r'\b(?:bet|casino|slot|jackpot|odds|cashout)\b',re.I)
store=json.loads((r/'Store/metadata.json').read_text())
for k,v in store.items():
 if isinstance(v,dict):assert len(v['subtitle'])<=30 and len(v['keywords'])<=100
report={'swift_files':len(source),'project_objects':len(ids),'other_projects_compared':compared,'uuid_collisions':collisions,'machine_traces_in_source':leaks,'localizations':['en','de','fr','pt-BR'],'catalog_keys':len(cat['strings']),'incomplete_translations':missing,'unlocalized_static_keys':unlocalized,'forbidden_ui_terms':terms.findall(json.dumps(cat)+json.dumps(store)),'spec_sha256':'15b53823d323c8d75276b2e7243ceabe6c1b6072f26729f35d70e01941d12fcc'}
assert not any([collisions,leaks,missing,unlocalized,report['forbidden_ui_terms']]) and len(source)==6
(r/'QA/audit.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))
