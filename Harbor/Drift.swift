import SwiftUI
import WidgetKit
import UserNotifications

#if DEBUG && targetEnvironment(simulator)
enum ScreenshotScreen: String, CaseIterable {
 case reel = "reel-the-fish"
 case catchResult = "catch-result"
 case trophies = "trophy-room"
 case lakes = "discover-the-lakes"
 case tackle = "your-tackle"

 static let current: ScreenshotScreen? = {
  let process = ProcessInfo.processInfo
  let arguments = process.arguments
  func value(after flag: String) -> String? {
   guard let index = arguments.firstIndex(of: flag), arguments.indices.contains(index + 1) else { return nil }
   return arguments[index + 1]
  }
  if arguments.contains("-ReviewScreen") {
   return value(after: "-ReviewScreen").flatMap(ScreenshotScreen.init(rawValue:))
  }
  guard arguments.contains("-AppStoreScreenshots") || process.environment["APPSTORE_SCREENSHOTS"] == "1",
        let rawIndex = value(after: "-AppStoreScreenshotScreen") ?? process.environment["APPSTORE_SCREENSHOT_SCREEN"],
        let index = Int(rawIndex), allCases.indices.contains(index) else { return nil }
  return allCases[index]
 }()

 var tab: Int {
  switch self {
  case .reel, .catchResult: return 0
  case .trophies: return 1
  case .tackle: return 2
  case .lakes: return 3
  }
 }

 func demoProgress() -> D44 {
  var demo = D44()
  let now = demo.checkpoint
  func land(_ species: String, kg: Double) {
   guard let fish = B85.fish.first(where: { $0.id == species }) else { return }
   B85.land(&demo, fish, kg, now)
  }

  switch self {
  case .reel:
   break
  case .catchResult:
   land("perch", kg: 0.86)
  case .trophies:
   land("perch", kg: 0.64)
   land("bluegill", kg: 0.42)
   land("bass", kg: 2.18)
   land("perch", kg: 0.86)
  case .lakes:
   demo.xp = 120
   demo.lake = 1
  case .tackle:
   demo.coins = 380
   _ = B85.buy(&demo, 0, 1)
   _ = B85.buy(&demo, 1, 1)
  }
  return demo
 }
}
#endif

@MainActor final class N83: ObservableObject {
 @Published var d:D44
 @Published var stage=0
 @Published var t=T19()
 @Published var hold=false
 @Published var result:R62?
 @Published var note=""
 @Published var idleCoins=0
 @Published var notification=""
 @Published var pending=false
 private var due=Date(); private var bite=Date(); private var pulse=Date.distantPast
 private var clock:Timer?
 init() {
 #if DEBUG && targetEnvironment(simulator)
 if let screen = ScreenshotScreen.current {
  d = screen.demoProgress()
  notification = "Not requested"
  switch screen {
  case .reel:
   t = T19(tension: 0.50, progress: 0.50)
   stage = 3
  case .catchResult:
   result = d.recent.first
   stage = 4
  default:
   break
  }
  // Leave the seeded fishing phase in place while the factory captures it.
  return
 }
 #endif
 d=B85.read()
 resume()
 clock=Timer.scheduledTimer(withTimeInterval:0.1,repeats:true){[weak self] _ in Task { @MainActor in self?.tick() }}
 }
 func save() {
 #if DEBUG && targetEnvironment(simulator)
 guard ScreenshotScreen.current == nil else { return }
 #endif
 B85.write(d); WidgetCenter.shared.reloadAllTimelines()
 }
 func resume() {
 #if DEBUG && targetEnvironment(simulator)
 guard ScreenshotScreen.current == nil else { return }
 #endif
 B85.rotate(&d,Date()); idleCoins += B85.idle(&d,Date()); if d.checkpoint>Date() {d.checkpoint=Date()};save();Task {await status()}
 }
 func rest() {
 #if DEBUG && targetEnvironment(simulator)
 guard ScreenshotScreen.current == nil else { return }
 #endif
 if stage==1 || stage==2 || stage==3 {stage=0;hold=false};save()
 }
 func cast() { guard stage==0 || stage==4 || stage==5 else{return}; result=nil; note="";stage=1; due=Date().addingTimeInterval(Double.random(in:3...6)) }
 func hook() {guard stage==2 else{return};t=T19();stage=3;ease()}
 func gentle() { pulse=Date().addingTimeInterval(0.9) }
 func ease() {hold=false;pulse=Date.distantPast}
 func tick() {
 switch stage {
 case 1: if Date()>=due {stage=2;bite=Date().addingTimeInterval(10); buzz()}
 case 2: if Date()>bite {stage=5;note="The fish swam away. Cast again."}
 case 3:
 let r=t.step(0.1,hold || Date()<pulse,d.rod,d.calm)
 if r == -1 {stage=5;hold=false;note="The line went loose or too tight. Try a gentler rhythm."}
 if r == 1 {
 let f=B85.pick(d,Date(),Double.random(in:0..<1)); let kg=Double.random(in:f.low...f.high)
 B85.land(&d,f,kg,Date());result=d.recent.first;stage=4;hold=false;buzz();save()
 }
 default:break
 }
 }
 func buzz() {if d.haptic {UIImpactFeedbackGenerator(style:.soft).impactOccurred()} }
 func buy(_ type:Int,_ level:Int) {if B85.buy(&d,type,level) {save();buzz()} }
 func choose(_ lake:Int) {guard d.xp>=B85.gates[lake],stage != 3 else{return};stage=0;d.lake=lake;save()}
 func status() async {let s=await UNUserNotificationCenter.current().notificationSettings(); notification=s.authorizationStatus == .denied ? "Disabled in system settings" : (s.authorizationStatus == .authorized ? "Allowed":"Not requested");if s.authorizationStatus == .denied && d.reminders {d.reminders=false;UNUserNotificationCenter.current().removeAllPendingNotificationRequests();save()}}
 func reminders(_ yes:Bool) async {
 #if DEBUG && targetEnvironment(simulator)
 guard ScreenshotScreen.current == nil else { return }
 #endif
 guard !pending else {return};pending=true;defer {pending=false}
 let c=UNUserNotificationCenter.current()
 if !yes {d.reminders=false;c.removeAllPendingNotificationRequests();save();return}
 do {
 let ok=try await c.requestAuthorization(options:[.alert,.sound]);d.reminders=ok
 if ok {
 c.removeAllPendingNotificationRequests()
 for h in [6,17] {var dc=DateComponents();dc.hour=h;let n=UNMutableNotificationContent();n.title=z("The lake is waking up");n.body=z("Your daily bite window is open. Take a quiet cast.");try await c.add(.init(identifier:"nacre.bite.\(h)",content:n,trigger:UNCalendarNotificationTrigger(dateMatching:dc,repeats:true)))}
 var dc=DateComponents();dc.day=1;dc.hour=10
 let n=UNMutableNotificationContent();n.title=z("A new season on the water");n.body=z("Fresh collection goals are ready. Earn keepsake badges at your own pace.")
 try await c.add(.init(identifier:"nacre.season",content:n,trigger:UNCalendarNotificationTrigger(dateMatching:dc,repeats:true)))
 }
 } catch {c.removeAllPendingNotificationRequests();d.reminders=false;notification="Could not schedule reminders. Try again.";save();return}
 save();await status()
 }
 func reset() {
 #if DEBUG && targetEnvironment(simulator)
 if ScreenshotScreen.current != nil {
  d = D44()
  stage = 0
  result = nil
  idleCoins = 0
  return
 }
 #endif
 UNUserNotificationCenter.current().removeAllPendingNotificationRequests();let u=UserDefaults(suiteName:r77) ?? .standard;u.removeObject(forKey:"nacre.state");u.removeObject(forKey:"nacre.backup");d=D44();stage=0;result=nil;idleCoins=0;save()
 }
}
@main struct A96:App {
 @StateObject private var v=N83()
 @Environment(\.scenePhase) var phase
 var body:some Scene {WindowGroup {K52().environmentObject(v).preferredColorScheme(.dark).onChange(of:phase){_,p in if p == .active {v.resume()} else {v.rest()} }}}
}
