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
