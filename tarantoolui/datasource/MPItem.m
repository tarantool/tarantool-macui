//
//  MPItem.m
//  tarantoolui
//
//  Created by Michael Filonenko on 06/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import "MPItem.h"

@implementation MPItem
{
    const char* data;
    BOOL pair;
}

- (instancetype)initWithData:(const char*) data {
    self = [super init];
    if (self) {
        self->data = data;
    }
    return self;
}

- (const char*)data {
    return self->data;
}

- (void)setPair:(BOOL)pair {
    self->pair = pair;
}

- (BOOL)pair {
    return self->pair;
}
@end
