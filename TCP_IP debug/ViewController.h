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
    
    NSDictionary * commandDic;
    
    IBOutlet NSComboBox *cmdCombox;
    IBOutlet NSPopUpButton *category;
    
    IBOutlet NSButton *connect;
    IBOutlet NSButton *Send;
    IBOutlet NSTextField *ShowFeedBack;
    BOOL didConnectionOK;
    IBOutlet NSTextView *LogView;
}
@property (nonatomic,strong) NSDictionary *commandListArray;

//-(IBAction)SendCmd:(id)sender;

@end

