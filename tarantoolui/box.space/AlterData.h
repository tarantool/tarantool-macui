//
//  AlterData.h
//  tarantoolui
//
//  Created by Michael Filonenko on 26/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <tarantool/tarantool.h>
#include <tarantool/tnt_net.h>
#include <tarantool/tnt_opt.h>

#import <Foundation/Foundation.h>

NSMutableArray* alterData(struct tnt_stream *tnt, NSString* space,
                          id origin, id newobj);
