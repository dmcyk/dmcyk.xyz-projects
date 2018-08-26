//
//  foo.m
//  ObjCConsumer
//
//  Created by Damian Malarczyk on 14/07/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

#import "foo.h"

@implementation Foo

-(void)takeRawDictionary:(NSDictionary *)dict {};
-(void)takeGenericDictionary:(NSDictionary<NSString *,NSNumber *> *)dict {};

+(NSDictionary<NSString*, NSNumber*>*)foo_dict {
    NSMutableDictionary<NSString*, NSNumber*>* _dict;
    _dict = [NSMutableDictionary new];
    for (size_t i = 0; i < 10; i++) {
        _dict[[NSString stringWithFormat:@"foo_%@", @(i)]] = @(i);
    }
    return _dict;
}

+(void)initialize {};

@end

void foo_callToTakeGeneric(Foo* foo) {
    [foo takeGenericDictionary:[Foo foo_dict]];
}

void foo_callToTakeRaw(Foo* foo) {
    [foo takeRawDictionary:[Foo foo_dict]];
}
