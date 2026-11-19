import WidgetKit
import SwiftUI
struct E35:TimelineEntry {var date:Date;var d:D44}
struct U48:TimelineProvider {
 func placeholder(in context:Context)->E35 {.init(date:Date(),d:D44())}
 func getSnapshot(in context:Context,completion:@escaping(E35)->Void){completion(.init(date:Date(),d:B85.read()))}
 func getTimeline(in context:Context,completion:@escaping(Timeline<E35>)->Void) {let d=B85.read();let a=(0..<25).map{E35(date:Date().addingTimeInterval(Double($0)*3600),d:d)};completion(Timeline(entries:a,policy:.atEnd))}
}
struct O41:View {
 var entry:E35
 var shape:WidgetFamily?=nil
 @Environment(\.widgetFamily) private var actual
 var family:WidgetFamily {shape ?? actual}
 var next:Int {B85.gates.firstIndex{$0>entry.d.xp} ?? 3}
 var body:some View {
 Group {
 switch family {
 case .accessoryInline:Label(B85.window(),systemImage:"fish.fill")
 case .accessoryCircular:VStack{Image(systemName:"fish.fill");Text("6–9").font(.caption2)}.accessibilityLabel(z("Daily bite window")+" "+B85.window())
 case .accessoryRectangular:VStack(alignment:.leading){Label(z("Daily bite window"),systemImage:"fish.fill").font(.headline);Text(B85.window()).font(.caption)}
 default:main
 }
 }.containerBackground(for:.widget){Color(red:0.024,green:0.184,blue:0.333)}.widgetURL(URL(string:family == .systemLarge ? "bigcatch://trophies":"bigcatch://lakes"))
 }
 var main:some View {
 VStack(alignment:.leading,spacing:family == .systemSmall ? 8:12){
 HStack{Image(systemName:"fish.fill").foregroundStyle(.orange);Text("Big Catch").font(.caption.weight(.bold));Spacer()}
 if family == .systemSmall {Text(z(B85.lively(entry.date) ? "Lively water":"Gentle water")).font(.title3.bold());Text(z("Daily bite window")).font(.caption);Text(B85.window()).font(.caption2).foregroundStyle(.white.opacity(0.7))}
 else {
 Text(z(entry.d.xp>=420 ? "All lakes discovered":"Your next lake")).font(.headline)
 HStack{Text(z(B85.lakes[next])).font(.title3.bold());Spacer();Text("\(min(entry.d.xp,B85.gates[next]))/\(B85.gates[next]) XP").font(.caption)}
 ProgressView(value:Double(min(entry.d.xp,B85.gates[next])),total:Double(B85.gates[next])).tint(.orange)
 if family == .systemLarge {Divider();Text(z("Trophy room")).font(.headline);HStack{Label("\(entry.d.catches.count)/12",systemImage:"fish.fill");Spacer();Label("\(B85.gates.filter{$0<=entry.d.xp}.count)/4",systemImage:"map.fill")}.font(.title2.bold());ForEach(Array(entry.d.catches.sorted{$0.best>$1.best}.prefix(3))){r in HStack{Text(z(B85.fish.first{$0.id==r.id}?.n ?? "Fish"));Spacer();Text(B85.kg(r.best,entry.d.metric))}.font(.caption)};if entry.d.catches.isEmpty {Text(z("Cast your first line to begin your collection.")).font(.caption).foregroundStyle(.white.opacity(0.7))};Spacer(minLength:0);Text(z("Season on the water")).font(.caption.bold());Text("\(entry.d.season == B85.month(entry.date) ? entry.d.seasonCount:0)/12 · "+z("Catch twelve fish")).font(.caption)}
 }
 }.foregroundStyle(.white)
 }
}
#if WIDGET_EXTENSION
@main struct W24:Widget {
 var body:some WidgetConfiguration {StaticConfiguration(kind:"org.siltreed.nacre.glance",provider:U48()){O41(entry:$0)}.configurationDisplayName("Big Catch").description(z("Bite hours, lake progress and your trophy room.")).supportedFamilies([.systemSmall,.systemMedium,.systemLarge,.accessoryInline,.accessoryCircular,.accessoryRectangular])}
}

#else
struct G53:View {
 #if DEBUG && targetEnvironment(simulator)
 @EnvironmentObject private var game: N83
 #endif

 private var progress: D44 {
  #if DEBUG && targetEnvironment(simulator)
  if ScreenshotScreen.current != nil { return game.d }
  #endif
  return B85.read()
 }

 var body:some View {ScrollView {VStack(spacing:20){ForEach([WidgetFamily.systemSmall,.systemMedium,.systemLarge,.accessoryRectangular],id:\.self){f in O41(entry:.init(date:Date(),d:progress),shape:f).padding(16).frame(width:f == .systemSmall ? 165:330,height:f == .systemLarge ? 350:f == .accessoryRectangular ? 90:165).background(Color(red:0.024,green:0.184,blue:0.333),in:RoundedRectangle(cornerRadius:22))}}.padding()}.navigationTitle(z("Widgets"))}
}
#endif
