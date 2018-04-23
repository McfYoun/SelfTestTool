//
//  ViewController.h
//  TCP_IP debug
//
//  Created by BP on 03/03/2017.
//  Copyright © 2017 B&P. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Socket.h"
@interface ViewController : NSViewController <NSComboBoxDelegate,NSComboBoxDataSource>
{
    Socket *socket;
    IBOutlet NSTextField *IPAddress;
    
    IBOutlet NSTextField *portNum;
    
    IBOutlet NSTextField *cmd;
    
    IBOutlet NSComboBox *cmdCombox;
    IBOutlet NSPopUpButton *category;
    
    IBOutlet NSButton *connect;
    IBOutlet NSButton *Send;
    IBOutlet NSTextField *ShowFeedBack;
    BOOL didConnectionOK;
    IBOutlet NSTextView *LogView;
}
@property (nonatomic,strong) NSDictionary *commandListArray;

@property (weak) IBOutlet NSTextField *SetIPTextField;
@property (weak) IBOutlet NSTextField *YieldTextField;

-(IBAction)SendCmd:(id)sender;
-(IBAction)getTCPconnect:(id)sender;
-(IBAction)disTCPconnect:(id)sender;

@end

