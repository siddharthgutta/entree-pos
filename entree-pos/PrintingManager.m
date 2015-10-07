

#import "PrintingManager.h"
#import "entree_pos-Swift.h"

#import <StarPrinting/StarPrinting.h>

#define kReceiptPrinterMACAddressKey @"receipt_printer_mac_address"

@interface PrintingManager ()

@property NSMutableDictionary *printerCache;

@property NSDateFormatter *dateFormatter;
@property NSNumberFormatter *numberFormatter;

- (void)printerWithMACAddress:(NSString *)address completion:(void (^)(Printer *printer))completion;
- (void)sendPrintData:(PrintData *)printData toPrinterWithMACAddress:(NSString *)address;

@end

@implementation PrintingManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _printerCache = [NSMutableDictionary dictionary];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
        
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    }
    return self;
}

#pragma mark - Shared Manager

+ (instancetype)sharedManager {
    static PrintingManager *sharedManager = nil;
    @synchronized(self) {
        if (sharedManager == nil) {
            sharedManager = [[self alloc] init];
        }
    }
    return sharedManager;
}

#pragma mark - Receipt Printer MAC Address

+ (NSString *)receiptPrinterMACAddress {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kReceiptPrinterMACAddressKey];
}

+ (void)setReceiptPrinterMACAddress:(NSString *)address {
    [[NSUserDefaults standardUserDefaults] setObject:address forKey:kReceiptPrinterMACAddressKey];
}

- (void)presentAlertControllerForPrintErrorWithMessage:(NSString *)message fromViewController:(UIViewController *)viewController {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Printing Error" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil]];
    [viewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Printer Communication

- (void)printerWithMACAddress:(NSString *)address completion:(void (^)(Printer *printer))completion {
    Printer *cachedPrinter = self.printerCache[address];
    if (cachedPrinter) {
        completion(cachedPrinter);
    }
    
    [Printer search:^(NSArray *found) {
        for (Printer *printer in found) {
            self.printerCache[printer.macAddress] = printer;
            
            if (printer.macAddress == address) {
                completion(printer);
            }
        }
    }];
}

- (void)sendPrintData:(PrintData *)printData toPrinterWithMACAddress:(NSString *)address {
    [self printerWithMACAddress:address completion:^(Printer *printer) {
        if (printer.status == PrinterStatusConnected) {
            [printer print:printData];
        } else {
            [printer connect:^(BOOL success) {
                if (success) {
                    [printer print:printData];
                } else{
                    NSString *message = [NSString stringWithFormat:@"Failed to connect to printer with MAC address %@.", address];
                    [self presentAlertControllerForPrintErrorWithMessage:message fromViewController:nil];
                }
            }];
        }
    }];
}

#pragma mark - Send To Kitchen

- (void)printPrintJobsForOrderItems:(NSArray *)orderItems party:(Party *)party server:(Employee *)server toGo:(BOOL)toGo fromViewController:(UIViewController *)viewController {
    // This is wildly complex and should be simplified if at all possible
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Kitchen printer not found on network." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil]];
    [viewController presentViewController:alertController animated:true completion:nil];
    
    NSMutableArray *printJobs = [NSMutableArray array];
    NSMutableDictionary *printJobObjectIDToOrderItemMap = [NSMutableDictionary dictionary];
    NSMutableDictionary *printerMACAddressToPrintJobsMap = [NSMutableDictionary dictionary];
    
    for (OrderItem *orderItem in orderItems) {
        [printJobs addObjectsFromArray:orderItem.menuItem.printJobs];
        for (PrintJob *printJob in orderItem.menuItem.printJobs) {
            printJobObjectIDToOrderItemMap[printJob.objectId] = orderItem;
            printerMACAddressToPrintJobsMap[printJob.printer.mac] = [NSMutableArray array];
        }
    }
    
    for (PrintJob *printJob in printJobs) {
        NSMutableArray *printJobsForPrinter = printerMACAddressToPrintJobsMap[printJob.printer.mac];
        [printJobsForPrinter addObject:printJob];
    }
    
    for (NSString *address in printerMACAddressToPrintJobsMap.allKeys) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"{{location}}": toGo ? @"To Go" : @"Dine-In",
                                                                                          @"{{time}}": [self.dateFormatter stringFromDate:[NSDate date]],
                                                                                          @"{{table}}": party ? party.table.name : @"N/A",
                                                                                          @"{{server}}": party ? party.server.name : server.name}];
        
        NSMutableString *menuItemsXML = [NSMutableString string];
        
        NSArray *printJobsForPrinter = printerMACAddressToPrintJobsMap[address];
        for (PrintJob *printJob in printJobsForPrinter) {
            OrderItem *orderItem = printJobObjectIDToOrderItemMap[printJob.objectId];
            
            NSString *itemNameString = printJob.text.length == 0 ? printJob.text : orderItem.menuItem.name;
            NSString *itemNameXML = [NSString stringWithFormat:@"<text><left><large>%@</large></left></text><newline />", itemNameString];
            
            NSString *seatXML = orderItem.seatNumber == 0 ? @"" : [NSString stringWithFormat:@"<tab /><text><large>SEAT: %ld</large></text><newline />", (long) orderItem.seatNumber];
            
            NSMutableString *modifiersXML = [NSMutableString string];
            if (orderItem.menuItemModifiers.count > 0) {
                for (MenuItemModifier *modifier in orderItem.menuItemModifiers) {
                    NSString *modifierXML = [NSString stringWithFormat:@"<tab /><text><large><ic>+ %@</ic></large></text><newline />", modifier.name];
                    [modifiersXML appendString:modifierXML];
                }
            }
            
            NSString *notesXML = orderItem.notes.length == 0 ? @"" : [NSString stringWithFormat:@"<tab /><text><large><ic>+ %@</ic></large></text><newline />", orderItem.notes];
            
            NSString *menuItemXML = [NSString stringWithFormat:@"%@%@%@%@", itemNameXML, seatXML, modifiersXML, notesXML];
            [menuItemsXML appendString:menuItemXML];
        }
        
        dictionary[@"{{menu_items}}"] = menuItemsXML;
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"order_item_template" ofType:@"xml"];
        PrintData *printData = [[PrintData alloc] initWithDictionary:dictionary atFilePath:filePath];
        [self sendPrintData:printData toPrinterWithMACAddress:address];
    }
}

#pragma mark - Print Check

- (void)printCheckForOrderItems:(NSArray *)orderItems party:(Party *)party fromViewController:(UIViewController *)viewController {
    NSString *address = [PrintingManager receiptPrinterMACAddress];
    if (!address) {
        [self presentAlertControllerForPrintErrorWithMessage:@"No receipt printer set. Please configure this in settings." fromViewController:viewController];
        return;
    }
    
    Restaurant *restaurant = [Restaurant defaultRestaurantFromLocalDatastoreFetchIfNil];
    
    NSMutableString *orderItemsXML = [NSMutableString string];
    
    double amountDue = 0;
    double tax = 0;
    
    for (OrderItem *item in orderItems) {
        NSString *price = [self.numberFormatter stringFromNumber:[NSNumber numberWithDouble:[item itemCost]]];
        NSString *itemXML = [NSString stringWithFormat:@"<left><text>[%@] %@</text></left><newline />", price, item.menuItem.name];
        [orderItemsXML appendString:itemXML];
        
        amountDue += [item itemCost];
        tax += [item applicableTax];
    }

    double subtotal = amountDue + tax;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"{{restaurant}}": restaurant.name,
                                                                                      @"{{location}}": restaurant.location,
                                                                                      @"{{phone}}": restaurant.phone,
                                                                                      @"{{time}}": [self.dateFormatter stringFromDate:[NSDate date]],
                                                                                      @"{{table}}": party.table.name,
                                                                                      @"{{server}}": party.server.name,
                                                                                      @"{{items}}": orderItemsXML,
                                                                                      @"{{amount_due}}": [self.numberFormatter stringFromNumber:@(amountDue)],
                                                                                      @"{{tax}}": [self.numberFormatter stringFromNumber:@(tax)],
                                                                                      @"{{subtotal}}": [self.numberFormatter stringFromNumber:@(subtotal)]}];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"check_template" ofType:@"xml"];
    PrintData *printData = [[PrintData alloc] initWithDictionary:dictionary atFilePath:filePath];
    [self sendPrintData:printData toPrinterWithMACAddress:address];
}

#pragma mark - Print Receipt

- (void)printReceiptForOrder:(Order *)order fromViewController:(UIViewController *)viewController {
    NSString *address = [PrintingManager receiptPrinterMACAddress];
    if (!address) {
        [self presentAlertControllerForPrintErrorWithMessage:@"No receipt printer set. Please configure this in settings." fromViewController:viewController];
        return;
    }
    
    BOOL cardPayment = order.payment.cardFlightChargeToken == nil;
    
    Restaurant *restaurant = [Restaurant defaultRestaurantFromLocalDatastoreFetchIfNil];
    
    NSMutableString *orderItemsXML = [NSMutableString string];
    for (OrderItem *orderItem in order.orderItems) {
        NSString *orderItemXML = [NSString stringWithFormat:@"<text>[%@] %@</text><newline />", [self.numberFormatter stringFromNumber:@(orderItem.itemCost)], orderItem.menuItem.name];
        [orderItemsXML appendString:orderItemXML];
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"{{copy}}": @"Customer Copy",
                                                                                      @"{{restaurant}}": restaurant.name,
                                                                                      @"{{location}}": restaurant.location,
                                                                                      @"{{phone}}": restaurant.phone,
                                                                                      @"{{time}}": [self.dateFormatter stringFromDate:[NSDate date]],
                                                                                      @"{{server}}": order.server.name,
                                                                                      @"{{order_id}}": order.objectId,
                                                                                      @"{{payment_id}}": order.payment.objectId,
                                                                                      @"{{order_items}}": orderItemsXML,
                                                                                      @"{{subtotal}}": [self.numberFormatter stringFromNumber:@(order.subtotal)]}];
    
    if (cardPayment) {
        dictionary[@"{{last_four}}"] = order.payment.cardLastFour;
        dictionary[@"{{cardholder}}"] = order.payment.cardName;
    } else {
        dictionary[@"{{cash_amount_paid}}"] = [self.numberFormatter stringFromNumber:[NSNumber numberWithDouble:order.payment.cashAmountPaid]];
        dictionary[@"{{change_given}}"] = [self.numberFormatter stringFromNumber:[NSNumber numberWithDouble:order.payment.changeGiven]];
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_receipt_template", order.payment.type.lowercaseString] ofType:@"xml"];
    PrintData *printData = [[PrintData alloc] initWithDictionary:dictionary atFilePath:filePath];
    [self sendPrintData:printData toPrinterWithMACAddress:address];
    
    if (cardPayment) {
        dictionary[@"{{copy}}"] = @"Merchant Copy";
        PrintData *printData = [[PrintData alloc] initWithDictionary:dictionary atFilePath:filePath];
        [self sendPrintData:printData toPrinterWithMACAddress:address];
    }
}

#pragma mark - Print Server Summary

- (void)printSummaryForServer:(Employee *)server date:(NSDate *)date fromViewController:(UIViewController *)viewController {
    NSString *address = [PrintingManager receiptPrinterMACAddress];
    if (!address) {
        [self presentAlertControllerForPrintErrorWithMessage:@"No receipt printer set. Please configure this in settings." fromViewController:viewController];
        return;
    }
    
    PFQuery *query = [Order query];
    query.limit = 1000;
    
    [query includeKey:@"payment"];
    
    [query whereKey:@"createdAt" greaterThanOrEqualTo:[[NSCalendar currentCalendar] startOfDayForDate:date]];
    [query whereKey:@"createdAt" lessThan:[[NSCalendar currentCalendar] startOfDayForDate:[date dateByAddingTimeInterval:86400]]];
    [query whereKey:@"server" equalTo:server];
    
    [query whereKeyExists:@"payment"];
    
    /*
    PFQuery *innerQuery = [Payment query];
    [innerQuery whereKey:@"chargedAt" equalTo:@YES];
    [query whereKey:@"payment" matchesQuery:innerQuery];
     */
    
    NSArray *orders = [query findObjects]; // This is a synchronous request, should be avoided if possible
    
    NSMutableString *ordersXML = [NSMutableString string];
    
    double cardTotal = 0;
    double cashTotal = 0;
    double tips = 0;
    
    for (Order *order in orders) {
        NSString *orderID = order.objectId;
        NSString *paymentType = order.payment.type;
        NSString *subtotal = [self.numberFormatter stringFromNumber:@(order.subtotal)];
        NSString *tip = [self.numberFormatter stringFromNumber:@(order.tip)];
        
        if ([paymentType isEqualToString:@"Card"]) {
            cardTotal += order.total;
        } else {
            cashTotal += order.total;
        }
        tips += order.tip;
        
        NSString *orderXML = [NSString stringWithFormat:@"<text>Order ID: %@</text><newline /><tab><text>Payment Type: %@</text><newline /><tab><text>Subtotal: %@</text><newline /><tab><text>Tip: %@</text><newline /><newline />", orderID, paymentType, subtotal, tip];
        [ordersXML appendString:orderXML];
    }
    
    NSDictionary *dictionary = @{@"{{name}}": server.name,
                                 @"{{date}}": [self.dateFormatter stringFromDate:date],
                                 @"{{orders}}": ordersXML,
                                 @"{{card}}": [self.numberFormatter stringFromNumber:@(cardTotal)],
                                 @"{{cash}}": [self.numberFormatter stringFromNumber:@(cashTotal)],
                                 @"{{tips}}": [self.numberFormatter stringFromNumber:@(tips)]};
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"server_summary_template" ofType:@"xml"];
    PrintData *printData = [[PrintData alloc] initWithDictionary:dictionary atFilePath:filePath];
    [self sendPrintData:printData toPrinterWithMACAddress:address];
}

#pragma mark - Printer Search Wrapper

- (void)searchForPrintersWithCompletion:(void (^)(NSArray<Printer *> *results))completion {
    [Printer search:^(NSArray *found) {
        completion(found);
    }];
}

@end
