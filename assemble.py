from pathlib import Path
import uuid,json,plistlib,shutil,re
r=Path(__file__).parent
assets=r/'Harbor'/'Pebbles.xcassets'
(assets/'AppIcon.appiconset').mkdir(parents=True,exist_ok=True)
(assets/'Stillwater.imageset').mkdir(parents=True,exist_ok=True)
(assets/'Contents.json').write_text(json.dumps({'info':{'author':'xcode','version':1}}))
(assets/'AppIcon.appiconset'/'Contents.json').write_text(json.dumps({'images':[{'idiom':'universal','platform':'ios','size':'1024x1024','filename':'AppIcon.png'}],'info':{'author':'xcode','version':1}}))
(assets/'Stillwater.imageset'/'Contents.json').write_text(json.dumps({'images':[{'idiom':'universal','filename':'Water.png'}],'info':{'author':'xcode','version':1}}))
rows=[x.split('|') for x in (r/'Art/locale_rows.txt').read_text().splitlines() if x]
strings={row[0]:{'extractionState':'manual','localizations':{lang:{'stringUnit':{'state':'translated','value':value}} for lang,value in zip(['en','de','fr','pt-BR'],row)}} for row in rows}
(r/'Harbor/Localizable.xcstrings').write_text(json.dumps({'sourceLanguage':'en','strings':strings,'version':'1.0'},ensure_ascii=False,indent=2))
(r/'Harbor/InfoPlist.xcstrings').write_text(json.dumps({'sourceLanguage':'en','strings':{'CFBundleDisplayName':{'localizations':{lang:{'stringUnit':{'state':'translated','value':'Big Catch'}} for lang in ['en','de','fr','pt-BR']}}},'version':'1.0'},indent=2))
def plist(path,data):
 with (r/path).open('wb') as f:plistlib.dump(data,f,sort_keys=False)
base={'CFBundleDevelopmentRegion':'en','CFBundleExecutable':'$(EXECUTABLE_NAME)','CFBundleIdentifier':'$(PRODUCT_BUNDLE_IDENTIFIER)','CFBundleInfoDictionaryVersion':'6.0','CFBundleName':'$(PRODUCT_NAME)','CFBundleShortVersionString':'$(MARKETING_VERSION)','CFBundleVersion':'$(CURRENT_PROJECT_VERSION)'}
plist('Harbor/Info.plist',{**base,**{'NSCameraUsageDescription': 'Take a photo or video to attach to a website form.', 'NSMicrophoneUsageDescription': 'Record sound for a video you choose to attach.', 'NSPhotoLibraryUsageDescription': 'Choose a photo or video to attach to a website form.'},'CFBundleDisplayName':'Big Catch','CFBundlePackageType':'APPL','LSRequiresIPhoneOS':True,'UILaunchScreen':{'UIColorName':''},'UIApplicationSceneManifest':{'UIApplicationSupportsMultipleScenes':False},'UIBackgroundModes':['remote-notification'],'UISupportedInterfaceOrientations':['UIInterfaceOrientationPortrait','UIInterfaceOrientationLandscapeLeft','UIInterfaceOrientationLandscapeRight'],'UISupportedInterfaceOrientations~ipad':['UIInterfaceOrientationPortrait','UIInterfaceOrientationPortraitUpsideDown','UIInterfaceOrientationLandscapeLeft','UIInterfaceOrientationLandscapeRight'],'CFBundleURLTypes':[{'CFBundleURLSchemes':['bigcatch'],'CFBundleURLName':'org.siltreed.nacre201'}]})
plist('Widgets/Info.plist',{**base,'CFBundlePackageType':'XPC!','CFBundleDisplayName':'Big Catch','NSExtension':{'NSExtensionPointIdentifier':'com.apple.widgetkit-extension'}})
plist('Harbor/Nacre.entitlements',{'com.apple.security.application-groups':['group.org.siltreed.bc201.nacre'],'aps-environment':'development'})
plist('Widgets/Wave.entitlements',{'com.apple.security.application-groups':['group.org.siltreed.bc201.nacre']})
plist('Harbor/PrivacyInfo.xcprivacy',{'NSPrivacyTracking':False,'NSPrivacyCollectedDataTypes':[],'NSPrivacyAccessedAPITypes':[{'NSPrivacyAccessedAPIType':'NSPrivacyAccessedAPICategoryUserDefaults','NSPrivacyAccessedAPITypeReasons':['1C8F.1','CA92.1']}]})
objects={}
def obj(isa,**kw):
 k=uuid.uuid4().hex[:24].upper();objects[k]={'isa':isa,**kw};return k
refs={}
def ref(path,typ):
 k=obj('PBXFileReference',lastKnownFileType=typ,path=path,sourceTree='<group>');refs[path]=k;return k
paths=['Harbor/Shoal.swift','Harbor/Drift.swift','Harbor/Lagoon.swift','Harbor/Ripples.swift','Widgets/GlanceC72a5a.swift','Checks/Verify.swift']
web_sources = sorted(str(p.relative_to(r)) for p in (r/'Harbor/Website').glob('*.swift'))
for p in paths+web_sources:ref(p,'sourcecode.swift')
for p,t in [('Harbor/Pebbles.xcassets','folder.assetcatalog'),('Harbor/Localizable.xcstrings','text.json.xcstrings'),('Harbor/InfoPlist.xcstrings','text.json.xcstrings'),('Harbor/PrivacyInfo.xcprivacy','text.xml'),('Harbor/Info.plist','text.plist.xml'),('Widgets/Info.plist','text.plist.xml'),('Harbor/Nacre.entitlements','text.plist.entitlements'),('Widgets/Wave.entitlements','text.plist.entitlements')]:ref(p,t)
products={}
for n,t in [('Nacre','wrapper.application'),('Ripple','wrapper.app-extension'),('CurrentChecks','wrapper.cfbundle'),('ShoreWalk','wrapper.cfbundle')]:products[n]=obj('PBXFileReference',explicitFileType=t,path=n+('.app' if n=='Nacre' else '.appex' if n=='Ripple' else '.xctest'),sourceTree='BUILT_PRODUCTS_DIR')
pg=obj('PBXGroup',children=list(products.values()),name='Products',sourceTree='<group>')
group=obj('PBXGroup',children=list(refs.values())+[pg],sourceTree='<group>')
folders = {Path('.'): group}
def project_folder(directory):
    if directory not in folders:
        parent = project_folder(directory.parent)
        group = obj('PBXGroup', path=directory.name, sourceTree='<group>', children=[])
        objects[parent]['children'].append(group)
        folders[directory] = group
    return folders[directory]

for item in list(objects[group]['children']):
    entry = objects[item]
    if entry['isa'] == 'PBXFileReference':
        path = Path(entry['path'])
        entry['path'] = path.name
    else:
        continue
    if path.parent != Path('.'):
        objects[group]['children'].remove(item)
        objects[project_folder(path.parent)]['children'].append(item)

def config(settings):
 arr=[]
 for name in ['Estuary','Tidal']:arr.append(obj('XCBuildConfiguration',name=name,buildSettings=settings(name)))
 return obj('XCConfigurationList',buildConfigurations=arr,defaultConfigurationIsVisible=0,defaultConfigurationName='Estuary')
common=config(lambda n:{'IPHONEOS_DEPLOYMENT_TARGET':'17.6','SDKROOT':'iphoneos','SWIFT_VERSION':'5.0','CLANG_ENABLE_MODULES':'YES','SWIFT_OPTIMIZATION_LEVEL':'-Onone' if n=='Estuary' else '-O','DEBUG_INFORMATION_FORMAT':'dwarf' if n=='Estuary' else 'dwarf-with-dsym','ENABLE_TESTABILITY':'YES' if n=='Estuary' else 'NO','GCC_PREPROCESSOR_DEFINITIONS':['$(inherited)','DEBUG=1'] if n=='Estuary' else ['$(inherited)']})
def phase(isa,paths,**kw):return obj(isa,buildActionMask=2147483647,files=[obj('PBXBuildFile',fileRef=refs[p]) for p in paths],runOnlyForDeploymentPostprocessing=0,**kw)
project_id=uuid.uuid4().hex[:24].upper()
targets={}
for name,src,resource,kind,bundle in [
 ('Nacre',paths[:4]+[paths[4]]+web_sources,['Harbor/Pebbles.xcassets','Harbor/Localizable.xcstrings','Harbor/InfoPlist.xcstrings','Harbor/PrivacyInfo.xcprivacy'],'application','org.siltreed.nacre201'),
 ('Ripple',[paths[0],paths[4]],['Harbor/Localizable.xcstrings','Harbor/PrivacyInfo.xcprivacy'],'app-extension','org.siltreed.nacre201.ripple'),
 ('CurrentChecks',[paths[0],paths[5]],[],'bundle.unit-test','org.siltreed.nacre201.rules'),
 ('ShoreWalk',[paths[5]],[],'bundle.ui-testing','org.siltreed.nacre201.walk')]:
 def settings(n,name=name,bundle=bundle):
  a={'PRODUCT_NAME':name,'PRODUCT_BUNDLE_IDENTIFIER':bundle,'CURRENT_PROJECT_VERSION':'20111','MARKETING_VERSION':'1.2.1','TARGETED_DEVICE_FAMILY':'1,2','CODE_SIGN_STYLE':'Automatic','SWIFT_EMIT_LOC_STRINGS':'NO','SUPPORTED_PLATFORMS':'iphoneos iphonesimulator','SUPPORTS_MACCATALYST':'NO'}
  if name=='Nacre':a.update({'INFOPLIST_FILE':'Harbor/Info.plist','CODE_SIGN_ENTITLEMENTS':'Harbor/Nacre.entitlements','ASSETCATALOG_COMPILER_APPICON_NAME':'AppIcon','LD_RUNPATH_SEARCH_PATHS':['$(inherited)','@executable_path/Frameworks']})
  elif name=='Ripple':a.update({'INFOPLIST_FILE':'Widgets/Info.plist','CODE_SIGN_ENTITLEMENTS':'Widgets/Wave.entitlements','SWIFT_ACTIVE_COMPILATION_CONDITIONS':'WIDGET_EXTENSION','APPLICATION_EXTENSION_API_ONLY':'YES','SKIP_INSTALL':'YES','LD_RUNPATH_SEARCH_PATHS':['$(inherited)','@executable_path/../../Frameworks']})
  else:a.update({'GENERATE_INFOPLIST_FILE':'YES','SWIFT_ACTIVE_COMPILATION_CONDITIONS':'RULE_CHECKS' if name=='CurrentChecks' else 'SHORE_WALK','TEST_TARGET_NAME':'Nacre' if name=='ShoreWalk' else ''})
  return a
 targets[name]=obj('PBXNativeTarget',name=name,productName=name,productReference=products[name],productType='com.apple.product-type.'+kind,buildConfigurationList=config(settings),buildPhases=[phase('PBXSourcesBuildPhase',src),phase('PBXFrameworksBuildPhase',[]),phase('PBXResourcesBuildPhase',resource)],buildRules=[],dependencies=[])
def dep(a,b):
 proxy=obj('PBXContainerItemProxy',containerPortal=project_id,proxyType=1,remoteGlobalIDString=targets[b],remoteInfo=b)
 objects[targets[a]]['dependencies'].append(obj('PBXTargetDependency',target=targets[b],targetProxy=proxy))
dep('Nacre','Ripple');dep('ShoreWalk','Nacre')
embed=obj('PBXBuildFile',fileRef=products['Ripple'],settings={'ATTRIBUTES':['RemoveHeadersOnCopy']})
objects[targets['Nacre']]['buildPhases'].append(obj('PBXCopyFilesBuildPhase',buildActionMask=2147483647,files=[embed],dstPath='',dstSubfolderSpec=13,name='Embed Water Glance',runOnlyForDeploymentPostprocessing=0))
objects[project_id]={'isa':'PBXProject','attributes':{'BuildIndependentTargetsInParallel':'YES','LastUpgradeCheck':'2720','ORGANIZATIONNAME':'Silt Reed Studio 201','TargetAttributes':{targets['Nacre']:{'SystemCapabilities':{'com.apple.ApplicationGroups.iOS':{'enabled':1},'com.apple.Push':{'enabled':1}}},targets['Ripple']:{'SystemCapabilities':{'com.apple.ApplicationGroups.iOS':{'enabled':1}}},targets['ShoreWalk']:{'TestTargetID':targets['Nacre']}}},'buildConfigurationList':common,'compatibilityVersion':'Xcode 14.0','developmentRegion':'en','knownRegions':['en','de','fr','pt-BR','Base'],'mainGroup':group,'productRefGroup':pg,'projectDirPath':'','projectRoot':'','targets':list(targets.values())}
def val(v):
 if isinstance(v,dict):return '{ '+ ' '.join(json.dumps(str(k))+ ' = '+val(x)+';' for k,x in v.items())+' }'
 if isinstance(v,list):return '( '+', '.join(val(x) for x in v)+' )'
 return str(v) if isinstance(v,int) else json.dumps(v)
pj=r/'Nacre.xcodeproj';pj.mkdir(exist_ok=True)
(pj/'project.pbxproj').write_text('// !$*UTF8*$!\n'+val({'archiveVersion':1,'classes':{},'objectVersion':56,'objects':objects,'rootObject':project_id}))
scheme=pj/'xcshareddata/xcschemes';scheme.mkdir(parents=True,exist_ok=True)
def br(n):return f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{targets[n]}" BuildableName="{n}{".app" if n=="Nacre" else ".xctest"}" BlueprintName="{n}" ReferencedContainer="container:Nacre.xcodeproj"/>'
(scheme/'Nacre.xcscheme').write_text(f'''<?xml version="1.0" encoding="UTF-8"?><Scheme LastUpgradeVersion="2720" version="1.7"><BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{br('Nacre')}</BuildActionEntry></BuildActionEntries></BuildAction><TestAction buildConfiguration="Estuary" shouldUseLaunchSchemeArgsEnv="YES"><Testables><TestableReference skipped="NO">{br('CurrentChecks')}</TestableReference><TestableReference skipped="NO">{br('ShoreWalk')}</TestableReference></Testables></TestAction><LaunchAction buildConfiguration="Estuary" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES"><BuildableProductRunnable runnableDebuggingMode="0">{br('Nacre')}</BuildableProductRunnable></LaunchAction><ProfileAction buildConfiguration="Tidal" shouldUseLaunchSchemeArgsEnv="YES" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES"><BuildableProductRunnable runnableDebuggingMode="0">{br('Nacre')}</BuildableProductRunnable></ProfileAction><AnalyzeAction buildConfiguration="Estuary"/><ArchiveAction buildConfiguration="Tidal" revealArchiveInOrganizer="YES"/></Scheme>''')
print('Created project with',len(objects),'fresh objects and',len(strings),'localized strings')
