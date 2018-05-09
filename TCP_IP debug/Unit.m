//
//  Unit.m
//  FixtureService
//
//  Created by Darren Mistica on 2/17/17.
//  Copyright © 2017 Darren Mistica. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Unit.h"
#import "ErrorCodes.h"


@implementation Unit
{
    NSDictionary *_fixtureMapping;
    NSMutableDictionary *_results;
}

- (id)initWithContext:(NSDictionary *)context
{
    self = [super init];
    
    NSDictionary *template = @{
                                kCode:@"",
                                kFailureMessage:@""
                              };
    _socket = [context valueForKey:@"socket"];
    _logpath = [context valueForKey:@"logpath"];
    _slot = [[context valueForKey:@"slotId"] intValue];
    _command = [context valueForKey:@"command"];
    _parameters = [context objectForKey:@"parameters"];
    _results = [NSMutableDictionary dictionaryWithDictionary:template];
    
    [self setCode:kDefaultCode];

    return self;
}

- (void)setCode:(int) code
{
    [_results setValue:[NSNumber numberWithInt: code] forKey:kCode];
    [_results setValue:[[ErrorCodes alloc] errorCodeString:code] forKey:kFailureMessage];
}

- (void)setFailureMessageWithFormat:(NSString *) failureMessage, ...
{
    va_list args;
    va_start(args, failureMessage);
    _results[kFailureMessage] = [[NSString alloc]
                                 initWithFormat:failureMessage arguments:args];
    va_end(args);
}

- (void)setFixtureMapping:(NSDictionary *)fixtureMapping
{
    _fixtureMapping = [fixtureMapping copy];
}

- (void)setReturnDictionary:(NSDictionary *)returnDictionary
{
    if (returnDictionary != nil)
    {
        [_results setObject:returnDictionary forKey:kReturnDictionary];
    }
}

- (int)getCode
{
    return [[_results objectForKey:kCode] intValue];
}

- (int)getMappedSlot
{
    return [[_fixtureMapping objectForKey:kInternalSlot] intValue];
}

- (NSDictionary *)getFixtureMapping
{
    return _fixtureMapping;
}

- (NSDictionary *)getResults
{
    return _results;
}

@end
