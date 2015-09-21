
#import <Foundation/Foundation.h>

@class Employee, Order, OrderItem, Party, Printer;

@interface PrintingManager : NSObject

+ (instancetype)sharedManager;

+ (NSString *)receiptPrinterMACAddress;
+ (void)setReceiptPrinterMACAddress:(NSString *)address;

- (void)printPrintJobsForOrderItems:(NSArray *)orderItems party:(Party *)party server:(Employee *)server toGo:(BOOL)toGo;
- (void)printCheckForOrderItems:(NSArray *)orderItems party:(Party *)party;
- (void)printReceiptForOrder:(Order *)order;
- (void)printSummaryForServer:(Employee *)server date:(NSDate *)date;

- (void)searchForPrintersWithCompletion:(void (^)(NSArray<Printer *> *results))completion;

@end
