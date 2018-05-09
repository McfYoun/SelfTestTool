//
//  Unit.h
//  FixtureService
//
//  Created by Darren Mistica on 2/17/17.
//  Copyright © 2017 Darren Mistica. All rights reserved.
//

#ifndef Unit_h
#define Unit_h

// Return Value Keys
#define kReturnDictionary   @"returnDictionary"
#define kFailureMessage     @"failureMessage"
#define kFixtureId          @"fixtureId"
#define kHeadId             @"headId"
#define kCode               @"code"
#define kDefaultCode        -9999

// Fixture Mapping Dictionary Keys
#define kFixture            @"fixture"
#define kPosition           @"position"
#define kInternalSlot       @"internalSlot"
#define kUserInfo           @"userInfo"

#import "Socket.h"

@interface Unit: NSObject

@property (readonly) int slot;
@property (readonly) NSString* command;
@property (readonly) NSDictionary* parameters;
@property (nonatomic) Socket * socket;

- (id)initWithContext:(NSDictionary *)context;

// For failure messages with a custom failure message, set code first, then message
- (void)setCode:(int) code;
- (void)setFailureMessageWithFormat:(NSString *) failureMessage, ...;
- (void)setFixtureMapping:(NSDictionary *)fixtureMapping;
- (void)setReturnDictionary:(NSDictionary *)returnDictionary;
- (int)getCode;
- (int)getMappedSlot;
- (NSDictionary *)getFixtureMapping;
- (NSDictionary *)getResults;

@end

#endif /* Unit_h */
