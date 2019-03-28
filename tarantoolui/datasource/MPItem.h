//
//  MPItem.h
//  tarantoolui
//
//  Created by Michael Filonenko on 06/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MPItem : NSObject
- (instancetype)initWithData:(const char*) data;
- (const char*)data;
- (void)setPair:(BOOL)pair;
- (BOOL)pair;
@end
