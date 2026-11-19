import SwiftUI

let c61=Color(red:0.024,green:0.184,blue:0.333)
let c28=Color(red:0.976,green:0.451,blue:0.086)
let c90=Color(red:0.957,green:0.894,blue:0.757)
struct K52:View {
 @EnvironmentObject var v:N83
 @Environment(\.horizontalSizeClass) private var width
 @Environment(\.dynamicTypeSize) private var textSize
 #if DEBUG && targetEnvironment(simulator)
 @State private var tab = ScreenshotScreen.current?.tab ?? 0
 private enum ScreenshotScrollTarget: Hashable { case reelingControls }
 #else
 @State private var tab=0
 #endif
 @State private var settings=false
 var body:some View {
 ZStack {c61.ignoresSafeArea(); VStack(spacing:0) {
 HStack {VStack(alignment:.leading,spacing:2){Text("BIG CATCH").font(.system(size:12,weight:.heavy,design:.rounded)).tracking(3).foregroundStyle(c28);Text(z(["A quiet cast","Trophy room","Your tackle","Discover the lakes"][tab])).font(.system(.title2,design:.rounded,weight:.bold))};Spacer();Label(v.d.coins.formatted(),systemImage:"circle.inset.filled").font(.headline).foregroundStyle(c90).accessibilityLabel(z("Coins")+" \(v.d.coins)");Button {settings=true} label:{Image(systemName:"gearshape").font(.title3).frame(width:40,height:44)}.accessibilityLabel(z("Settings")).accessibilityIdentifier("settings")}.padding(.horizontal,22).padding(.vertical,12)
 initialTabScroll
 HStack(spacing:0){ForEach(0..<4){i in Button {tab=i} label:{VStack(spacing:5){Image(systemName:["water.waves","fish.fill","figure.fishing","map.fill"][i]).font(.system(size:20));Text(z(["Fish","Trophies","Tackle","Lakes"][i])).font(.caption.weight(.semibold))}.foregroundStyle(tab==i ? c28:c90.opacity(0.65)).frame(maxWidth:.infinity).frame(minHeight:58).contentShape(Rectangle())}.accessibilityIdentifier("tab\(i)").accessibilityAddTraits(tab==i ? .isSelected:[])} }.padding(.top,7).background(.black.opacity(0.18))
 }}.tint(c28).sheet(isPresented:$settings){settingsView}.onOpenURL {url in if url.host=="trophies" {tab=1} else if url.host=="lakes" {tab=3} else {tab=0} }
 }
 private var tabScroll: some View {
  ScrollView {Group {switch tab {case 1:trophies;case 2:tackle;case 3:lakes;default:water}}.frame(maxWidth:1100).frame(maxWidth:.infinity).padding(.bottom,24)}
 }
 @ViewBuilder private var initialTabScroll: some View {
  #if DEBUG && targetEnvironment(simulator)
  if ScreenshotScreen.current == .reel {
   ScrollViewReader { proxy in
    tabScroll.onAppear {
     // Defer until the reader can locate the controls in the scroll content.
     DispatchQueue.main.async {
      guard tab == 0, v.stage == 3 else { return }
      var transaction = Transaction(animation: nil)
      transaction.disablesAnimations = true
      withTransaction(transaction) {
       // With no anchor, SwiftUI scrolls only enough to reveal the row.
       proxy.scrollTo(ScreenshotScrollTarget.reelingControls)
      }
     }
    }
   }
  } else {
   tabScroll
  }
  #else
  tabScroll
  #endif
 }
 var water:some View {
 VStack(spacing:16) {
 Group {
 if width == .regular && !textSize.isAccessibilitySize {HStack(alignment:.top,spacing:18){scene.frame(height:540);actions.frame(width:320)}}
 else {VStack(spacing:14){scene.frame(height:350);actions}}
 }
 .padding(.horizontal,16)
 if v.idleCoins>0 {HStack(spacing:12){Image(systemName:"sun.horizon.fill").foregroundStyle(c28);VStack(alignment:.leading){Text(z("Your waterside supplies")).font(.headline);Text(z("Coins gathered while you were away")+": \(v.idleCoins)").font(.subheadline).foregroundStyle(c90)};Spacer();Button {v.idleCoins=0} label:{Image(systemName:"xmark.circle.fill")}.accessibilityLabel(z("Dismiss"))}.padding(16).background(.white.opacity(0.07),in:RoundedRectangle(cornerRadius:20)).padding(.horizontal,16)}
 HStack(alignment:.top,spacing:12){Image(systemName:"sun.max.fill").foregroundStyle(c28);VStack(alignment:.leading,spacing:5){Text(z("Daily bite window")).font(.headline);Text(B85.window()).font(.subheadline).foregroundStyle(c90);Text(z("Game conditions follow your device clock.")).font(.caption).foregroundStyle(.white.opacity(0.6))};Spacer()}.padding(18).background(.white.opacity(0.055),in:RoundedRectangle(cornerRadius:20)).padding(.horizontal,16)
 }
 }
 var scene:some View {
 ZStack(alignment:.topLeading){
 J31(lake:v.d.lake,active:v.stage==1 || v.stage==2,calm:v.d.calm)
 LinearGradient(colors:[.black.opacity(0.22),.clear,.black.opacity(0.4)],startPoint:.top,endPoint:.bottom)
 VStack(alignment:.leading,spacing:8){HStack {Label(z("OFFLINE LAKE"),systemImage:"leaf.fill").font(.system(size:10,weight:.bold)).tracking(1.8);Spacer();Text(z(B85.lively(Date()) ? "Lively water":"Gentle water")).font(.caption.weight(.semibold)).padding(.horizontal,10).padding(.vertical,6).background(.ultraThinMaterial,in:Capsule())};Text(z(B85.lakes[v.d.lake])).font(.system(.largeTitle,design:.serif,weight:.medium));Spacer();HStack{Image(systemName:"location.north.circle");Text(z("Find your rhythm. Let the water lead.")).font(.subheadline);Spacer()}.foregroundStyle(c90)}.padding(22)
 if v.stage==2 {Text(z("A bite!" )).font(.title2.bold()).padding(18).background(c28,in:Capsule()).frame(maxWidth:.infinity,maxHeight:.infinity).accessibilityHidden(true)}
 }.frame(minHeight:330,maxHeight:.infinity).clipShape(RoundedRectangle(cornerRadius:28)).accessibilityElement(children:.combine)
 }
 var actions:some View {
 VStack(alignment:.leading,spacing:14){
 HStack{Text(z(["Ready when you are","Waiting for a ripple","Time to set the hook","Keep a gentle rhythm","A moment to remember","Another quiet chance"][v.stage])).font(.system(.title3,design:.rounded,weight:.bold));Spacer();Image(systemName:["figure.fishing","water.waves","exclamationmark","waveform.path","fish.fill","wind"][v.stage]).foregroundStyle(c28)}
 switch v.stage {
 case 0:
 Text(z("Cast into the lake, then watch for a bite. Every fish returns to the water.")).font(.subheadline).foregroundStyle(c90)
 primary("Cast your line","cast",v.cast)
 case 1:
 Text(z("A little patience. The float will move when a fish is ready.")).font(.subheadline).foregroundStyle(c90)
 ProgressView().tint(c28).frame(maxWidth:.infinity,minHeight:45)
 Button(z("Bring the line in")){v.stage=0}.font(.subheadline)
 case 2:Text(z("Tap to hook the fish before it swims away.")).font(.subheadline).foregroundStyle(c90);primary("Set the hook","hook",v.hook)
 case 3:
 VStack(alignment:.leading,spacing:7){HStack{Text(z("Line tension"));Spacer();Text(Int(v.t.tension*100).formatted()+"%").monospacedDigit()}.font(.caption.weight(.semibold));GeometryReader{g in ZStack(alignment:.leading){Capsule().fill(.white.opacity(0.12));Rectangle().fill(.mint.opacity(0.35)).frame(width:g.size.width*0.6).offset(x:g.size.width*0.22);Capsule().fill(v.t.tension>0.82 ? .red:c28).frame(width:6).offset(x:max(0,min(g.size.width-6,g.size.width*v.t.tension)))}}.frame(height:12).clipShape(Capsule());ProgressView(value:min(v.t.progress,1)).tint(.mint);Text(z("Reel to raise tension. Ease to lower it. Keep tension between 22% and 82%.")).font(.caption).foregroundStyle(c90)}.accessibilityElement(children:.ignore).accessibilityLabel(z("Line tension")).accessibilityIdentifier("tension").accessibilityValue("\(Int(v.t.tension*100))% · \(Int(v.t.progress*100))%")
 reelingControls
 case 4:
 if let r=v.result,let f=B85.fish.first(where:{$0.id==r.fish}) {HStack{Image(systemName:"fish.fill").font(.system(size:40)).foregroundStyle(c28);VStack(alignment:.leading){Text(z(f.n)).font(.title3.bold());Text(B85.kg(r.kg,v.d.metric)).font(.headline).foregroundStyle(c90)}};Text(z("Recorded in your trophy room. Released with care.")).font(.caption).foregroundStyle(c90)}
 primary("Cast again","cast",v.cast)
 default:Text(z(v.note)).font(.subheadline).foregroundStyle(c90);primary("Cast again","cast",v.cast)
 }
 if v.stage != 3 {HStack{Image(systemName:"figure.fishing");Text(z(B85.rods[v.d.rod]));Text("·");Text(z(B85.lures[v.d.lure]))}.font(.caption).foregroundStyle(.white.opacity(0.5))}
 }.padding(20).frame(maxWidth:.infinity,alignment:.leading).background(.white.opacity(0.065),in:RoundedRectangle(cornerRadius:24))
 }
 @ViewBuilder private var reelingControls: some View {
  let buttons = HStack {
   Button { v.gentle() } label: {
    Label(z("Reel gently"), systemImage: "arrow.up")
     .frame(maxWidth: .infinity, minHeight: 44)
   }
   .buttonStyle(.borderedProminent)
   .tint(c28)
   .accessibilityIdentifier("reel")
   Button { v.ease() } label: {
    Label(z("Ease"), systemImage: "arrow.down")
     .frame(minHeight: 44)
   }
   .buttonStyle(.bordered)
   .accessibilityIdentifier("ease")
  }
  #if DEBUG && targetEnvironment(simulator)
  if ScreenshotScreen.current == .reel {
   buttons.id(ScreenshotScrollTarget.reelingControls)
  } else {
   buttons
  }
  #else
  buttons
  #endif
 }
 func primary(_ title:String,_ id:String,_ action:@escaping()->Void)->some View {Button(action:action){Text(z(title)).font(.headline).frame(maxWidth:.infinity,minHeight:48)}.buttonStyle(.borderedProminent).tint(c28).foregroundStyle(.white).accessibilityIdentifier(id)}
 var trophies:some View {
 VStack(alignment:.leading,spacing:22){
 HStack{stat("Species", "\(v.d.catches.count)/12","fish.fill");stat("Lakes", "\(B85.gates.filter{$0<=v.d.xp}.count)/4","map.fill");stat("Catches",v.d.catches.reduce(0){$0+$1.count}.formatted(),"water.waves")}
 Text(z("Your collection")).font(.title2.bold())
 Text(z("Every catch is recorded here. Explore new lakes to find all twelve species.")).font(.subheadline).foregroundStyle(c90)
 LazyVGrid(columns:[GridItem(.adaptive(minimum:155),spacing:12)],spacing:12){ForEach(B85.fish){f in let r=v.d.catches.first{$0.id==f.id};VStack(alignment:.leading,spacing:10){Image(systemName:r == nil ? "fish":"fish.fill").font(.system(size:36)).foregroundStyle(r == nil ? .white.opacity(0.2):c28).frame(maxWidth:.infinity).padding(.vertical,10);Text(z(f.n)).font(.headline);Text(z(B85.lakes[f.home])).font(.caption).foregroundStyle(c90);if let r {Text(z("Best")+" "+B85.kg(r.best,v.d.metric)).font(.subheadline);Text(z("Caught")+" \(r.count)").font(.caption).foregroundStyle(.white.opacity(0.55))} else {Text(z("Not discovered yet")).font(.caption).foregroundStyle(.white.opacity(0.55))}}.frame(maxWidth:.infinity,alignment:.leading).padding(16).background(.white.opacity(0.06),in:RoundedRectangle(cornerRadius:20))}}
 season
 if !v.d.recent.isEmpty {Text(z("Recent catches")).font(.title2.bold());ForEach(v.d.recent.prefix(10)){r in HStack{Image(systemName:"fish.fill").foregroundStyle(c28);VStack(alignment:.leading){Text(z(B85.fish.first{$0.id==r.fish}?.n ?? "Fish"));Text(r.date,style:.date).font(.caption).foregroundStyle(c90)};Spacer();Text(B85.kg(r.kg,v.d.metric))}.padding(12).background(.white.opacity(0.04),in:RoundedRectangle(cornerRadius:12))}}
 }.padding(20)
 }
 var season:some View {
 VStack(alignment:.leading,spacing:15){HStack{Image(systemName:"seal.fill").foregroundStyle(c28);Text(z("Season on the water")).font(.title3.bold());Spacer();Text(Date(),format:.dateTime.month(.wide)).font(.caption)};Text(z("Monthly goals award keepsake badges only. New goals begin each calendar month.")).font(.caption).foregroundStyle(c90)
 ForEach(0..<3){i in let values=[v.d.seasonCount,v.d.seasonKinds.count,Int(v.d.seasonKg)];let goals=[12,6,30];HStack{Image(systemName:values[i]>=goals[i] ? "checkmark.seal.fill":"seal").foregroundStyle(values[i]>=goals[i] ? c28:c90);VStack(alignment:.leading){Text(z(["Catch twelve fish","Discover six species","Record 30 kg this month"][i])).font(.subheadline);ProgressView(value:Double(min(values[i],goals[i])),total:Double(goals[i])).tint(c28)};Text("\(min(values[i],goals[i]))/\(goals[i])").font(.caption.monospacedDigit())}}
 Text(z("Collected badges")+": \(v.d.badges.count)").font(.caption).foregroundStyle(c90)
 }.padding(20).background(.white.opacity(0.07),in:RoundedRectangle(cornerRadius:22))
 }
 func stat(_ title:String,_ value:String,_ icon:String)->some View {VStack(spacing:8){Image(systemName:icon).foregroundStyle(c28);Text(value).font(.system(.title2,design:.rounded,weight:.bold));Text(z(title)).font(.caption).foregroundStyle(c90)}.frame(maxWidth:.infinity).padding(.vertical,18).background(.white.opacity(0.06),in:RoundedRectangle(cornerRadius:20))}
 var tackle:some View {
 VStack(alignment:.leading,spacing:20){Text(z("Good tools, quieter water.")).font(.system(.largeTitle,design:.serif));Text(z("Use coins earned by fishing and idle supplies. Everything here is earned through play.")).foregroundStyle(c90)
 ForEach(0..<2){kind in Text(z(kind==0 ? "Rods":"Lures")).font(.title2.bold());ForEach(0..<3){i in let owned=(kind==0 ? v.d.rods:v.d.lures).contains(i);let selected=(kind==0 ? v.d.rod:v.d.lure)==i;HStack(spacing:16){Image(systemName:kind==0 ? "figure.fishing":"fish.circle.fill").font(.system(size:30)).foregroundStyle(c28).frame(width:42);VStack(alignment:.leading,spacing:5){Text(z(kind==0 ? B85.rods[i]:B85.lures[i])).font(.headline);Text(z(kind==0 ? ["Balanced for a first cast","Smoother line tension","The most forgiving tension"][i]:["A simple lake companion","More uncommon species","The strongest rare-species attraction"][i])).font(.caption).foregroundStyle(c90)};Spacer();Button {v.buy(kind,i)} label:{Text(selected ? z("Equipped"):(owned ? z("Equip"):"\(B85.costs[i]) ◉")).font(.subheadline.bold()).frame(minWidth:64,minHeight:44)}.buttonStyle(.bordered).disabled(selected || (!owned && v.d.coins<B85.costs[i])).accessibilityIdentifier("gear\(kind)\(i)")}.padding(16).background(.white.opacity(0.06),in:RoundedRectangle(cornerRadius:20))}}
 }.padding(20)
 }
 var lakes:some View {
 VStack(alignment:.leading,spacing:18){Text(z("Four waters. Twelve discoveries.")).font(.system(.largeTitle,design:.serif));Text(z("Explore by catching fish and gathering idle experience. Lake access is permanent.")).font(.subheadline).foregroundStyle(c90)
 ForEach(0..<4){i in let open=v.d.xp>=B85.gates[i];VStack(alignment:.leading,spacing:12){ZStack(alignment:.bottomLeading){J31(lake:i,active:false,calm:true).frame(height:155);LinearGradient(colors:[.clear,.black.opacity(0.6)],startPoint:.top,endPoint:.bottom);HStack{Text(z(B85.lakes[i])).font(.title2.bold());Spacer();Image(systemName:open ? "water.waves":"lock.fill")}.padding(16)}.clipShape(RoundedRectangle(cornerRadius:18));HStack{Text(B85.fish.filter{$0.home==i}.map{z($0.n)}.joined(separator:" · ")).font(.caption).foregroundStyle(c90);Spacer()};if open {primary(v.d.lake==i ? "Fishing here":"Fish this lake","lake\(i)"){v.choose(i);tab=0}} else {ProgressView(value:Double(min(v.d.xp,B85.gates[i])),total:Double(B85.gates[i])).tint(c28);Text(z("Exploration")+": \(v.d.xp)/\(B85.gates[i]) XP").font(.caption).foregroundStyle(c90)}}.padding(14).background(.white.opacity(0.055),in:RoundedRectangle(cornerRadius:24))}
 }.padding(20)
 }
 @State private var clear=false
 var settingsView:some View {
 NavigationStack {Form {
 Section(z("Make yourself comfortable")){Toggle(z("Metric weights"),isOn:$v.d.metric).onChange(of:v.d.metric){v.save()};Toggle(z("Gentle haptics"),isOn:$v.d.haptic).onChange(of:v.d.haptic){v.save()};Toggle(z("Calm water"),isOn:$v.d.calm).onChange(of:v.d.calm){v.save()};Text(z("Calm water reduces motion and shortens reeling time.")).font(.caption)}
 Section(z("Local reminders")){Text(z("Choose daily bite-window reminders and a monthly season note. Notifications are optional and stay on this device.")).font(.subheadline);Toggle(z("Remind me"),isOn:Binding(get:{v.d.reminders},set:{b in Task {await v.reminders(b)}})).accessibilityIdentifier("reminders").disabled(v.pending);Text(z(v.notification)).font(.caption);if v.notification=="Disabled in system settings" {Button(z("Open system settings")){if let url=URL(string:UIApplication.openSettingsURLString){UIApplication.shared.open(url)}}}}
 Section(z("Widgets")){NavigationLink(z("Preview widgets")){G53()}.accessibilityIdentifier("preview");Text(z("Add Big Catch widgets from your Home Screen or Lock Screen. They show local bite hours, lake progress and your collection without a connection."))}
 Section(z("Your data")){Text(z("No accounts, analytics, tracking, purchases or advertising. Your collection stays on this device and its widget group. Deleting the app removes local progress; system backups follow your device settings."));Text(z("Idle supplies accrue every five minutes, up to eight hours away. Fish are only recorded after you reel them in."));Button(z("Erase local progress"),role:.destructive){clear=true}.accessibilityIdentifier("reset")}
 }.navigationTitle(z("Settings")).toolbar{ToolbarItem(placement:.confirmationAction){Button(z("Done")){settings=false}}}.confirmationDialog(z("Erase your collection, tackle and coins?"),isPresented:$clear,titleVisibility:.visible){Button(z("Erase local progress"),role:.destructive){v.reset()};Button(z("Cancel"),role:.cancel){}}message:{Text(z("This cannot be undone."))}}
 }
}
