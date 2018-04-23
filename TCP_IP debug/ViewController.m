//
//  ViewController.m
//  TCP_IP debug
//
//  Created by BP on 03/03/2017.
//  Copyright © 2017 B&P. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self->socket = [[Socket alloc]init];
    self->socket->listenSocket = -1;
    [self->cmdCombox setDelegate:self];
    [self->cmdCombox setDataSource:self];
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
-(IBAction)SendCmd:(id)sender;
{
    NSString *cmdstr = [self->cmdCombox stringValue];
    if (didConnectionOK == true) {
//        [self->socket clearSocketBuffer];
        if([self->socket WriteCMDBySocket:cmdstr] == true){
//            [NSThread sleepForTimeInterval:0.2];
            NSString *feedbackStr = [self->socket ReadstrBySocket];
            [self logInfo:[NSString stringWithFormat:@"%@",feedbackStr]];
        }
        else{
            
            [self logError:[NSString stringWithFormat:@"write commad:%@ fail !",cmdstr]];
        }
    }else
    {
         [self logError:[NSString stringWithFormat:@"socket connection fail !"]];
        
    }
}

//SET_IP_ADDR 10.0.100.11$

-(IBAction)getTCPconnect:(id)sender;
{
    
    didConnectionOK = false;
    NSString *ip = [self->IPAddress stringValue];
    int port = [self->portNum intValue];
    
    if ([self->socket ConnectSocketIP:ip andPort:port] == true) {
        didConnectionOK = true;
        [self logInfo:[NSString stringWithFormat:@"Connection with %@:%d OK",ip,port]];
    }else
    {
        didConnectionOK = false;
        [self logError:[NSString stringWithFormat:@"Connection with %@:%d fail",ip,port]];
    }
}
- (IBAction)SETIPBTN:(id)sender {
    NSString * FInalIP = _SetIPTextField.stringValue;
    
    NSString * ipCmd = [NSString stringWithFormat:@"SET_IP_ADDR 10.0.100.%@$",FInalIP];
    if (FInalIP.length != 2) {
        [self logError:[NSString stringWithFormat:@"write commad:%@ fail ! \n should import 11 or 21 or 31 or 41",ipCmd]];
    }
    
    if (didConnectionOK == true) {
        //[self->socket clearSocketBuffer];
        if([self->socket WriteCMDBySocket:ipCmd] == true){
            NSString *feedbackStr = [self->socket ReadstrBySocket];
            [self logInfo:[NSString stringWithFormat:@"%@",feedbackStr]];
        }
        else{
            
            [self logError:[NSString stringWithFormat:@"write commad:%@ fail !",cmd]];
        }
    }else
    {
        [self logError:[NSString stringWithFormat:@"socket connection fail !"]];
        
    }
}

- (IBAction)YieldBTN:(id)sender {
    NSString * finalString = [[NSString alloc] initWithFormat:@"find /vault/Atlas/Units/Archive -mtime -%@ | grep tgz",_YieldTextField.stringValue];
    [self ActionTheCommand:finalString];
}

- (void)ActionTheCommand:(NSString *)finalString
{
    // 创建
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(ConnectTerminal:) object:finalString];
    // 启动
    [thread start];
    return;
}

- (void)ConnectTerminal:(NSString *)FFinalString
{
    NSTask *task;
    task = [[NSTask alloc] init];
    
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:@"-c",FFinalString,nil];
    [task setArguments: arguments];
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data
                                   encoding: NSUTF8StringEncoding];
    //    NSLog (@"got\n%@", string);
    [self analyseString:string];
    //    [[NSRunLoop currentRunLoop] run];
}

- (void)analyseString:(NSString *)resultStr
{
    if (!resultStr) {
        return;
    }
    NSArray * resultArr = [resultStr componentsSeparatedByString:@"\n"];
    
    NSMutableArray * slot1Arr = [[NSMutableArray alloc] init];
    NSMutableArray * slot2Arr = [[NSMutableArray alloc] init];
    NSMutableArray * slot3Arr = [[NSMutableArray alloc] init];
    NSMutableArray * slot4Arr = [[NSMutableArray alloc] init];
    
    NSString * totalresult = [[NSString alloc] init];
    NSString * slot1result = [[NSString alloc] init];
    NSString * slot2result = [[NSString alloc] init];
    NSString * slot3result = [[NSString alloc] init];
    NSString * slot4result = [[NSString alloc] init];
    
    float passCount = 0;
    
    for (NSString * totalcountstr in resultArr) {
        if ([totalcountstr containsString:@"Pass"]) {
            passCount ++;
        }
    }
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self logInfo:@"NA"];
//    });
    
    
    totalresult = [[NSString alloc] initWithFormat:@"total,input_%lu,Pass_%ld,Yield_%0.2f",resultArr.count - 1,(long)passCount,passCount/(resultArr.count - 1)];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self logInfo:totalresult];
    });
    
    passCount = 0;
    
    for (NSString * str in resultArr) {
        if ([str containsString:@"Slot-1"]) {
            [slot1Arr addObject:str];
        }
        if ([str containsString:@"Slot-2"]) {
            [slot2Arr addObject:str];
        }
        if ([str containsString:@"Slot-3"]) {
            [slot3Arr addObject:str];
        }
        if ([str containsString:@"Slot-4"]) {
            [slot4Arr addObject:str];
        }
    }
    
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self logInfo:totalresult];
//    });
    
    
    if (slot1Arr.count > 0) {
        for (NSString * slotstr in slot1Arr) {
            if ([slotstr containsString:@"Passed"]) {
                passCount ++;
            }
        }
        slot1result = [NSString stringWithFormat:@"slot1,input_%lu,Pass_%ld,Yield_%0.2f",(unsigned long)slot1Arr.count,(long)passCount,passCount/slot1Arr.count];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self logInfo:slot1result];
        });
    }
    
    
    passCount = 0;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [_slot2Result setStringValue:@"NA"];
//    });
    if (slot2Arr.count > 0) {
        for (NSString * slotstr in slot2Arr) {
            if ([slotstr containsString:@"Passed"]) {
                passCount ++;
            }
        }
        slot2result = [NSString stringWithFormat:@"slot2,input_%lu,Pass_%ld,Yield_%0.2f",(unsigned long)slot2Arr.count,(long)passCount,passCount/slot2Arr.count];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self logInfo:slot2result];
        });
        
    }
    
    passCount = 0;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [_slot3Result setStringValue:@"NA"];
//    });
    if (slot3Arr.count > 0) {
        for (NSString * slotstr in slot3Arr) {
            if ([slotstr containsString:@"Passed"]) {
                passCount ++;
            }
        }
        slot3result = [NSString stringWithFormat:@"slot3,input_%lu,Pass_%ld,Yield_%0.2f",(unsigned long)slot3Arr.count,(long)passCount,passCount/slot3Arr.count];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self logInfo:slot3result];
        });
        
    }
    
    passCount = 0;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [_slot4Result setStringValue:@"NA"];
//    });
    if (slot4Arr.count > 0) {
        for (NSString * slotstr in slot4Arr) {
            if ([slotstr containsString:@"Passed"]) {
                passCount ++;
            }
        }
        slot4result = [NSString stringWithFormat:@"slot4,input_%lu,Pass_%ld,Yield_%0.2f",(unsigned long)slot4Arr.count,(long)passCount,passCount/slot4Arr.count];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self logInfo:slot4result];
        });
    }
}


-(IBAction)disTCPconnect:(id)sender;
{
    NSString *ip = [self->IPAddress stringValue];
    int port = [self->portNum intValue];
    
    if([self->socket DisconnectBySocket] == true)
    {
        [self logInfo:[NSString stringWithFormat:@"Disconnect with %@:%d OK",ip,port]];
    }else
    {
        [self logInfo:@"Don't have the socket,don't need to disconnect"];
    }
}

- (IBAction)MCU_RESET:(id)sender {
    
    NSString *ip = [self->IPAddress stringValue];
    int port = 28888;
    //CMD:  CNVT_RESET_MCU
    if ([self->socket ConnectSocketIPUDP:ip andPort:port] == true){
        didConnectionOK = true;
        [self logInfo:[NSString stringWithFormat:@"Connection with %@:%d OK",ip,port]];
    }else
    {
        didConnectionOK = false;
        [self logError:[NSString stringWithFormat:@"Connection with %@:%d fail",ip,port]];
    }
    NSString *cmdstr = @"CNVT_RESET_MCU";
    if (didConnectionOK == true) {
        //        [self->socket clearSocketBuffer];
        if([self->socket WriteCMDBySocket:cmdstr] == true){
            NSString *feedbackStr = [self->socket ReadstrBySocket];
            [self logInfo:[NSString stringWithFormat:@"%@",feedbackStr]];
        }
        else{
            
            [self logError:[NSString stringWithFormat:@"write commad:%@ fail !",cmdstr]];
        }
    }else
    {
        [self logError:[NSString stringWithFormat:@"socket connection fail !"]];
    }
}

#pragma mark - Log method -
- (void)logInfo:(NSString *)msg
{
    NSString *paragraph = [NSString stringWithFormat:@"> %@\n", msg];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
    [attributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
    
    NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
    
    [[LogView textStorage] appendAttributedString:as];
    [self scrollToBottom];
}
- (void)logError:(NSString *)msg
{
    NSString *paragraph = [NSString stringWithFormat:@"> %@\n", msg];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
    [attributes setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
    
    NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
    
    [[LogView textStorage] appendAttributedString:as];
    [self scrollToBottom];
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
