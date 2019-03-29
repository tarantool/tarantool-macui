//
//  GetSpaces.h
//  tarantoolui
//
//  Created by Michael Filonenko on 08/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#ifndef GetSpaces_h
#define GetSpaces_h

#include <tarantool/tarantool.h>
#include <tarantool/tnt_net.h>
#include <tarantool/tnt_opt.h>

#import <Foundation/Foundation.h>

/*!
* \brief Synchroniusly evaluates lua expression with arguments in tnt instance
*
* \param[in]  tnt    tnt connection
* \param[in]  command  lua script
* \param[in]  args argumnents
*
* \returns array if results

* \retval @[result, ...]  results
* \retval @[EMPTY, error] error while processing both c and lua sides
 */
NSMutableArray* eval(struct tnt_stream *tnt, NSString* command, NSArray* args);

NSMutableArray* getSpaces(struct tnt_stream *tnt, BOOL showSystem);
NSMutableArray* dropSpace(struct tnt_stream *tnt, NSString* spacename);

#endif /* GetSpaces_h */
