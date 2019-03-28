//
//  AddSpace.h
//  tarantoolui
//
//  Created by Michael Filonenko on 17/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#include <tarantool/tarantool.h>
#include <tarantool/tnt_net.h>
#include <tarantool/tnt_opt.h>

#import <Foundation/Foundation.h>

NSMutableArray* createSpace(struct tnt_stream *tnt, NSDictionary* space);
