//
//  GetData.h
//  tarantoolui
//
//  Created by Michael Filonenko on 08/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#ifndef GetData_h
#define GetData_h

#include <tarantool/tarantool.h>
#include <tarantool/tnt_net.h>
#include <tarantool/tnt_opt.h>

#import <Foundation/Foundation.h>

NSMutableArray* getData(struct tnt_stream *tnt, NSString* space,
                        NSInteger limit, id from,
                        id search);

#endif /* GetData_h */
