
import UIKit

let CARDFLIGHT_DEVELOPMENT_API_KEY = "4bd62d6719544a30ae6cf5811d1145a8"
let CARDFLIGHT_PRODUCTION_API_KEY = "d384bbb0da123af65c1c24d6f792a75c"

let LOAD_OBJECTS_NOTIFICATION = "load_objects"
let UNRECOGNIZED_SEGUE_IDENTIFIER_ERROR_MESSAGE = "😕 Unrecognized segue identifier"

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    let reader = CFTReader(reader: 0)
    
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Parse
        Parse.setApplicationId("siTMH1dC5Qk84JvfZ3U5xfRfKwqb5jQv4CnCQGZn", clientKey: "rKr1TeMyRNFNhx4zI4guhzk39Uap7MoHYfxdHvQo")
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions) { (succeeded: Bool, error: NSError?) in
            if succeeded {
                println("Parse Analytics: 👍")
            } else {
                println("Parse Analytics: 👎")
            }
        }
        
        Employee.registerSubclass()
        Menu.registerSubclass()
        MenuCategory.registerSubclass()
        MenuItem.registerSubclass()
        MenuItemModifier.registerSubclass()
        Order.registerSubclass()
        OrderItem.registerSubclass()
        Party.registerSubclass()
        Payment.registerSubclass()
        PrintJob.registerSubclass()
        Restaurant.registerSubclass()
        Shift.registerSubclass()
        StarPrinter.registerSubclass()
        Table.registerSubclass()
        
        // CardFlight
        // Logging is enabled for debuging purposes
        CFTSessionManager.sharedInstance().setLogging(true)
        
        if let restaurant = Restaurant.synchronouslyFetchDefaultRestaurant() {
            CFTSessionManager.sharedInstance().setApiToken(CARDFLIGHT_PRODUCTION_API_KEY, accountToken: restaurant.cardFlightAccountToken)
            println("CardFlight: 👍")
        } else {
            println("CardFlight: 👎")
        }
        
        // UIAppearance
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

