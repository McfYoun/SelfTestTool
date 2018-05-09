//
//  ErrorCodes.m
//  FixtureService
//
//  Created by Darren Mistica on 2/17/17.
//  Copyright © 2017 Darren Mistica. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ErrorCodes.h"

@implementation ErrorCodes

- (NSString *)errorCodeString:(int)code
{
    NSString *description;
    NSDictionary *errorCodeTable;
    
    errorCodeTable = @{
                        @     0 : @"No Errors",
                        @    -1 : @"Command Not Supported by Fixture Service",
                        @    -2 : @"Unknown Error Reported",
                        @    -4 : @"Slot-ID Does not Exist in info.plist",
                        @ -1000 : @"Failed to Connect to Fixture Control Card at [IP]",
                        @ -1001 : @"Failed to Set Default GPIOs",
                        @ -1002 : @"Failed to Initialize I2C (If Applicable)",
                        @ -1003 : @"Failed to Initialize UART",
                        @ -1004 : @"Failed to Initialize ADC Channels (If Applicable)",
                        @ -1005 : @"Pogo Pins have been actuated beyond <maxActuations>",
                        @ -1006 : @"Connection Details Missing in info.plist",
                        @ -1025 : @"Drawer Was Not Closed: Sensor(s) [sensor(s) location(s)] reported 0",
                        @ -1026 : @"Pressure Plate Could Not Actuate: Sensor(s) [sensor(s) location(s)] reported 0",
                        @ -1027 : @"No MLB Found in Slot: Sensor [sensor location] reported 0",
                        @ -1050 : @"Drawer Could Not Open: Sensor(s) [sensor(s) location(s)] reported 0",
                        @ -1051 : @"Pressure Plate Could Not Lift: Sensor(s) [sensor(s) location(s)] reported 0",
                        @ -1075 : @"Could not Lock Fixture",
                        @ -1076 : @"Could not Unlock Fixture",
                        @ -1100 : @"Carrier is missing DUT Serial Number",
                        @ -1125 : @"USB Restore Location not found in system_profiler",
                        @ -1150 : @"UART Path Does Not Exist on Carrier",
                        @ -1175 : @"Missing UART Path",
                        @ -1176 : @"Missing USB Restore Location",
                        @ -1200 : @"No data Retrieved from EEPROM",
                        @ -1201 : @"Fixture Firmware Version is Incorrect",
                        @ -1202 : @"Unable to set Attribute Data",
                        @ -1225 : @"ADC Signal Name Doesn’t Exist in Mapping Table",
                        @ -1226 : @"NULL Data Retrieved from ADC Read",
                        @ -1227 : @"Measured Value is not Within Limits",
                        @ -1250 : @"GPIO Signal Name Doesn’t Exist in Mapping Table",
                        @ -1251 : @"NULL Data Retrieved from GPIO Read",
                        @ -1252 : @"Checked Data Doesn’t Match GPIO Write",
                        @ -1275 : @"Unable to Connect to Port",
                        @ -1276 : @"Invalid Baud Rate",
                        @ -1277 : @"Invalid Parity",
                        @ -1278 : @"Invalid Stop Bits",
                        @ -1279 : @"Cannot Write to Log File",
                        @ -1300 : @"No Connection Open on the Specified Port",
                        @ -1302 : @"Unable to Close UART Connection",
                        @ -1303 : @"Couldn’t Find Frame Terminator",
                        @ -1325 : @"Could not Configure I2C Bus",
                        @ -1326 : @"Unable to Read from I2C Bus",
                        @ -1327 : @"Could not Write to I2C Bus",
                        @ -1350 : @"Unable to set LED color",
                        @ -1375 : @"Couldn’t set DFU pin to high",
                        @ -1376 : @"DUT did not power up",
                        @ -1377 : @"DUT did not show up in DFU at the board level",
                        @ -1378 : @"Couldn't set DFU pin to Low",
                        @ -1400 : @"DUT is not Powered Up",
                        @ -1401 : @"DUT is not Powered Down",
                        @ -1425 : @"DUT did not gracefully power down",
                        @ -1426 : @"PSU did not respond to GPIO change, DUT still powered up",
                        @ -1427 : @"DUT did not Boot After Power Cycling",
                        @ -1450 : @"Error Setting Power Button High",
                        @ -1451 : @"Error Setting Power Button Low",
                        @ -1452 : @"DUT did not Force Shutdown Through Power Button",
                        @ -1475 : @"Error Connecting Battery",
                        @ -1476 : @"Error Disconnecting Battery",
                        @ -1500 : @"Unable to Actuate: Sensor(s) [sensor(s) location(s)] reported 0",
                        @ -1501 : @"Expected 1, Sensor Reported 0",
                        @ -1502 : @"Expected 0, Sensor Reported 1",
                        @ -1525 : @"Unable to Teardown",
                        @ -9999 : @"Error Code was Never Set! Did test execute?",
                              //add aceOtpErrorCode
                        @   100 : @"PPDCIN too low at value",
                        @   101 : @"first read retry over limit",
                        @   102 : @"ACE in wrong operating mode buf",
                        @   103 : @"ACE not programable buf",
                        @   104 : @"failed to enable programming",
                        @   105 : @"ace not blank",
                        @   106 : @"ace has programmed with wrong value",
                        @   107 : @"failed to program, buf",
                        @   108 : @"failed to write err buf[1]",
                        @   109 : @"write failed, replace ACE",
                        @   120 : @"no,power switch retry",
                        @   110 : @"command send error"
                    };
    
    description = [errorCodeTable objectForKey:[NSNumber numberWithInt: code]];
    return description && [description length] ? description : @"Invalid Error Code!";
}

@end
