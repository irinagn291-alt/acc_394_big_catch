import XCTest
#if RULE_CHECKS
final class C38:XCTestCase {
 func testIdleCapAndClock() {var d=D44();let base=Date(timeIntervalSince1970:100000);d.checkpoint=base;XCTAssertEqual(B85.idle(&d,base.addingTimeInterval(-10)),0);XCTAssertEqual(B85.idle(&d,base.addingTimeInterval(999999)),192);XCTAssertEqual(d.xp,96);XCTAssertTrue(d.catches.isEmpty);XCTAssertEqual(B85.idle(&d,base.addingTimeInterval(999999)),0)}
 func testCatchAndSeason() {var d=D44();let date=Date();for i in 0..<12 {B85.land(&d,B85.fish[i%6],3,date)};XCTAssertEqual(d.catches.count,6);XCTAssertEqual(d.seasonCount,12);XCTAssertEqual(d.badges.count,3);let next=Calendar.current.date(byAdding:.month,value:1,to:date)!;B85.rotate(&d,next);XCTAssertEqual(d.seasonCount,0);XCTAssertEqual(d.badges.count,3)}
 func testEquipmentCannotOverspend() {var d=D44();XCTAssertFalse(B85.buy(&d,0,2));XCTAssertEqual(d.coins,80);d.coins=500;XCTAssertTrue(B85.buy(&d,1,2));XCTAssertEqual(d.coins,220);XCTAssertTrue(B85.buy(&d,1,2));XCTAssertEqual(d.coins,220);XCTAssertEqual(d.lure,2)}
 func testLocalSpeciesAndLure() {var d=D44();for lake in 0..<4 {d.lake=lake;for i in 0..<100 {XCTAssertEqual(B85.pick(d,Date(),Double(i)/100).home,lake)}};d.lake=0;let a=B85.weights(d,Date()).first{$0.0.rare}!.1;d.lure=2;XCTAssertGreaterThan(B85.weights(d,Date()).first{$0.0.rare}!.1,a)}
 func testReelingHasSuccessAndFailure() {var s=T19();var r=0;for _ in 0..<500 {r=s.step(0.1,s.tension<0.5,0,false);if r != 0 {break}};XCTAssertEqual(r,1);var f=T19();for _ in 0..<100 {r=f.step(0.1,true,0,false);if r != 0 {break}};XCTAssertEqual(r,-1)}
 func testRoundTrip() throws {var d=D44();B85.land(&d,B85.fish[0],1.3,Date());let b=try JSONEncoder().encode(d);let p=try JSONDecoder().decode(D44.self,from:b);XCTAssertEqual(p.coins,d.coins);XCTAssertEqual(p.catches,d.catches)}
}
#else
final class H27:XCTestCase {
 @MainActor func testJourney() {
 let app=XCUIApplication();app.launch();XCTAssertTrue(app.buttons["cast"].waitForExistence(timeout:10));shot("01-lake",app)
 app.buttons["cast"].tap();XCTAssertTrue(app.buttons["hook"].waitForExistence(timeout:12));shot("02-bite",app);app.buttons["hook"].tap()
 for _ in 0..<90 {if app.buttons["cast"].exists {break};let gauge=app.descendants(matching:.any)["tension"].firstMatch;let val=(gauge.value as? String ?? "0").split(separator:"%").first.flatMap{Int($0)} ?? 0;if val<46 {app.buttons["reel"].tap()} else if val>62 {app.buttons["ease"].tap()};Thread.sleep(forTimeInterval:0.22)}
 XCTAssertTrue(app.buttons["cast"].exists);shot("03-catch",app)
 app.buttons["tab1"].tap();XCTAssertTrue(app.staticTexts.matching(NSPredicate(format:"label BEGINSWITH %@", "Caught ")).firstMatch.exists);shot("04-trophies",app);app.swipeUp();shot("05-season",app)
 app.buttons["tab2"].tap();XCTAssertTrue(app.buttons["gear01"].exists);shot("06-tackle",app)
 app.buttons["tab3"].tap();shot("07-lakes",app)
 app.terminate();app.launch();app.buttons["tab1"].tap();XCTAssertTrue(app.staticTexts.matching(NSPredicate(format:"label BEGINSWITH %@", "Caught ")).firstMatch.exists);shot("08-persistence",app)
 app.buttons["settings"].tap();shot("09-settings",app)
 app.buttons["preview"].tap();shot("10-widgets",app)
 }
 @MainActor func testReminderDenialDoesNotBlockPlay() {
 let app=XCUIApplication();app.launch();app.buttons["settings"].tap()
 let toggle=app.switches["reminders"];if !toggle.isHittable {app.swipeUp()};toggle.tap()
 let alert=XCUIApplication(bundleIdentifier:"com.apple.springboard").alerts.firstMatch
 if alert.waitForExistence(timeout:6) {let deny=alert.buttons.matching(NSPredicate(format:"label CONTAINS[c] %@", "Don")).firstMatch;XCTAssertTrue(deny.exists);deny.tap()}
 XCTAssertTrue(app.staticTexts["Disabled in system settings"].waitForExistence(timeout:5));shot("11-notification-denied",app)
 app.buttons["Done"].tap();XCTAssertTrue(app.buttons["cast"].waitForExistence(timeout:5))
 }
 @MainActor func shot(_ name:String,_ app:XCUIApplication) {let a=XCTAttachment(screenshot:app.screenshot());a.name=name;a.lifetime = .keepAlways;add(a)}
}
#endif
