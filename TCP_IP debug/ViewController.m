//
//  ViewController.m
//  TCP_IP debug
//
//  Created by BP on 03/03/2017.
//  Copyright © 2017 B&P. All rights reserved.
//

#import "ViewController.h"
#import "Unit.h"

#define carbonPort 4500
#define pchPort 4501
#define ADCPort 4502

@implementation ViewController
{
    Socket * socket1;
    Socket * socket2;
    Socket * socket3;
    Socket * socket4;
    dispatch_group_t testItemGroup;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self->socket = [[Socket alloc]init];
    self->socket->listenSocket = -1;
    commandDic = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"commandList" ofType:@"plist"]];
//    NSLog(@"%@",commandDic);
    NSArray * powerOnArr = [commandDic objectForKey:@"powerOn"];
    NSLog(@"%@",powerOnArr);
//    socket1 = [[Socket alloc] init];
//    socket2 = [[Socket alloc] init];
//    socket3 = [[Socket alloc] init];
//    socket4 = [[Socket alloc] init];
    testItemGroup = dispatch_group_create();
    // Do any additional setup after loading the view.
}
- (IBAction)slot1StartTest:(id)sender {
    Unit * unit1 = [[Unit alloc] initWithContext:@{@"slotId":@"1"}];
    [unit1 setValue:@"hello" forKey:@"command"];
    dispatch_group_async(testItemGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self startTest:unit1];
    });
}
- (IBAction)slot2StartTest:(id)sender {
    Unit * unit2 = [[Unit alloc] initWithContext:@{@"slotId":@"2"}];
    dispatch_group_async(testItemGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self startTest:unit2];
    });
}
- (IBAction)slot3StartTest:(id)sender {
    Unit * unit3 = [[Unit alloc] initWithContext:@{@"slotId":@"3"}];
    dispatch_group_async(testItemGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self startTest:unit3];
    });
}
- (IBAction)slot4StartTest:(id)sender {
    Unit * unit4 = [[Unit alloc] initWithContext:@{@"slotId":@"4"}];
    dispatch_group_async(testItemGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self startTest:unit4];
    });
}


- (void)startTest:(Unit *)unit
{
    NSString * address = [NSString stringWithFormat:@"10.0.100.%d1",unit.slot];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5* NSEC_PER_SEC));
    __block BOOL connected = NO;
    [self logInfo:[NSString stringWithFormat:@"Connecting to carbon 10.0.100.%d1!",unit.slot] slot:unit.slot];
    dispatch_async(dispatch_queue_create("Connection Queue", NULL),
                   ^{
                       if([socket ConnectSocketIP:address andPort:carbonPort])
                       {
                           [self logInfo:@"Opening interface successfully!" slot:unit.slot];
                           connected = YES;
                           dispatch_semaphore_signal(semaphore);
                       }
                       
                   });
    dispatch_semaphore_wait(semaphore, timeout);
    
    if (!connected)
    {
        [self logError:@"Opening interface errored" slot:unit.slot];
        return;
    }
    
    do {
        NSString * cmd = @"USB20_SWITCH_DEBUG";
        NSString * oKay = [socket sendCMDBySocket:cmd WithTime:@5];
        if (![oKay containsString:@"OK"])
        {
            [self logError:@"USB20_SWITCH_DEBUG errored" slot:unit.slot];
        }else{
            [self logError:@"USB20_SWITCH_DEBUG OK" slot:unit.slot];
        }
        cmd = @"IIC_BATT_SWITCH_DIS";
        oKay = [socket sendCMDBySocket:cmd WithTime:@5];
    } while (0);
    
    
    //check BatteryVoltageCheck
    do {
        NSString * cmd = @"FORCE_BAT_EN";
        NSString * oKay = [socket sendCMDBySocket:cmd WithTime:@5];
        if (![oKay containsString:@"OK"])
        {
            [self logError:@"enable Battery errored\n" slot:unit.slot];
            return;
        }
        [NSThread sleepForTimeInterval:1];
        cmd = @"IIC_BATT1_SWITCH_EN";
        oKay = [socket sendCMDBySocket:cmd WithTime:@5];
        if (![oKay containsString:@"OK"])
        {
            [self logError:@"enable I2C errored\n" slot:unit.slot];
            return;
        }
        
        [NSThread sleepForTimeInterval:2];
        
        if (![[self BatteryVoltageCheck:@"IIC_BATT1_READ_VOL" unit:unit] containsString:@"OK"]) {
            return;
        }
        
        cmd = @"MLB_EN_BAT";
        oKay = [socket sendCMDBySocket:cmd WithTime:@5];
        if (![oKay containsString:@"OK"])
        {
            [self logError:@"disenable Battery errored\n" slot:unit.slot];
            return;
        }
        [NSThread sleepForTimeInterval:0.5];
        cmd = @"IIC_BATT1_SWITCH_DIS";
        oKay = [socket sendCMDBySocket:cmd WithTime:@5];
        if (![oKay containsString:@"OK"])
        {
            [self logError:@"disable i2C errored\n" slot:unit.slot];
            return;
        }
    } while (0);
    
    NSArray * powerOnArr = [commandDic objectForKey:@"powerOn"];
    NSArray * powerOffArr = [commandDic objectForKey:@"powerOff"];
    NSArray * enterDFUArr = [commandDic objectForKey:@"enterDFU"];
    
    NSMutableArray * sequenceArr = [[NSMutableArray alloc] init];
    [sequenceArr addObject:powerOnArr];
    [sequenceArr addObject:powerOffArr];
    [sequenceArr addObject:enterDFUArr];
    
//    for (NSArray * arr in sequenceArr) {
//        if ([self powerOn:unit withArr:arr]) {
//
//        };
//    }
    
    [self powerOn:unit];
    [self powerOff:unit];
    [self enterDFU:unit];
    
    
    [unit setCode:0];
}
- (NSString *)BatteryVoltageCheck:(NSString *)CMD unit:(Unit *)unit
{
    //IIC_BATT1_SET_VOL      set voltage
    //IIC_BATT1_READ_VOL     read voltage
    //return "Battery Voltage = %dmV\r"
    NSString * oKay = nil;
    NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:5];
    while ([[NSDate date] timeIntervalSinceDate:timeout] < 0 ) {
        [NSThread sleepForTimeInterval:1];
        oKay = [socket sendCMDBySocket:CMD WithTime:@5];
        if ([oKay containsString:@"Fail"] || [oKay containsString:@"ERROR"]) {
            continue;
        }
        oKay = [oKay stringByReplacingOccurrencesOfString:@"Battery Voltage = " withString:@""];
        oKay = [oKay stringByReplacingOccurrencesOfString:@"mV\r" withString:@""];
        if ((oKay.doubleValue/1000  >= 12.06) && (oKay.doubleValue/1000 <= 13.33)) {
            [self logInfo:[NSString stringWithFormat:@"Battery Voltage is %f,in limit 12.06-13.33",oKay.doubleValue/1000] slot:unit.slot];
            return @"OK";
        }
    }
    [self logError:[NSString stringWithFormat:@"Battery Voltage is %f,not in limit 12.06-13.33",oKay.doubleValue/1000] slot:unit.slot];
    return @"ERROR";
}

- (BOOL)powerOn:(Unit *)unit
{
    BOOL powerOnPass = TRUE;
    NSString * oKay = nil;
    NSNumber * volCheck = nil;
    NSArray * powerOnArr = [commandDic objectForKey:@"powerOn"];
    for (NSString * cmd in powerOnArr)
    {
        if ([cmd containsString:@"sleep"]) {
            [NSThread sleepForTimeInterval:5];
        }
        if (![cmd containsString:@"limit"])
        {
            oKay = [socket sendCMDBySocket:cmd WithTime:@5];
            if ([oKay containsString:@"OK"]) {
                [self logInfo:oKay slot:unit.slot];
            }else{
                [self logError:oKay slot:unit.slot];
                [unit setCode:110];
                powerOnPass = FALSE;
                return FALSE;
            }
        }
        NSArray * cmdArr = [cmd componentsSeparatedByString:@","];
        if (!(cmdArr.count > 2)) {
            return FALSE;
        }
        
        NSDate * timeout = [NSDate dateWithTimeIntervalSinceNow:5];
        while ([[NSDate date] timeIntervalSinceDate:timeout] < 0) {
            volCheck = [self getADCValueBySignal:cmdArr[0] unit:unit];
            if ([cmd containsString:@"+"]) {
                if (volCheck.doubleValue > [cmdArr[2] doubleValue]) {
                    [self logInfo:[NSString stringWithFormat:@"%@ value is %@ in limit[value > %@]",cmdArr[0],volCheck,cmdArr[2]] slot:unit.slot];
                    break;
                }else{
                    [self logError:[NSString stringWithFormat:@"%@ value is not in limit[value > %@]",cmdArr[0],cmdArr[2]] slot:unit.slot];
                    [unit setCode:-1227];
                    powerOnPass = FALSE;
                }
            }else{
                if ((volCheck.doubleValue > [cmdArr[2] doubleValue]) && (volCheck.doubleValue < [cmdArr[3] doubleValue])) {
                    [self logInfo:[NSString stringWithFormat:@"%@ value is %@ in limit[%@-%@]",cmdArr[0],volCheck,cmdArr[2],cmdArr[3]] slot:unit.slot];
                    break;
                }else{
                    [self logError:[NSString stringWithFormat:@"%@ value is not in limit[%@-%@]",cmdArr[0],cmdArr[2],cmdArr[3]] slot:unit.slot];
                    [unit setCode:-1227];
                    powerOnPass = FALSE;
                }
            }
        }
        [NSThread sleepForTimeInterval:1];
    }
    
    if (powerOnPass) {
        return TRUE;
    }else{
        return FALSE;
    }
}

- (BOOL)powerOff:(Unit *)unit
{
    BOOL powerOffPass = TRUE;
    NSString * oKay = nil;
    NSNumber * volCheck = nil;
    NSArray * powerOnArr = [commandDic objectForKey:@"powerOff"];
    for (NSString * cmd in powerOnArr)
    {
        if ([cmd containsString:@"sleep"]) {
            [NSThread sleepForTimeInterval:5];
        }
        if (![cmd containsString:@"limit"])
        {
            oKay = [socket sendCMDBySocket:cmd WithTime:@5];
            if ([oKay containsString:@"OK"]) {
                [self logInfo:oKay slot:unit.slot];
            }else{
                [self logError:oKay slot:unit.slot];
                [unit setCode:110];
                powerOffPass = FALSE;
                return FALSE;
            }
        }
        NSArray * cmdArr = [cmd componentsSeparatedByString:@","];
        if (!(cmdArr.count > 2)) {
            return FALSE;
        }
        
        NSDate * timeout = [NSDate dateWithTimeIntervalSinceNow:5];
        while ([[NSDate date] timeIntervalSinceDate:timeout] < 0) {
            volCheck = [self getADCValueBySignal:cmdArr[0] unit:unit];
            if ([cmd containsString:@"+"]) {
                if (volCheck.doubleValue > [cmdArr[2] doubleValue]) {
                    [self logInfo:[NSString stringWithFormat:@"%@ value is %@ in limit[value > %@]",cmdArr[0],volCheck,cmdArr[2]] slot:unit.slot];
                    break;
                }else{
                    [self logError:[NSString stringWithFormat:@"%@ value is not in limit[value > %@]",cmdArr[0],cmdArr[2]] slot:unit.slot];
                    [unit setCode:-1227];
                    powerOffPass = FALSE;
                }
            }else{
                if ((volCheck.doubleValue > [cmdArr[2] doubleValue]) && (volCheck.doubleValue < [cmdArr[3] doubleValue])) {
                    [self logInfo:[NSString stringWithFormat:@"%@ value is %@ in limit[%@-%@]",cmdArr[0],volCheck,cmdArr[2],cmdArr[3]] slot:unit.slot];
                    break;
                }else{
                    [self logError:[NSString stringWithFormat:@"%@ value is not in limit[%@-%@]",cmdArr[0],cmdArr[2],cmdArr[3]] slot:unit.slot];
                    [unit setCode:-1227];
                    powerOffPass = FALSE;
                }
            }
        }
        [NSThread sleepForTimeInterval:1];
    }
    
    if (powerOffPass) {
        return TRUE;
    }else{
        return FALSE;
    }
}

- (BOOL)enterDFU:(Unit *)unit
{
    BOOL enterDFUPass = TRUE;
    NSString * oKay = nil;
    NSNumber * volCheck = nil;
    NSArray * powerOnArr = [commandDic objectForKey:@"enterDFU"];
    for (NSString * cmd in powerOnArr)
    {
        if ([cmd containsString:@"POWERON"]) {
            if (![self powerOn:unit]) {
                return FALSE;
            };
        }
        if ([cmd containsString:@"sleep"]) {
            [NSThread sleepForTimeInterval:5];
        }
        if (![cmd containsString:@"limit"])
        {
            oKay = [socket sendCMDBySocket:cmd WithTime:@5];
            if ([oKay containsString:@"OK"]) {
                [self logInfo:oKay slot:unit.slot];
            }else{
                [self logError:oKay slot:unit.slot];
                [unit setCode:110];
                enterDFUPass = FALSE;
                return FALSE;
            }
        }
        NSArray * cmdArr = [cmd componentsSeparatedByString:@","];
        if (!(cmdArr.count > 2)) {
            return FALSE;
        }
        
        NSDate * timeout = [NSDate dateWithTimeIntervalSinceNow:5];
        while ([[NSDate date] timeIntervalSinceDate:timeout] < 0) {
            volCheck = [self getADCValueBySignal:cmdArr[0] unit:unit];
            if ([cmd containsString:@"+"]) {
                if (volCheck.doubleValue > [cmdArr[2] doubleValue]) {
                    [self logInfo:[NSString stringWithFormat:@"%@ value is %@ in limit[value > %@]",cmdArr[0],volCheck,cmdArr[2]] slot:unit.slot];
                    break;
                }else{
                    [self logError:[NSString stringWithFormat:@"%@ value is not in limit[value > %@]",cmdArr[0],cmdArr[2]] slot:unit.slot];
                    [unit setCode:-1227];
                    enterDFUPass = FALSE;
                }
            }else{
                if ((volCheck.doubleValue > [cmdArr[2] doubleValue]) && (volCheck.doubleValue < [cmdArr[3] doubleValue])) {
                    [self logInfo:[NSString stringWithFormat:@"%@ value is %@ in limit[%@-%@]",cmdArr[0],volCheck,cmdArr[2],cmdArr[3]] slot:unit.slot];
                    break;
                }else{
                    [self logError:[NSString stringWithFormat:@"%@ value is not in limit[%@-%@]",cmdArr[0],cmdArr[2],cmdArr[3]] slot:unit.slot];
                    [unit setCode:-1227];
                    enterDFUPass = FALSE;
                }
            }
        }
        [NSThread sleepForTimeInterval:1];
    }
    
    if (enterDFUPass) {
        return TRUE;
    }else{
        return FALSE;
    }
    
}

- (NSNumber *)getADCValueBySignal:(NSString *)signal unit:(Unit *)unit
{
    NSNumber *defaultReturn = @9999;
    uint8_t channel = CarbonADCChannelForSignal(signal);
    
    NSString * command  = [NSString stringWithFormat:@"get_adc ch%d",channel];
    NSNumber *timeout = @10;
    NSString * frameTerminator = @"$";
    
    NSString * response = [[NSString alloc]init];
    BOOL didTimeout = NO;
    
    if([socket WriteCMDBySocket:command] == true){
        response = [socket ReadStrBySocketWithTime:timeout frameTerminator:frameTerminator];
    }
    if (![[response uppercaseString] containsString:@"CHL"]) {
        NSString *string = [socket ReadStrBySocketWithTime:timeout frameTerminator:frameTerminator];
        response = [response stringByAppendingString:string];
    }
    if (didTimeout)
    {
        [self logError:@"Error:  UART (%@) command '%@' timeout!\n" slot:unit.slot];
        return defaultReturn;
    }
    
    // begin get the number value from the response string.
    if ([response containsString:@"error"])
    {
        [self logError:@"command return error" slot:unit.slot];
        return defaultReturn;
    }
    
    NSString *patternStr = [NSString stringWithFormat:@"CHL%d=(-?\\d+\\.?)mV",channel];
    NSString *value = nil;
    
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:patternStr options:NSRegularExpressionCaseInsensitive error:nil];
    if (!response)
    {
        [self logError:@"Response is nil!!!" slot:unit.slot];
        return defaultReturn;
    }

    @try
    {
        NSLog(@"[SLOT:%d] parsed output was: %@", unit.slot, [response copy]);
        NSLog(@"[SLOT:%d] Length is: %lu", unit.slot, (unsigned long)[[response copy] length]);
        NSArray *matches =[regExp matchesInString:response options:0 range:NSMakeRange(0, [[response copy] length])];
        
        for (NSTextCheckingResult *match in matches)
        {
            NSRange firstHalfRange = [match rangeAtIndex:1];
            value = [response substringWithRange:firstHalfRange];
            [self logInfo:[NSString stringWithFormat:@"%@ value=%@",signal,value] slot:unit.slot];
            break;
        }
    }
    @catch (NSException *exception)
    {
        if (exception)
        {
            [self logError:[NSString stringWithFormat:@"<Exception> can't get expect value string(xx.xx) error:%@\n",exception] slot:unit.slot];
            return defaultReturn;
        }
    }
    
    if (value == nil)
    {
        return defaultReturn;
    }
    
    value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
    value = [value stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    value = [value stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSNumber *transValue = [NSNumber numberWithFloat:([value floatValue] / 1000)];
    return transValue;
}
uint8_t CarbonADCChannelForSignal(NSString* signal)
{
#define RETURN_CH_MAP(s,c)   if ([signal isEqual:@s]) return c;
    
    //J132
    RETURN_CH_MAP("SOC_USB_VBUS",1);
    RETURN_CH_MAP("PM_PCH_SYS_PWROK",2);
    RETURN_CH_MAP("PM_SLP_S3_L",3);
    RETURN_CH_MAP("PPBUS_G3H",4);
    RETURN_CH_MAP("PP3V3_G3H",5);
    RETURN_CH_MAP("PP1V_PRIM",6);
    RETURN_CH_MAP("PPVCC_S0_CPU",7);
    RETURN_CH_MAP("PP3V3_G3H_RTC",8);
    RETURN_CH_MAP("CHGR_EN_MVR",9);
    RETURN_CH_MAP("PP1V8_SSD0",10);
    RETURN_CH_MAP("PP0V9_SSD0",11);
    RETURN_CH_MAP("PP2V7_NAND_SSD0",12);
    RETURN_CH_MAP("P1V8_G3S",13);
    
    //change
    RETURN_CH_MAP("PPDCIN_G3H",14);
    RETURN_CH_MAP("PP3V3_S5",15);
    RETURN_CH_MAP("PPDCIN_G3H_CHGR",16);
    RETURN_CH_MAP("PP1V2_S3",17);
    RETURN_CH_MAP("PP0V82_SLPDDR",18);
    RETURN_CH_MAP("PPVBAT_G3H_CONN",19);
    RETURN_CH_MAP("PPVDDCPU_AWAKE",20);
    RETURN_CH_MAP("PP1V8_SLPS2R",21);
    
    RETURN_CH_MAP("PMU_SYS_ALIVE",22);
    RETURN_CH_MAP("PM_PCH_PWROK",23);
    RETURN_CH_MAP("NULL",24);
    RETURN_CH_MAP("PP20V_USBC_XA_VBUS",25);
    //    RETURN_CH_MAP("SYS_DETECT_L",26);
    RETURN_CH_MAP("PMU_ACTIVE_READY",27);
    RETURN_CH_MAP("SOC_FORCE_DFU",28);
    RETURN_CH_MAP("PP20V_USBC_XB_VBUS",29);
    RETURN_CH_MAP("PP20V_USBC_TA_VBUS",30);
    //    RETURN_CH_MAP("PP20V_USBC_XA_VBUS",31);
    //0906Update
    RETURN_CH_MAP("PP20V_USBC_TB_VBUS",31);
    RETURN_CH_MAP("PP1V8_S5",32);
    RETURN_CH_MAP("SMC_SYSRST_L",33);
    RETURN_CH_MAP("SOC_SOCHOT_L",34);
    
    RETURN_CH_MAP("SSD_PMU_RESET_L",36);
    RETURN_CH_MAP("PMU_COLD_RESET_L",37);
    RETURN_CH_MAP("PM_SYSRST_L",38);
    RETURN_CH_MAP("PLT_RST_L",39);
    RETURN_CH_MAP("PM_RSMRST_L",40);
    RETURN_CH_MAP("SOC_SWD_MUX_SEL_PCH",43);
    RETURN_CH_MAP("SOC_DOCK_CONNECT",44);
    RETURN_CH_MAP("SYS_DETECT",45);
    RETURN_CH_MAP("SOC_DFU_STATUS",46);
    RETURN_CH_MAP("SOC_SWD_MUX_SEL",47);
    return 99; // invalid
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - Log method -
- (void)logInfo:(NSString *)msg slot:(int)slot
{
    NSString *paragraph = [NSString stringWithFormat:@"[SLOT %d]: %@\n",slot,msg];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
    [attributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
    
    NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LogView textStorage] appendAttributedString:as];
        [self scrollToBottom];
    });
}
- (void)logError:(NSString *)msg slot:(int)slot
{
    NSString *paragraph = [NSString stringWithFormat:@"[SLOT %d]: %@\n",slot,msg];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
    [attributes setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
    
    NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LogView textStorage] appendAttributedString:as];
        [self scrollToBottom];
    });

}
- (void)scrollToBottom
{
    NSScrollView *scrollView = [LogView enclosingScrollView];
    NSPoint newScrollOrigin;
    
    if ([[scrollView documentView] isFlipped])
        newScrollOrigin = NSMakePoint(0.0F, NSMaxY([[scrollView documentView] frame]));
    else
        newScrollOrigin = NSMakePoint(0.0F, 0.0F);
    
    [[scrollView documentView] scrollPoint:newScrollOrigin];
}
-(NSDictionary *)commandListArray
{
    if (!_commandListArray) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"commandList" ofType:@"plist"];
        _commandListArray = [NSDictionary dictionaryWithContentsOfFile:path];
        
    }
    
    return _commandListArray;
}


#pragma mark -  comboBox delegate -
-(void)controlTextDidChange:(NSNotification *)obj
{
    id object = [obj object];
    [object setCompletes:YES];
    
}
#pragma mark -  comboBox dataSource -
-(NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox
{
    NSString *categoryString = category.selectedItem.title;
    NSArray *cateCmdArray = [self.commandListArray objectForKey:categoryString];
    return cateCmdArray.count;
    
}
- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    NSString *categoryString = category.selectedItem.title;
    NSArray *cateCmdArray = [self.commandListArray objectForKey:categoryString];
    return cateCmdArray[index];
    
    
}
- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)string
{
    NSString *categoryString = category.selectedItem.title;
    NSArray *cateCmdArray = [self.commandListArray objectForKey:categoryString];
    return [cateCmdArray indexOfObject:string];
    
}

@end
