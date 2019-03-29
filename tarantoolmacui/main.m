//
//  main.m
//  tarantoolui
//
//  Created by Michael Filonenko on 10/12/2018.
//  Copyright © 2018 tarantool. All rights reserved.
//

#import <Cocoa/Cocoa.h>

static void Handler(int signal) {
    if (signal == SIGPIPE) {
        NSLog(@"%s", "sigpipe");
    }
}

int main(int argc, const char * argv[]) {
    struct sigaction action = { 0 };
    action.sa_handler = Handler;
    sigaction(SIGPIPE, &action, NULL);

    return NSApplicationMain(argc, argv);
}
