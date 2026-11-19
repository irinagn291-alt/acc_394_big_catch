#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
kind="${1:-phone}"
trap 'python3 QA/finalize.py "$kind" "$?"' EXIT
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcrun simctl boot "$GF_SIMULATOR_UDID" || true
xcrun simctl bootstatus "$GF_SIMULATOR_UDID" -b
set +e
xcodebuild -project Nacre.xcodeproj -scheme Nacre -configuration Estuary -destination "id=$GF_SIMULATOR_UDID" -parallel-testing-enabled NO -derivedDataPath Build/Preflight -resultBundlePath "QA/${kind}.xcresult" CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=- test-without-building > "QA/${kind}-tests.log" 2>&1
outcome=$?
set -e
xcrun simctl launch "$GF_SIMULATOR_UDID" org.siltreed.nacre201
xcrun simctl io "$GF_SIMULATOR_UDID" screenshot "QA/${kind}-final.png"
xcrun xcresulttool export attachments --path "QA/${kind}.xcresult" --output-path "QA/${kind}-captures"
group_path=$(xcrun simctl get_app_container "$GF_SIMULATOR_UDID" org.siltreed.nacre201 group.org.siltreed.bc201.nacre)
GF_NACRE_GROUP_PATH="$group_path" GF_NACRE_KIND="$kind" python3 - <<'PYDATA'
import os,plistlib,json
from pathlib import Path
p=Path(os.environ['GF_NACRE_GROUP_PATH'])/'Library/Preferences/group.org.siltreed.bc201.nacre.plist'
a=plistlib.loads(p.read_bytes());d=json.loads(a['nacre.state'])
report={'group':'group.org.siltreed.bc201.nacre','species':len(d['catches']),'coins':d['coins'],'xp':d['xp'],'reminders':d['reminders'],'result':'passed' if d['catches'] else 'failed'}
Path('QA/'+os.environ['GF_NACRE_KIND']+'-shared-state.json').write_text(json.dumps(report,indent=2))
assert d['catches'], 'The successful catch must exist in the widget group'
PYDATA
if [ "$kind" = phone ]; then
 for lang in de fr pt-BR; do
  xcrun simctl terminate "$GF_SIMULATOR_UDID" org.siltreed.nacre201 || true
  xcrun simctl launch "$GF_SIMULATOR_UDID" org.siltreed.nacre201 -AppleLanguages "($lang)" -AppleLocale "$lang"
  sleep 2
  xcrun simctl io "$GF_SIMULATOR_UDID" screenshot "QA/locale-${lang}.png"
 done
fi
exit "$outcome"
