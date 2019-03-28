//
//  MsgPackDataSource.m
//  tarantoolui
//
//  Created by Michael Filonenko on 18/12/2018.
//  Copyright © 2018 tarantool. All rights reserved.
//

#import "MsgPackDataSource.h"

#include <tarantool/tarantool.h>
#include <tarantool/tnt_net.h>
#include <tarantool/tnt_opt.h>

#define MP_SOURCE 1
#include <msgpuck/msgpuck.h>

#import "MPItem.h"



@implementation MsgPackDataSource
{
    char* data;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        data = NULL;
    }
    return self;
}

- (void)dealloc
{
    if (data != NULL)
        free(data);
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (data == NULL)
        return nil;
    
    const char* msg = data;
    if (msg == NULL)
        return 0;
    enum mp_type type = mp_typeof(*msg);
    if (item != nil) {
        MPItem* casted = (MPItem*)item;
        msg = [casted data];
        type = mp_typeof(*msg);
    }
    
    switch (type) {
        case MP_MAP: {
            uint32_t size = mp_decode_map(&msg);
            assert(index<size);
            for (uint32_t i = 0; i < index*2; ++i) {
                mp_next(&msg);
            }
            
            MPItem *item = [[MPItem alloc] initWithData:msg];
            [item setPair:YES];
            return item;
        }
        case MP_ARRAY: {
            uint32_t size = mp_decode_array(&msg);
            assert(index<size);
            for (uint32_t i = 0; i < index; ++i) {
                mp_next(&msg);
            }
            
            MPItem *item = [[MPItem alloc] initWithData:msg];
            return item;
        }
        default:
            if (item != nil) {
                MPItem *casted = (MPItem*)item;
                msg = [casted data];
                if ([casted pair]) {
                    mp_next(&msg);
                    type = mp_typeof(*msg);
                    switch (type) {
                        case MP_MAP:{
                            uint32_t size = mp_decode_map(&msg);
                            assert(index<size);
                            for (uint32_t i = 0; i < index*2; ++i) {
                                mp_next(&msg);
                            }
                            
                            MPItem *item = [[MPItem alloc] initWithData:msg];
                            [item setPair:YES];
                            return item;}
                        case MP_ARRAY:{
                            uint32_t size = mp_decode_array(&msg);
                            assert(index<size);
                            for (uint32_t i = 0; i < index; ++i) {
                                mp_next(&msg);
                            }
                            
                            MPItem *item = [[MPItem alloc] initWithData:msg];
                            return item;
                        }
                        default:
                            return nil;
                    }
                }
            }
            return nil;
    }
    return nil;
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if (data == NULL)
        return NO;
    
    const char* msg = data;
    if (msg == NULL)
        return 0;
    enum mp_type type = mp_typeof(*msg);
    if (item != nil) {
        MPItem *casted = (MPItem*)item;
        msg = [casted data];
        type = mp_typeof(*msg);
    }
    
    switch (type) {
        case MP_MAP:
            return YES;
        case MP_ARRAY:
            return YES;
        default: {
            if (item != nil) {
                MPItem *casted = (MPItem*)item;
                msg = [casted data];
                if ([casted pair]) {
                    mp_next(&msg);
                    type = mp_typeof(*msg);
                    switch (type) {
                        case MP_MAP:
                            return YES;
                        case MP_ARRAY:
                            return YES;
                        default:
                            return NO;
                    }
                }
            }
            return NO;
        }
    }
    
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (data == NULL)
        return 0;
    
    const char* msg = data;
    if (msg == NULL)
        return 0;
    
    enum mp_type type = mp_typeof(*msg);
    if (item != nil) {
        MPItem* casted = (MPItem*)item;
        msg = [casted data];
        type = mp_typeof(*msg);
    }
    switch (type) {
        case MP_MAP: {
            uint32_t size = mp_decode_map(&msg);
            return size;
        }
        case MP_ARRAY:{
            uint32_t size = mp_decode_array(&msg);
            return size;
        }
        default: {
            if (item != nil) {
                MPItem *casted = (MPItem*)item;
                msg = [casted data];
                if ([casted pair]) {
                    mp_next(&msg);
                    type = mp_typeof(*msg);
                    switch (type) {
                        case MP_MAP:{
                            uint32_t size = mp_decode_map(&msg);
                            return size;}
                        case MP_ARRAY:{
                            uint32_t size = mp_decode_array(&msg);
                            return size;}
                        default:
                            return 0;
                    }
                }
            }
            return 0;
        }
    }
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    const char* msg = NULL;
    MPItem* casted = (MPItem*)item;
    msg = [casted data];
    enum mp_type type = mp_typeof(*msg);
    NSString *result;
    switch(type) {
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
    if ([item pair]) {
        enum mp_type type = mp_typeof(*msg);
        switch(type) {
            case MP_INT:
                result = [result stringByAppendingFormat:@"=%lld", mp_decode_int(&msg)];
                break;
            case MP_UINT:
                result = [result stringByAppendingFormat:@"=%lld", mp_decode_uint(&msg)];
                break;
            case MP_STR: {
                uint32_t len = 0;
                const char* str = mp_decode_str(&msg, &len);
                result = [result stringByAppendingString:[[NSString alloc] initWithBytes:str length:len encoding:NSUTF8StringEncoding]];
                break;
            }
            case MP_ARRAY: {
                uint32_t size = mp_decode_array(&msg);
                result = [result stringByAppendingFormat:@"=ARRAY (%u)", size];
                break;
            }
            case MP_MAP: {
                uint32_t size = mp_decode_map(&msg);
                result = [result stringByAppendingFormat:@"=MAP (%u)", size];
                break;
            }
        }
    }
    
    return result;
}

- (void)setMsgPackData:(char *)mpdata {
    if (self->data != NULL) {
        free(self->data);
    }
    self->data = mpdata;
}

@end
