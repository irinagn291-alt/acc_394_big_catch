import Foundation

let r77 = "group.org.siltreed.bc201.nacre"
func z(_ k:String) -> String { NSLocalizedString(k, comment: "") }
struct F29: Codable, Equatable, Identifiable {
 var id:String; var n:String; var low:Double; var high:Double; var home:Int; var dawn:Bool; var rare:Bool
}
struct P63: Codable, Equatable, Identifiable { var id:String; var count:Int; var best:Double; var first:Date }
struct R62: Codable, Identifiable { var id=UUID().uuidString; var fish:String; var kg:Double; var lake:Int; var date:Date }
struct D44: Codable {
 var revision=1; var coins=80; var xp=0; var lake=0; var rod=0; var lure=0
 var rods=[0]; var lures=[0]; var catches:[P63]=[]; var recent:[R62]=[]
 var checkpoint=Date(); var season=""; var seasonCount=0; var seasonKinds:[String]=[]; var seasonKg=0.0
 var badges:[String]=[]; var metric=true; var haptic=true; var calm=false; var reminders=false
}
enum B85 {
 static let lakes=["Willow Lake","Bluewater Reach","Copper Cove","Moonpine Lake"]
 static let gates=[0,80,200,420]
 static let rods=["Willow rod","River rod","Summit rod"]
 static let lures=["Copper spoon","Reed lure","Moon lure"]
 static let costs=[0,120,280]
 static let fish:[F29]=[
 .init(id:"perch",n:"Perch",low:0.2,high:1.4,home:0,dawn:true,rare:false),
 .init(id:"bluegill",n:"Bluegill",low:0.15,high:0.7,home:0,dawn:false,rare:false),
 .init(id:"bass",n:"Largemouth bass",low:0.8,high:4.8,home:0,dawn:true,rare:true),
 .init(id:"trout",n:"Rainbow trout",low:0.5,high:3.5,home:1,dawn:true,rare:false),
 .init(id:"pike",n:"Northern pike",low:1.0,high:7.5,home:1,dawn:false,rare:true),
 .init(id:"carp",n:"Common carp",low:0.8,high:6.2,home:1,dawn:false,rare:false),
 .init(id:"walleye",n:"Walleye",low:0.6,high:4.5,home:2,dawn:false,rare:false),
 .init(id:"catfish",n:"Channel catfish",low:1.0,high:8.0,home:2,dawn:false,rare:true),
 .init(id:"sunfish",n:"Sunfish",low:0.2,high:0.9,home:2,dawn:true,rare:false),
 .init(id:"salmon",n:"Lake salmon",low:1.2,high:9.5,home:3,dawn:true,rare:true),
 .init(id:"char",n:"Arctic char",low:0.7,high:5.0,home:3,dawn:true,rare:false),
 .init(id:"muskie",n:"Muskellunge",low:2.0,high:12.0,home:3,dawn:false,rare:true)]
 static func month(_ d:Date)->String { let c=Calendar.current.dateComponents([.year,.month], from:d); return "\(c.year ?? 0)-\(c.month ?? 0)" }
 static func lively(_ d:Date)->Bool { let h=Calendar.current.component(.hour,from:d); return (6..<9).contains(h) || (17..<20).contains(h) }
 static func window()->String { let f=DateFormatter(); f.dateFormat=DateFormatter.dateFormat(fromTemplate:"jmm",options:0,locale:.current); let c=Calendar.current; func h(_ n:Int)->String { f.string(from:c.date(bySettingHour:n,minute:0,second:0,of:Date())!) }; return "\(h(6))–\(h(9)) · \(h(17))–\(h(20))" }
 static func weights(_ d:D44,_ time:Date)->[(F29,Double)] {
 let h=Calendar.current.component(.hour,from:time)
 return fish.filter{$0.home == d.lake}.map { f in
 var w=f.rare ? 1.0:4.0
 if f.dawn && (6..<10).contains(h) {w *= 1.8}
 if !f.dawn && (17..<24).contains(h) {w *= 1.8}
 if f.rare {w += Double(d.lure)*1.4}; return (f,w)
 }
 }
 static func pick(_ d:D44,_ time:Date,_ roll:Double)->F29 {
 let a=weights(d,time); var v=min(0.999999,max(0,roll))*a.reduce(0){$0+$1.1}
 for (f,w) in a { v -= w; if v < 0 {return f} }; return a.last!.0
 }
 static func idle(_ d:inout D44,_ now:Date)->Int {
 let elapsed=max(0,min(28800,now.timeIntervalSince(d.checkpoint)))
 let ticks=Int(elapsed/300); guard ticks>0 else {return 0}
 let n=ticks*2; d.coins += n; d.xp += ticks
 d.checkpoint=now; return n
 }
 static func rotate(_ d:inout D44,_ date:Date) {
 let m=month(date); if d.season != m {d.season=m; d.seasonCount=0; d.seasonKinds=[]; d.seasonKg=0}
 }
 static func land(_ d:inout D44,_ f:F29,_ kg:Double,_ now:Date) {
 rotate(&d,now)
 if let i=d.catches.firstIndex(where:{$0.id==f.id}) { d.catches[i].count += 1; d.catches[i].best=max(d.catches[i].best,kg) }
 else {d.catches.append(.init(id:f.id,count:1,best:kg,first:now))}
 d.recent.insert(.init(fish:f.id,kg:kg,lake:d.lake,date:now),at:0); d.recent=Array(d.recent.prefix(100))
 d.coins += 15+Int(kg*3); d.xp += 12; d.seasonCount += 1; d.seasonKg += kg
 if !d.seasonKinds.contains(f.id) {d.seasonKinds.append(f.id)}
 let done=[d.seasonCount>=12,d.seasonKinds.count>=6,d.seasonKg>=30]
 for i in 0..<3 where done[i] {let k="\(d.season):\(i)"; if !d.badges.contains(k) {d.badges.append(k)}}
 }
 static func buy(_ d:inout D44,_ type:Int,_ level:Int)->Bool {
 guard (0...2).contains(level) else {return false}; let owned=type==0 ? d.rods:d.lures
 if owned.contains(level) { if type==0 {d.rod=level} else {d.lure=level}; return true }
 guard d.coins>=costs[level] else {return false}; d.coins -= costs[level]
 if type==0 {d.rods.append(level); d.rod=level} else {d.lures.append(level); d.lure=level}; return true
 }
 static func kg(_ v:Double,_ metric:Bool)->String {
 let f=NumberFormatter(); f.maximumFractionDigits=2; f.minimumFractionDigits=1
 return (f.string(from:NSNumber(value:metric ? v:v*2.20462262)) ?? "0") + (metric ? " kg":" lb")
 }
 static func read()->D44 {
 let u=UserDefaults(suiteName:r77) ?? .standard
 for k in ["nacre.state","nacre.backup"] { if let d=u.data(forKey:k),let p=try? JSONDecoder().decode(D44.self,from:d) {return p} }; return D44()
 }
 static func write(_ d:D44) { let u=UserDefaults(suiteName:r77) ?? .standard; if let b=try? JSONEncoder().encode(d) {if let old=u.data(forKey:"nacre.state") {u.set(old,forKey:"nacre.backup")};u.set(b,forKey:"nacre.state")} }
}
struct T19 {
 var tension=0.42; var progress=0.0; var slack=0.0; var age=0.0
 mutating func step(_ dt:Double,_ reel:Bool,_ rod:Int,_ calm:Bool)->Int {
 age += dt
 let pull=0.12+sin(age*2.2)*0.08
 tension += (reel ? 0.35-Double(rod)*0.025 : -0.26)*dt + pull*dt
 tension=max(0,tension)
 if tension>0.22 && tension<0.82 {progress += dt*(calm ? 0.14:0.105)}
 if tension<=0.08 {slack += dt} else {slack=0}
 if tension>=1 || slack>2.6 || age>50 {return -1}
 return progress>=1 ? 1:0
 }
}
