from pathlib import Path
import zipfile,json,hashlib,uuid
r=Path(__file__).parent
include=['Harbor','Widgets','Checks','Nacre.xcodeproj','Store','Art','REPORT.md','assemble.py','package.py','QA/qa.sh','QA/run_pool.py','QA/audit.py','QA/audit.json','QA/core-rules.json','QA/finalize.py','QA/native-status.json','QA/STATUS.md','QA/archive-audit.json']
out=r/'Build/BigCatch-source.zip'
temp=out.with_name('.source-'+uuid.uuid4().hex+'.zip')
with zipfile.ZipFile(temp,'w',zipfile.ZIP_DEFLATED) as z:
 for item in include:
  p=r/item
  rows=[p] if p.is_file() else list(p.rglob('*'))
  for f in rows:
   if f.is_file() and 'xcuserdata' not in f.parts and f.name!='.DS_Store':z.write(f,'BigCatch/'+str(f.relative_to(r)))
temp.replace(out)
print(out.name,hashlib.sha256(out.read_bytes()).hexdigest())
