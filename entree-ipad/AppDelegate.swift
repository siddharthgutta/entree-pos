
import UIKit

let UNRECOGNIZED_SEGUE_IDENTIFIER_ERROR_MESSAGE = "Unrecognized segue identifier"

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Parse
        Parse.setApplicationId("siTMH1dC5Qk84JvfZ3U5xfRfKwqb5jQv4CnCQGZn", clientKey: "rKr1TeMyRNFNhx4zI4guhzk39Uap7MoHYfxdHvQo")
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions) { (succeeded: Bool, error: NSError?) in
            if succeeded {
                println("Analytics: 👍")
            } else {
                println("Analytics: 👎")
            }
        }
        
        Employee.registerSubclass()
        Menu.registerSubclass()
        MenuCategory.registerSubclass()
        MenuItem.registerSubclass()
        MenuItemModifier.registerSubclass()
        Order.registerSubclass()
        Party.registerSubclass()
        Restaurant.registerSubclass()
        Shift.registerSubclass()
        Table.registerSubclass()
        Ticket.registerSubclass()
        
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

