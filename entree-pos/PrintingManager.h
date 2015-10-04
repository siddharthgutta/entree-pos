
#import <UIKit/UIKit.h>

@class Employee, Order, OrderItem, Party, Printer;

@interface PrintingManager : NSObject

+ (instancetype)sharedManager;

+ (NSString *)receiptPrinterMACAddress;
+ (void)setReceiptPrinterMACAddress:(NSString *)address;

- (void)printPrintJobsForOrderItems:(NSArray *)orderItems party:(Party *)party server:(Employee *)server toGo:(BOOL)toGo fromViewController:(UIViewController *)viewController;
- (void)printCheckForOrderItems:(NSArray *)orderItems party:(Party *)party fromViewController:(UIViewController *)viewController;
- (void)printReceiptForOrder:(Order *)order fromViewController:(UIViewController *)viewController;
- (void)printSummaryForServer:(Employee *)server date:(NSDate *)date fromViewController:(UIViewController *)viewController;

- (void)searchForPrintersWithCompletion:(void (^)(NSArray<Printer *> *results))completion;

@end
