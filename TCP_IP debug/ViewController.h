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
    
    __weak IBOutlet NSButton *powerOnSelected;
    __weak IBOutlet NSButton *powerOffSelected;
    __weak IBOutlet NSButton *PCHSelected;
    __weak IBOutlet NSButton *ADCSelected;
    __weak IBOutlet NSButton *panda;
    __weak IBOutlet NSButton *DFUSelected;
    
    
    __weak IBOutlet NSTextField *pandaValue;
    __weak IBOutlet NSTextField *pchValue;
    
//    IBOutlet NSButton *connect;
//    IBOutlet NSButton *Send;
//    IBOutlet NSTextField *ShowFeedBack;
    BOOL didConnectionOK;
    IBOutlet NSTextView *LogView;
    __weak IBOutlet NSButton *powerOnCheck;
}
@property (nonatomic,strong) NSDictionary *commandListArray;

//-(IBAction)SendCmd:(id)sender;

@end

