from pathlib import Path
import os,sys,subprocess,json
root=Path(__file__).resolve().parents[5]
sys.path.insert(0,str(root))
import runpy
from types import SimpleNamespace
simulator_pool=SimpleNamespace(**runpy.run_path(str(root/"gf/genesis/simulator_pool.py")))
simulator_pool.configure_xcode()
rows=[d for a in simulator_pool.inventory()['devices'].values() for d in a if simulator_pool.PREFIX not in d['name']]
for kind,needle in [('phone','iPhone'),('pad','iPad')]:
 selected=next((d for d in rows if needle in d['name']),None)
 if not selected:raise SystemExit('Missing '+needle+' template')
 print('Using factory template',selected['name'],flush=True)
 subprocess.run([sys.executable,str(root/'gf/genesis/simulator_pool.py'),selected['udid'],'bash',str(Path(__file__).with_name('qa.sh')),kind],check=True)
