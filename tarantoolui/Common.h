//
//  Common.h
//  tarantoolui
//
//  Created by Michael Filonenko on 08/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#ifndef Common_h
#define Common_h

#define StringMultiline(...) #__VA_ARGS__

@interface NSObject (ATMutableDeepCopy)
- (id)mutableDeepCopy;
@end

#endif /* Common_h */
