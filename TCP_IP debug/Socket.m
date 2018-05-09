//
//  Socket.m
//  TCP_IP debug
//
//  Created by BP on 03/03/2017.
//  Copyright © 2017 B&P. All rights reserved.
//

#import "Socket.h"
#include <sys/socket.h>
#import "termios.h"
#include <netdb.h>
#include <arpa/inet.h>
#include <stdio.h>
@implementation Socket


#pragma mark--Connect Instructions By Ethernet
-(BOOL)ConnectSocketIP:(NSString *)IP andPort:(int)port;
{
    if (port == 4502) {
        struct protoent *ppe;
        ppe=getprotobyname("tcp");
        listenSocket=socket(AF_INET,SOCK_STREAM,ppe->p_proto);  ///----obtain  the socket handle .
        NSLog(@"Ethernet socket listenSocket=%d",listenSocket);
        NSString *uiInfo = @"Fail,";
        if (listenSocket==-1) //---obtain socket handle fail
        {
            uiInfo = @"Fail, obtain socket handle fail, listenSocket=";
            NSString *tmp = [NSString stringWithFormat:@"%d",listenSocket];
            uiInfo = [uiInfo stringByAppendingString:tmp];
            
            return false;
        }
        
        //    NSString *strIP=@"169.254.4.10";
        NSString *strIP=IP;
        int iPortID =port;
        //int iPortID = [[ScriptParse getValueFromSummary:@"EthernetPort"] intValue];
        
        struct sockaddr_in daddr;
        memset((void *)&daddr,0,sizeof(daddr));
        daddr.sin_family=AF_INET;
        daddr.sin_port=htons(iPortID);   ////convert port
        daddr.sin_addr.s_addr=inet_addr([strIP cStringUsingEncoding:NSASCIIStringEncoding]) ; ///connect address
        int err ;
        err = connect(listenSocket,(struct sockaddr *)&daddr,sizeof(daddr)) ;
        ///....................................................
        NSLog(@"Ethernet connect err=%d",err);
        if (err!=0) ///connected fail .
        {
            //NSString *tmp = [NSString stringWithFormat:@"%d",err];
            return false;
        }
        else
        {
            
            //==configure port===============//
            //        int iTimeOut = 5000 ;
            
            //            fcntl(listenSocket, F_SETFL,O_NONBLOCK);//set nonblock enable
            struct timeval timeout={2,0};
            int ret = setsockopt(listenSocket,SOL_SOCKET,SO_RCVTIMEO,(const char*)&timeout,sizeof(timeout)) ;
            if (ret != 0) {
                NSLog(@"set Rcv timeout fail");
            }
            ret = setsockopt(listenSocket,SOL_SOCKET,SO_SNDTIMEO,(const char*)&timeout,sizeof(timeout)) ;
            if (ret != 0) {
                NSLog(@"set SND timeout fail");
            }
            int iAddr = 1 ;
            setsockopt(listenSocket,SOL_SOCKET,SO_REUSEADDR,(char*)&iAddr,sizeof(int)) ;
        }
        
        return true;
    }
    struct protoent *ppe;
    ppe=getprotobyname("tcp");
    listenSocket=socket(AF_INET,SOCK_STREAM,ppe->p_proto);  ///----obtain  the socket handle .
    NSLog(@"Ethernet socket listenSocket=%d",listenSocket);
    NSString *uiInfo = @"Fail,";
    if (listenSocket==-1) //---obtain socket handle fail
    {
        uiInfo = @"Fail, obtain socket handle fail, listenSocket=";
        NSString *tmp = [NSString stringWithFormat:@"%d",listenSocket];
        uiInfo = [uiInfo stringByAppendingString:tmp];
        
        return false;
    }
    
    //    NSString *strIP=@"169.254.4.10";
    NSString *strIP=IP;
    int iPortID =port;
    //int iPortID = [[ScriptParse getValueFromSummary:@"EthernetPort"] intValue];
    
    struct sockaddr_in daddr;
    memset((void *)&daddr,0,sizeof(daddr));
    daddr.sin_family=AF_INET;
    daddr.sin_port=htons(iPortID);   ////convert port
    daddr.sin_addr.s_addr=inet_addr([strIP cStringUsingEncoding:NSASCIIStringEncoding]) ; ///connect address
    int err ;
    err = connect(listenSocket,(struct sockaddr *)&daddr,sizeof(daddr)) ;
    ///....................................................
    NSLog(@"Ethernet connect err=%d",err);
    if (err!=0) ///connected fail .
    {
        //NSString *tmp = [NSString stringWithFormat:@"%d",err];
        return false;
    }
    else
    {
        
        //==configure port===============//
        //        int iTimeOut = 5000 ;
        
        //        fcntl(listenSocket, F_SETFL,O_NONBLOCK);//set nonblock enable
        struct timeval timeout={3,0};
        int ret = setsockopt(listenSocket,SOL_SOCKET,SO_RCVTIMEO,(const char*)&timeout,sizeof(timeout)) ;
        if (ret != 0) {
            NSLog(@"set Rcv timeout fail");
        }
        ret = setsockopt(listenSocket,SOL_SOCKET,SO_SNDTIMEO,(const char*)&timeout,sizeof(timeout)) ;
        if (ret != 0) {
            NSLog(@"set SND timeout fail");
        }
        int iAddr = 1 ;
        setsockopt(listenSocket,SOL_SOCKET,SO_REUSEADDR,(char*)&iAddr,sizeof(int)) ;
    }
    return true;
}

-(BOOL)ConnectSocketIPUDP:(NSString *)IP andPort:(int)port;
{
  
    struct protoent *ppe;
    ppe=getprotobyname("udp");
    listenSocket=socket(AF_INET,SOCK_DGRAM,ppe->p_proto);  ///----obtain  the socket handle .
    NSLog(@"Ethernet socket listenSocket=%d",listenSocket);
    NSString *uiInfo = @"Fail,";
    if (listenSocket==-1) //---obtain socket handle fail
    {
        uiInfo = @"Fail, obtain socket handle fail, listenSocket=";
        NSString *tmp = [NSString stringWithFormat:@"%d",listenSocket];
        uiInfo = [uiInfo stringByAppendingString:tmp];
        
        return false;
    }
    
    //    NSString *strIP=@"169.254.4.10";
    NSString *strIP=IP;
    int iPortID =port;
    //int iPortID = [[ScriptParse getValueFromSummary:@"EthernetPort"] intValue];
    
    struct sockaddr_in daddr;
    memset((void *)&daddr,0,sizeof(daddr));
    daddr.sin_family=AF_INET;
    daddr.sin_port=htons(iPortID);   ////convert port
    daddr.sin_addr.s_addr=inet_addr([strIP cStringUsingEncoding:NSASCIIStringEncoding]) ; ///connect address
    int err ;
    err = connect(listenSocket,(struct sockaddr *)&daddr,sizeof(daddr)) ;
    ///....................................................
    NSLog(@"Ethernet connect err=%d",err);
    if (err!=0) ///connected fail .
    {
        //NSString *tmp = [NSString stringWithFormat:@"%d",err];
        return false;
    }
    else
    {
        struct timeval timeout={3,0};
        int ret = setsockopt(listenSocket,SOL_SOCKET,SO_RCVTIMEO,(const char*)&timeout,sizeof(timeout)) ;
        if (ret != 0) {
            NSLog(@"set Rcv timeout fail");
        }
        ret = setsockopt(listenSocket,SOL_SOCKET,SO_SNDTIMEO,(const char*)&timeout,sizeof(timeout)) ;
        if (ret != 0) {
            NSLog(@"set SND timeout fail");
        }
        int iAddr = 1 ;
        setsockopt(listenSocket,SOL_SOCKET,SO_REUSEADDR,(char*)&iAddr,sizeof(int)) ;
    }
    return true;
}

-(BOOL)DisconnectBySocket;
{
    //
    //fflush(stdin);
    if (listenSocket < 0) {
        return false;
    }
    shutdown(listenSocket,0) ;////wait end the data sended.
    close(listenSocket);
    listenSocket = -1;
    return true;
    
}

-(BOOL)WriteCMDBySocket:(NSString *)cmd;
{
    
    [self clearSocketBuffer];
    
    NSString *cmdtr = [NSString stringWithFormat:@"%@\r\n" ,cmd];
    //[NSThread sleepForTimeInterval:0.01];
    NSLog(@"write cmd:%@",cmdtr);
    BOOL wCMD=[self WriteInstructionBySocket:cmdtr];
    
    
    //strcpy(stringinput,[aa UTF8String]);
    if (wCMD) {
        NSLog(@"Pass");
        return true;
    }
    else{
        NSLog(@"socket fail");
        return false;
    }
    
}
-(BOOL)WriteInstructionBySocket:(NSString *)cmd;
{
    //NSString *uiInfo = @"Fail,";
    long wordsWritten;
    //char *cData= "SYSTem:COMMunicate:ENABle ON,LAN\n" ;
    //cmd = @"SYST:VERS?\n";
    //cmd = @"MEASure:FRESistance? 5,0.001\n";
    //cmd = @"MEASure:FRESistance?\n";
    
    
    const char *cData= [cmd UTF8String];
    long sendLen = strlen(cData);
    //NSLog(@"Ethernet send len=%ld \n",sendLen);
    //memset(cData,'\0',[sendBuffer length]+1) ;
    //[sendBuffer getBytes:cData] ;
    //uiInfo = [NSString stringWithFormat:@"\n      [%@]Send:%@",[[NSCalendarDate date] description],cmd];
    //NSLog(@"Ethernet send listenSocket=%d \n",listenSocket);
    if (cData == nil || listenSocket <= 0) {
        return false;
    }
    
    wordsWritten = send(listenSocket,cData,sendLen,0) ;
    //NSLog(@"Ethernet send return len=%d \n",wordsWritten);
    
    if(wordsWritten > 0)
    {
        NSLog(@"%@",[NSString stringWithFormat: @"[CMD Send] %@",cmd]);
        return true;
    }
    else
    {
        NSLog(@"%@",[NSString stringWithFormat: @"[CMD Send fail] %@",cmd]);
        return false;
    }
    
    
}

-(NSString *)ReadstrBySocket;
{
    
    NSString *subString = [self ReadBySocket];
    if (subString == nil) {
        NSLog(@"recieve nothing");
    }
    NSLog(@"got the message %@",subString);
    return subString;
}
-(NSString *)ReadBySocket;
{
    NSString *bufferString = @"";
    
    do {
        long wordsRead = 0;
        char tempRecBuffer[256] ;
        memset(tempRecBuffer, 0, 256);
        wordsRead = recv(listenSocket,tempRecBuffer,255,0) ; //received socket data
        if (wordsRead <= 0) //read available data
        {
            NSLog(@"no data to recv");
            break;
        }
        
        //    for (int i=0; i<wordsRead; i++) {
        //        printf("%02x",tempRecBuffer[i]);
        //    }
        
        NSString *ReceiveData = [NSString stringWithUTF8String:tempRecBuffer];
        NSLog(@"Ethernet socket comm received nsstringReceiveData=%@ \n",ReceiveData);
        bufferString = [bufferString stringByAppendingString:ReceiveData];
        NSLog(@"bufferString = %@",bufferString);
    } while (![bufferString containsString:@"$"] && bufferString != nil );
    
    
    return bufferString;
    
}

-(NSString *)sendCMDBySocket:(NSString *)cmd WithTime:(NSNumber *)timeout;
{
    NSString *readStr = nil;
    if([self WriteCMDBySocket:cmd] == true){
        readStr = [self ReadStrBySocketWithTime:timeout];
    }
    return readStr;
}

-(NSString *)ReadStrBySocketWithTime:(NSNumber *)timeout;
{
    NSString *bufferString = [[NSString alloc]init];
    if (!timeout)
    {
        // If no timeout value is specified, just set it to 10s.
        timeout = [NSNumber numberWithInteger:10];
    }
    NSTimeInterval timeStart = [[NSDate date] timeIntervalSince1970];
    do {
        long wordsRead = 0;
        char tempRecBuffer[1024] ;
        memset(tempRecBuffer, 0, 1024);
        wordsRead = recv(listenSocket,tempRecBuffer,1023,0) ; //received socket data
        if (wordsRead <= 0) //read available data
        {
            [NSThread sleepForTimeInterval:1];
            continue;
        }
        NSString *ReceiveData = [NSString stringWithUTF8String:tempRecBuffer];
        bufferString = [bufferString stringByAppendingString:ReceiveData];
    } while (![bufferString containsString:@"\r"] && ([[NSDate date] timeIntervalSince1970] - timeStart) < timeout.doubleValue );
    return bufferString;
    
}
-(NSString *)ReadStrBySocketWithTime:(NSNumber *)timeout frameTerminator:(NSString *)frameTerminator;
{
    NSString *bufferString = [[NSString alloc]init];
    [NSThread sleepForTimeInterval:0.02];
    if (!timeout)
    {
        timeout = [NSNumber numberWithInteger:10];
    }
    NSTimeInterval timeStart = [[NSDate date] timeIntervalSince1970];
    do {
        long wordsRead = 0;
        char tempRecBuffer[1024] ;
        memset(tempRecBuffer, 0, 1024);
        wordsRead = recv(listenSocket,tempRecBuffer,1023,0) ; //received socket data
        if (wordsRead <= 0) //read available data
        {
            break;
        }
        NSString *ReceiveData = [NSString stringWithUTF8String:tempRecBuffer];
        bufferString = [bufferString stringByAppendingString:ReceiveData];
    } while (![bufferString containsString:frameTerminator] && ([[NSDate date] timeIntervalSince1970] - timeStart) < timeout.doubleValue );
    return bufferString;
}

-(void)clearSocketBuffer;
{
    if(listenSocket <= 0) {
        return;
    }
    long wordsRead = 0;
    do {
        char tempRecBuffer[256] ;
        memset(tempRecBuffer, 0, 256);
        wordsRead = recv(listenSocket,tempRecBuffer,255,0);
    } while (wordsRead > 0);
}
-(void)ReadFeedBackBySocket:(NSDictionary *)context;
{
    //sleep(1);
    
    NSString *min = [context objectForKey:@"MinValue"];
    NSString *max = [context objectForKey:@"MaxValue"];
    NSString *expectStr = [context objectForKey:@"ExpectStr"];
    
    NSString *subString = [self ReadInstructionBySocket:expectStr];
    
    if (subString == nil) {
        subString = @"No Value";
        NSLog(@"No Value");
    }
    
    
    //modify the value,20160129 by joe
    //+9.48317049E-02
    
    
    
    
    if(((min==nil||[min length]<=0)?1:([subString floatValue]*1000 >=[min floatValue])) &&
       ((max==nil||[max length]<=0)?1:([subString floatValue]*1000 <=[max floatValue])))
    {
        subString = [NSString stringWithFormat:@"%.2lf",[subString floatValue]*1000];
        
        NSLog(@"pass with string:%@",subString);
    }
    else
    {
        
        if ([subString floatValue]*1000 < 10000000000) {
            subString = [NSString stringWithFormat:@"%.2lf",[subString floatValue]*1000];
        }
        
        if ([subString floatValue]*1000 >= 10000000000) {
            subString = [NSString stringWithFormat:@"%.2lf",[subString floatValue]];
            subString = [NSString stringWithFormat:@"%.1e",[subString floatValue]];
            
            
        }
        
        NSLog(@"fail with string:%@",subString);
    }
    
    
}
-(NSString *)ReadInstructionBySocket:(NSString *)strExpect;
{
    
    
    long wordsRead = 0;
    char tempRecBuffer[256] ;
    memset(tempRecBuffer, 0, 256);
    wordsRead = recv(listenSocket,tempRecBuffer,255,0) ; //received socket data
    if (wordsRead <= 0) //read available data
    {
        NSLog(@"[CMD no Received]");
        return nil;
    }
    
    //for (int i=0; i<wordsRead; i++) {
    //    printf("%02x",tempRecBuffer[i]);
    //}
    
    NSString* nsstringReceiveData = [NSString stringWithUTF8String:tempRecBuffer];
    //NSLog(@"Ethernet socket comm received nsstringReceiveData=%@ \n",nsstringReceiveData);
    
    
    
    
    NSString *databuffer = nsstringReceiveData;
    
    NSString *logContent = [NSString stringWithFormat:@"[CMD Received] %@",databuffer];
    NSLog(@"%@",logContent);
    
    
    NSString *value = nil;
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:strExpect options:NSRegularExpressionCaseInsensitive error:nil];
    
    @try {
        NSArray *matches =[ regExp matchesInString:databuffer options:0 range:NSMakeRange(0, [databuffer length])];
        
        for (NSTextCheckingResult *match in matches) {
            NSRange firstHalfRange = [match rangeAtIndex:0];
            value = [databuffer substringWithRange:firstHalfRange];
            
            break;
        }
    }
    @catch (NSException *exception) {
        
        NSLog(@"<Exception> getStringWithPattern");
    }
    
    //NSLog(@"value:%@",value);
    
    
    value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
    value = [value stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    value = [value stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    //NSString *intStrValue = [NSString stringWithFormat:@"%f",[value floatValue]*1000];
    //return intStrValue;
    return value;
    
    //NSString *intStrValue = [NSString stringWithFormat:@"%f",[value floatValue]];
    
    //return intStrValue;
    
}
@end
