
#ifndef CONSUMER_H
#define CONSUMER_H

@import Foundation;
#include <stdatomic.h>

NS_ASSUME_NONNULL_BEGIN

@interface OBJConsumer: NSObject

@property NSObject* producer;

-(id)initProducer:(NSObject*)producer;
-(atomic_int*)getCounter;

@end

NS_ASSUME_NONNULL_END

#endif
