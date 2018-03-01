//
//  Socket.h
//  TCP_IP debug
//
//  Created by BP on 03/03/2017.
//  Copyright © 2017 B&P. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Socket : NSObject
{
    @public
    int listenSocket;
}

-(BOOL)ConnectSocketIP:(NSString *)IP andPort:(int)port;
-(BOOL)ConnectSocketIPUDP:(NSString *)IP andPort:(int)port;
-(BOOL)DisconnectBySocket;
-(BOOL)WriteCMDBySocket:(NSString *)cmd;
-(BOOL)WriteInstructionBySocket:(NSString *)cmd;
-(NSString *)ReadstrBySocket;
-(NSString *)ReadBySocket;
-(void)ReadFeedBackBySocket:(NSDictionary *)context;
-(NSString *)ReadInstructionBySocket:(NSString *)strExpect;
-(void)clearSocketBuffer;
@end
