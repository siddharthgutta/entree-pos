//
//  Printer.m
//  StarPrinting
//
//  Created by Matthew Newberry on 4/10/13.
//  OpenTable

#import "Printer.h"
#import "PrintCommands.h"
#import "PrintParser.h"
#import <StarIO/Port.h>
#import <objc/runtime.h>

#define DEBUG_LOGGING           NO
#define DEBUG_PREFIX            @"Printer:"

#define kHeartbeatInterval      5.f
#define kJobRetryInterval       2.f

#define PORT_CLASS              [[self class] portClass]

typedef void(^PrinterOperationBlock)(void);
typedef void(^PrinterJobBlock)(BOOL portConnected);

@interface Printer ()

@property (nonatomic, strong) NSTimer *heartbeatTimer;
@property (nonatomic, assign) PrinterStatus previousOnlineStatus;

- (BOOL)performCompatibilityCheck;

@end

static Printer *connectedPrinter;

static char const * const PrintJobTag = "PrintJobTag";
static char const * const HeartbeatTag = "HeartbeatTag";
static char const * const ConnectJobTag = "ConnectJobTag";

@implementation Printer

#pragma mark - Class Methods

+ (Printer *)printerFromPort:(PortInfo *)port
{
    Printer *printer = [[Printer alloc] init];
    printer.modelName = port.modelName;
    printer.portName = port.portName;
    printer.macAddress = port.macAddress;
    
    [printer initialize];
    
    return printer;
}

+ (Printer *)connectedPrinter
{
    if (connectedPrinter) return connectedPrinter;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:kConnectedPrinterKey]) {
        NSData *encoded = [defaults objectForKey:kConnectedPrinterKey];
        connectedPrinter = [NSKeyedUnarchiver unarchiveObjectWithData:encoded];
        return connectedPrinter;
    }
    
    return nil;
}

+ (void)search:(PrinterSearchBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSArray *found = [PORT_CLASS searchPrinter];
        
        NSMutableArray *printers = [NSMutableArray arrayWithCapacity:[found count]];
        Printer *lastKnownPrinter = [Printer connectedPrinter];
        
        for(PortInfo *p in found) {
            Printer *printer = [Printer printerFromPort:p];
            if([printer.macAddress isEqualToString:lastKnownPrinter.macAddress]) {
                [printers addObject:lastKnownPrinter];
            } else {
                [printers addObject:printer];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(printers);
        });
    });
}

+ (Class)portClass
{
    return [SMPort class];
}

+ (NSString *)stringForStatus:(PrinterStatus)status
{
    switch (status) {
        case PrinterStatusConnected:
            return NSLocalizedString(@"Connected", @"Connected");
            break;
            
        case PrinterStatusConnecting:
            return NSLocalizedString(@"Connecting", @"Connecting");
            break;
            
        case PrinterStatusDisconnected:
            return NSLocalizedString(@"Disconnected", @"Disconnected");
            break;
            
        case PrinterStatusLowPaper:
            return NSLocalizedString(@"Low Paper", @"Low Paper");
            break;
            
        case PrinterStatusCoverOpen:
            return NSLocalizedString(@"Cover Open", @"Cover Open");
            break;
            
        case PrinterStatusOutOfPaper:
            return NSLocalizedString(@"Out of Paper", @"Out of Paper");
            break;
            
        case PrinterStatusConnectionError:
            return NSLocalizedString(@"Connection Error", @"Connection Error");
            break;
            
        case PrinterStatusLostConnectionError:
            return NSLocalizedString(@"Lost Connection", @"Lost Connection");
            break;
            
        case PrinterStatusPrintError:
            return NSLocalizedString(@"Print Error", @"Print Error");
            break;
        case PrinterStatusIncompatible:
            return NSLocalizedString(@"Incompatible Printer", @"Incompatible Printer");
            break;
        case PrinterStatusUnknownError:
        default:
            return NSLocalizedString(@"Unknown Error", @"Unknown Error");
            break;
    }
}

#pragma mark - Initialization & Coding

- (void)initialize
{
    self.jobs = [NSMutableArray array];
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 1;
    self.previousOnlineStatus = PrinterStatusDisconnected;
    
    [self performCompatibilityCheck];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.modelName forKey:@"modelName"];
    [encoder encodeObject:self.portName forKey:@"portName"];
    [encoder encodeObject:self.macAddress forKey:@"macAddress"];
    [encoder encodeObject:self.friendlyName forKey:@"friendlyName"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self) {
        self.modelName = [aDecoder decodeObjectForKey:@"modelName"];
        self.portName = [aDecoder decodeObjectForKey:@"portName"];
        self.macAddress = [aDecoder decodeObjectForKey:@"macAddress"];
        self.friendlyName = [aDecoder decodeObjectForKey:@"friendlyName"];
        [self initialize];
    }
    
    return self;
}

#pragma mark - Port Handling

- (BOOL)openPort
{
    BOOL error = NO;
    
    @try {
        self.port = [PORT_CLASS getPort:self.portName :nil :3000];
        if(!self.port) {
            error = YES;
        }
    } @catch (NSException *exception) {
        self.status = PrinterStatusUnknownError;
        error = YES;
    }
    
    return !error;
}

- (void)releasePort
{
    if(self.port) {
        [PORT_CLASS releasePort:self.port];
        self.port = nil;
    }
}


#pragma mark - Job Handling

- (void)addJob:(PrinterJobBlock)job
{
    if([self isHeartbeatJob:job] && [self.jobs count] > 0) return;
    
    [self.jobs addObject:job];
    [self printJobCount:@"Adding job"];
    
    if([self.jobs count] == 1 || self.queue.operationCount == 0) {
        [self runNext];
    }
}

- (void)runNext
{
    PrinterOperationBlock block = ^{
        
        if([self.jobs count] == 0) return;
        
        PrinterJobBlock job = self.jobs[0];
        BOOL portConnected = NO;
        
        for(int i = 0; i < 20; i++) {
            portConnected = [self openPort];
            if(portConnected) break;
            [self log:@"Retrying to open port!"];
            usleep(1000 * 333);
        }
        
        if(!portConnected) {
            // Printer is offline
            if(self.status != PrinterStatusUnknownError) {
                if([self isConnectJob:job]) {
                    self.status = PrinterStatusConnectionError;
                } else {
                    self.status = PrinterStatusLostConnectionError;
                }
            }
        } else {
            // Printer is online but might have an error
            [self updateStatus];
        }
        
        job(portConnected);
        [self releasePort];
    };
    
    [self.queue addOperationWithBlock:block];
}

- (void)jobWasSuccessful
{
    [self.jobs removeObjectAtIndex:0];
    [self printJobCount:@"SUCCESS, Removing job"];
    [self runNext];
}

- (void)jobFailedRetry:(BOOL)retry
{
    if(!retry) {
        [self.jobs removeObjectAtIndex:0];
        [self printJobCount:@"FAILURE, Removing job"];
    } else {
        double delayInSeconds = kJobRetryInterval;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            if([self.jobs count] == 0) return;
            [self log:@"***** RETRYING JOB ******"];
            
            PrinterJobBlock job = self.jobs[0];
            [self.jobs removeObjectAtIndex:0];
            [self.jobs addObject:job];
            
            [self runNext];
        });
    }
}

#pragma mark - Connection

- (void)connect:(PrinterResultBlock)result
{
    [self log:@"Attempting to connect"];
    
    connectedPrinter = self;
    self.status = PrinterStatusConnecting;
    
    PrinterJobBlock connectJob = ^(BOOL portConnected) {
        
        if(!portConnected) {
            [self jobFailedRetry:YES];
            [self log:@"Failed to connect"];
        } else {
            [self establishConnection];
            [self jobWasSuccessful];
            [self log:@"Successfully connected"];
        }
        
        if(result) {
            result(portConnected);
        }
    };
    
    objc_setAssociatedObject(connectJob, ConnectJobTag, @1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self addJob:connectJob];
}

- (void)establishConnection
{
    if(!self.isOnlineWithError) self.status = PrinterStatusConnected;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encoded = [NSKeyedArchiver archivedDataWithRootObject:self];
    [defaults setObject:encoded forKey:kConnectedPrinterKey];
    [defaults synchronize];
    
    [self startHeartbeat];
}

- (void)disconnect
{
    self.status = PrinterStatusDisconnected;
    connectedPrinter = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kConnectedPrinterKey];
    
    [self stopHeartbeat];
}

#pragma mark - Printing

- (void)printTest
{
    if(![Printer connectedPrinter]) return;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"xml"];
   
    NSDictionary *dictionary = @{
                           @"{{printerStatus}}" : [Printer stringForStatus:[Printer connectedPrinter].status],
                           @"{{printerName}}" : [Printer connectedPrinter].name
                           };
    
    PrintData *printData = [[PrintData alloc] initWithDictionary:dictionary atFilePath:filePath];
    
    [self print:printData];
}

- (void)print:(PrintData *)printData
{
    [self log:@"Queued a print job"];
    
    PrinterJobBlock printJob = ^(BOOL portConnected) {
        
        BOOL error = !portConnected || !self.isReadyToPrint;
        
        if(!error) {
            
            NSDictionary *dictionary = printData.dictionary;
            NSString *filePath = printData.filePath;
            
            NSData *contents = [[NSFileManager defaultManager] contentsAtPath:filePath];
            NSMutableString *s = [[NSMutableString alloc] initWithData:contents encoding:NSUTF8StringEncoding];
            
            [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
                [s replaceOccurrencesOfString:key withString:value options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
            }];
            
            PrintParser *parser = [[PrintParser alloc] init];
            NSData *data = [parser parse:[s dataUsingEncoding:NSUTF8StringEncoding]];
            
            if(![self printChit:data]) {
                self.status = PrinterStatusPrintError;
                error = YES;
            }
        }
        
        if(error) {
            [self log:@"Print job unsuccessful"];
            [self jobFailedRetry:YES];
        } else {
            [self log:@"Print job successfully finished"];
            [self jobWasSuccessful];
        }
    };
    
    objc_setAssociatedObject(printJob, PrintJobTag, @1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self addJob:printJob];
}

- (BOOL)printChit:(NSData *)data
{
    [self log:@"Printing"];
    
    BOOL error = NO;
    BOOL completed = NO;
    
    // Add cut manually
    NSMutableData *printData = [NSMutableData dataWithData:data];
    [printData appendData:[kPrinterCMD_CutFull dataUsingEncoding:NSASCIIStringEncoding]];
    
    int commandSize = [printData length];
    unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
    [printData getBytes:dataToSentToPrinter];
    
    do {
        @try {
            int totalAmountWritten = 0;
            while (totalAmountWritten < commandSize) {
                
                int remaining = commandSize - totalAmountWritten;
                
                int blockSize = (remaining > 1024) ? 1024 : remaining;
                
                int amountWritten = [self.port writePort:dataToSentToPrinter :totalAmountWritten :blockSize];
                totalAmountWritten += amountWritten;
            }
            
            if (totalAmountWritten < commandSize) {
                error = YES;
            }
        }
        @catch (PortException *exception) {
            [self log:[exception description]];
            error = YES;
        }
        
        completed = YES;
        
        free(dataToSentToPrinter);
        
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:kHeartbeatInterval]];
    } while (!completed);
    
    return !error;
}

#pragma mark - Heartbeat

- (void)heartbeat
{
    PrinterJobBlock heartbeatJob = ^(BOOL portConnected) {
        [self jobWasSuccessful];
        [self log:@"*** Heartbeat ***"];
    };

    objc_setAssociatedObject(heartbeatJob, HeartbeatTag, @1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self addJob:heartbeatJob];
}

- (void)startHeartbeat
{
    if(!self.heartbeatTimer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:kHeartbeatInterval target:self selector:@selector(heartbeat) userInfo:nil repeats:YES];
        });
    }
}

- (void)stopHeartbeat
{
    [self.heartbeatTimer invalidate];
    self.heartbeatTimer = nil;
}

#pragma mark - Status

- (void)updateStatus
{
    if (![self performCompatibilityCheck]) {
        return;
    }
    
    PrinterStatus status = PrinterStatusNoStatus;
    StarPrinterStatus_2 printerStatus;
    [self.port getParsedStatus:&printerStatus :2];
    
    if(printerStatus.offline == SM_TRUE) {
        if(printerStatus.coverOpen == SM_TRUE) {
            status = PrinterStatusCoverOpen;
        } else if(printerStatus.receiptPaperEmpty == SM_TRUE) {
            status = PrinterStatusOutOfPaper;
        } else if(printerStatus.receiptPaperNearEmptyInner == SM_TRUE ||
                  printerStatus.receiptPaperNearEmptyOuter == SM_TRUE) {
            status = PrinterStatusLowPaper;
        }
    }
    
    // CoverOpen, LowPaper, or OutOfPaper
    if(status != PrinterStatusNoStatus) {
        self.status = status;
        return;
    }
    
    // Printer did have error, but error is now resolved
    if(self.hasError) {
        self.status = self.previousOnlineStatus;
    }
}

- (void)setStatus:(PrinterStatus)status
{
    if(self.status != status) {
        
        if(!self.isOffline && self.status != PrinterStatusConnecting) {
            self.previousOnlineStatus = self.status;
        }
        
        _status = status;
        
        if(_delegate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate printer:self didChangeStatus:status];
            });
        }
    }
}

#pragma mark - Properties

- (NSString *)description
{
    NSString *desc = [NSString stringWithFormat:@"<Printer: %p { name:%@ mac:%@ model:%@ portName:%@ status:%@}>", self, self.name, self.macAddress, self.modelName, self.portName, [Printer stringForStatus:self.status]];
    
    return desc;
}

- (NSString *)name
{
    return self.friendlyName == nil ? self.modelName : self.friendlyName;
}

- (BOOL)isReadyToPrint
{
    return self.status == PrinterStatusConnected || self.status == PrinterStatusLowPaper;
}

- (BOOL)hasError
{
    return self.status != PrinterStatusConnected &&
    self.status != PrinterStatusConnecting &&
    self.status != PrinterStatusDisconnected;
}

- (BOOL)isOffline
{
    return self.status == PrinterStatusConnectionError ||
    self.status == PrinterStatusLostConnectionError ||
    self.status == PrinterStatusUnknownError;
}

- (BOOL)isOnlineWithError
{
    return self.hasError && !self.isOffline && self.status != PrinterStatusPrintError;
}

/*
 Star TSP100 model printers are do not support line mode commands.
 Until better raster mode support is enabled, we're notify that they're incompatible.
*/
- (BOOL)isCompatible
{
    BOOL compatible = YES;
    
    NSArray *p = [self.modelName componentsSeparatedByString:@" ("];
    if ([p count] == 2) {
        
        NSString *modelNumber = p[0];
        if ([modelNumber length] == 6 && [modelNumber rangeOfString:@"TSP1"].location != NSNotFound) {
            compatible = NO;
        }
    }
    
    return compatible;
}

- (BOOL)performCompatibilityCheck
{
    BOOL compatible = [self isCompatible];
    if (!compatible) {
        self.status = PrinterStatusIncompatible;
    }
    
    return compatible;
}

#pragma mark - Helpers

- (void)log:(NSString *)message
{
    if(DEBUG_LOGGING) {
        NSLog(@"%@", [NSString stringWithFormat:@"%@ %@ -> %@", DEBUG_PREFIX, self, message]);
    }
}

- (void)printJobCount:(NSString *)message
{
    [self log:[NSString stringWithFormat:@"%@ -> Job Count = %i", message, [self.jobs count]]];
}

- (BOOL)isConnectJob:(PrinterJobBlock)job
{
    NSNumber *isConnectJob = objc_getAssociatedObject(job, PrintJobTag);
    return [isConnectJob intValue] == 1;
}

- (BOOL)isPrintJob:(PrinterJobBlock)job
{
    NSNumber *isPrintJob = objc_getAssociatedObject(job, PrintJobTag);
    return [isPrintJob intValue] == 1;
}

- (BOOL)isHeartbeatJob:(PrinterJobBlock)job
{
    NSNumber *isHeartbeatJob = objc_getAssociatedObject(job, HeartbeatTag);
    return [isHeartbeatJob intValue] == 1;
}

@end
