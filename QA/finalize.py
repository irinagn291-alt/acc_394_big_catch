from pathlib import Path
import json,sys,subprocess
r=Path(__file__).resolve().parent.parent
kind=sys.argv[1];code=int(sys.argv[2])
p=r/'QA/native-status.json'
a=json.loads(p.read_text()) if p.exists() else {'phone':{'status':'queued'},'pad':{'status':'queued'}}
a[kind]={'status':'passed' if code==0 else 'failed','exit_code':code,'captures':len(list((r/('QA/'+kind+'-captures')).rglob('*.png')))}
result=r/('QA/'+kind+'.xcresult')
if result.exists():
 try:
  c=subprocess.run(['xcrun','xcresulttool','get','test-results','summary','--path',str(result)],capture_output=True,text=True,timeout=40)
  if c.returncode==0:
   summary=json.loads(c.stdout)
   (r/('QA/'+kind+'-summary.json')).write_text(json.dumps(summary,indent=2))
 except (OSError,ValueError,subprocess.TimeoutExpired):pass
p.write_text(json.dumps(a,indent=2))
lines=['# Native QA status','', 'Tests run through the factory simulator pool. Generated after each device script exits.','']
for name,data in a.items():lines.append(f'- {name}: {data["status"]}; exported screenshots: {data.get("captures",0)}.')
lines+=['','Screenshots are evidence of actual execution. A human visual review is still required if the chat ended while queued.','No App Store submission or physical-device provisioning has been performed.']
(r/'QA/STATUS.md').write_text('\n'.join(lines)+'\n')
subprocess.run([sys.executable,str(r/'package.py')],cwd=r,capture_output=True)
