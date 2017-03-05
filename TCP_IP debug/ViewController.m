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

    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
-(IBAction)SendCmd:(id)sender;
{
    NSString *cmdstr = [self->cmd stringValue];
    if (didConnectionOK == true) {
        
        if([self->socket WriteCMDBySocket:cmdstr] == true){
            [NSThread sleepForTimeInterval:0.2];
            NSString *feedbackStr = [self->socket ReadstrBySocket];
            [self logInfo:[NSString stringWithFormat:@"%@",feedbackStr]];
        }
        else{
            
            [self logInfo:[NSString stringWithFormat:@"write commad:%@ fail !",cmdstr]];
        }
    }else
    {
         [self logInfo:[NSString stringWithFormat:@"socket connection fail !"]];
        
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
        [self logInfo:[NSString stringWithFormat:@"Connection with %@:%d fail",ip,port]];
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
@end
