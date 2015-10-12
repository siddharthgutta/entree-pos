
import UIKit

let PARSE_APPLICATION_ID = "siTMH1dC5Qk84JvfZ3U5xfRfKwqb5jQv4CnCQGZn"
let PARSE_CLIENT_KEY = "rKr1TeMyRNFNhx4zI4guhzk39Uap7MoHYfxdHvQo"

let CARDFLIGHT_DEVELOPMENT_API_KEY = "4bd62d6719544a30ae6cf5811d1145a8"
let CARDFLIGHT_PRODUCTION_API_KEY = "d384bbb0da123af65c1c24d6f792a75c"

let LOAD_OBJECTS_NOTIFICATION = "load_objects"

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Parse
        Parse.enableLocalDatastore()
        Parse.setApplicationId(PARSE_APPLICATION_ID, clientKey: PARSE_CLIENT_KEY)
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions) { (succeeded: Bool, error: NSError?) in
            if succeeded {
                print("Parse Analytics: 👍")
            } else {
                print("Parse Analytics: 👎\nError: \(error)")
            }
            BITHockeyManager.sharedHockeyManager().configureWithIdentifier("399ffede8586a6ffe6624efc83173269")
            // Do some additional configuration if needed here
            BITHockeyManager.sharedHockeyManager().startManager()
            BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()

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
        
        // Logging should only be enabled for debugging purposes
        // CFTSessionManager.sharedInstance().setLogging(true)
        
        if let restaurant = Restaurant.synchronouslyFetchDefaultRestaurant() {
            CFTSessionManager.sharedInstance().setApiToken(CARDFLIGHT_PRODUCTION_API_KEY, accountToken: restaurant.cardFlightAccountToken)
            print("CardFlight: 👍")
        } else {
            print("CardFlight: 👎")
        }
        
        // UIAppearance
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
        
        return true
    }

}

