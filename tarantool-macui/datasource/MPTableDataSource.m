//
//  MPTableDataSource.m
//  tarantoolui
//
//  Created by Michael Filonenko on 06/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import "MPTableDataSource.h"

#include <tarantool/tarantool.h>
#include <tarantool/tnt_net.h>
#include <tarantool/tnt_opt.h>


#include <msgpuck/msgpuck.h>

#import "MPItem.h"

@implementation MPTableDataSource {
    char* data;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (data == NULL)
        return 0;
    
    const char* msg = data;
    if (msg == NULL)
        return 0;
    enum mp_type type = mp_typeof(*msg);
    
    switch (type) {
        case MP_ARRAY: {
            uint32_t size = mp_decode_array(&msg);
            return size;
        }
        default:
            return 0;
    }
    return 0;
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSInteger column = [[tableView tableColumns] indexOfObject:tableColumn];
    if (data == NULL)
        return 0;
    
    const char* msg = data;
    if (msg == NULL)
        return 0;
    enum mp_type type = mp_typeof(*msg);
    
    switch (type) {
        case MP_ARRAY: {
            uint32_t rows = mp_decode_array(&msg);
            assert(row < rows);
            for (int i = 0; i < row; ++i) {
                mp_next(&msg);
            }
            
            enum mp_type columntype = mp_typeof(*msg);
            switch (columntype) {
                case MP_ARRAY:{
                    uint32_t columns = mp_decode_array(&msg);
                    if (column >= columns)
                        return @"box.NULL";
                    
                    for (int i = 0; i < column; ++i) {
                        mp_next(&msg);
                    }
                    
                    NSString *result;
                    enum mp_type valtype = mp_typeof(*msg);
                    switch(valtype) {
                        case MP_INT:
                            result = [NSString stringWithFormat:@"%lld", mp_decode_int(&msg)];
                            break;
                        case MP_UINT:
                            result = [NSString stringWithFormat:@"%lld", mp_decode_uint(&msg)];
                            break;
                        case MP_STR: {
                            uint32_t len = 0;
                            const char* str = mp_decode_str(&msg, &len);
                            result = [[NSString alloc] initWithBytes:str length:len encoding:NSUTF8StringEncoding];
                            break;
                        }
                        case MP_ARRAY: {
                            uint32_t size = mp_decode_array(&msg);
                            result = [NSString stringWithFormat:@"ARRAY (%u)", size];
                            break;
                        }
                        case MP_MAP: {
                            uint32_t size = mp_decode_map(&msg);
                            result = [NSString stringWithFormat:@"MAP (%u)", size];
                            break;
                        }
                    }
                    return result;
                    break;}
                default:
                    return @"box.NULL";
            }
        }
        default:
            return @"box.NULL";
    }
    return @"box.NULL";
}
- (void)setMsgPackData:(char *)mpdata {
    if (self->data != NULL) {
        free(self->data);
    }
    self->data = mpdata;
}
@end
