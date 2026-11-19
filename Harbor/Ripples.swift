import SwiftUI
struct J31:View {
 var lake:Int;var active:Bool;var calm:Bool
 @Environment(\.accessibilityReduceMotion) private var reduce
 private var still: Bool {
  #if DEBUG && targetEnvironment(simulator)
  if ScreenshotScreen.current != nil { return true }
  #endif
  return calm || reduce
 }
 var body:some View {
 GeometryReader {g in
 ZStack {
 if UIImage(named:"Stillwater") != nil {Image("Stillwater").resizable().scaledToFill().frame(width:g.size.width,height:g.size.height).clipped().overlay([Color.clear,Color.cyan.opacity(0.12),Color.orange.opacity(0.12),Color.indigo.opacity(0.35)][lake])}
 else {LinearGradient(colors:[Color(red:0.35,green:0.64,blue:0.8),Color(red:0.04,green:0.32,blue:0.6),c61],startPoint:.top,endPoint:.bottom)}
 TimelineView(.animation(minimumInterval:still ? 2:0.05,paused:still)){line in
 Canvas{ctx,size in let w=size.width,h=size.height;let a=still ? 0:line.date.timeIntervalSinceReferenceDate
 if UIImage(named:"Stillwater")==nil {
 for j in 0..<3 {var p=Path();p.move(to:CGPoint(x:0,y:h*0.3));for i in 0...8 {p.addLine(to:CGPoint(x:w*Double(i)/8,y:h*(0.15+Double(j)*0.06+sin(Double(i)*1.8+Double(j))*0.08)))};p.addLine(to:CGPoint(x:w,y:h*0.43));p.addLine(to:CGPoint(x:0,y:h*0.43));p.closeSubpath();ctx.fill(p,with:.color(Color(red:0.02,green:0.18+Double(j)*0.03,blue:0.3+Double(j)*0.07)))}
 }
 for i in 0..<14 {let y=h*(0.46+Double(i)*0.038);let x=w*(0.1+Double((i*31)%71)/100);var p=Path();p.move(to:CGPoint(x:x+sin(a*0.5+Double(i))*5,y:y));p.addQuadCurve(to:CGPoint(x:min(w,x+35+Double(i%3)*15),y:y),control:CGPoint(x:x+20,y:y+2));ctx.stroke(p,with:.color(.white.opacity(0.12)),lineWidth:1)}
 if active {let x=w*0.52,y=h*0.64+sin(a*2)*3
 for i in 0..<3 {let s=CGFloat(20+i*18)+sin(a*1.5)*4;ctx.stroke(Path(ellipseIn:CGRect(x:x-s,y:y-s*0.24,width:s*2,height:s*0.48)),with:.color(c90.opacity(0.32-Double(i)*0.07)),lineWidth:1.2)}
 ctx.fill(Path(ellipseIn:CGRect(x:x-4,y:y-13,width:8,height:15)),with:.color(c28));ctx.fill(Path(ellipseIn:CGRect(x:x-4,y:y-2,width:8,height:5)),with:.color(c90))
 }
 }
 }
 }.frame(width:g.size.width,height:g.size.height).clipped()
 }.accessibilityHidden(true)
 }
}
