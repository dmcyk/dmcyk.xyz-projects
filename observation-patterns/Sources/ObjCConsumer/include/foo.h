//
//  foo.h
//  ObjCConsumer
//
//  Created by Damian Malarczyk on 14/07/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

#ifndef FOO_H
#define FOO_H

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface Foo: NSObject

-(void)takeGenericDictionary:(NSDictionary<NSString*, NSNumber*>*)dict;
-(void)takeRawDictionary:(NSDictionary*)dict;

@end

void foo_callToTakeGeneric(Foo* foo);
void foo_callToTakeRaw(Foo* foo);

NS_ASSUME_NONNULL_END

#endif
