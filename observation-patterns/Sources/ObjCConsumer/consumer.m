
#import "include/consumer.h"

@interface OBJConsumer() {
    atomic_int _counter;
}
@end

@implementation OBJConsumer

+(NSSet<NSString*>*)keyPaths {
    static NSSet<NSString*>*_titles;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _titles = [[NSSet alloc] initWithObjects:
                   @"foo",
                   @"bar",
                   @"baz",
                   @"qux",
                   nil
        ];
    });
    return _titles;
}

-(id)initProducer:(NSObject*)producer {
    self = [super init];

    if (self) {
        [self setProducer:producer];

        NSKeyValueObservingOptions opt = NSKeyValueObservingOptionInitial;

        for (NSString* path in [OBJConsumer keyPaths]) {
            [producer addObserver:self forKeyPath:path options:opt context:nil];
        }
    }

    return self;
}

-(void)dealloc {
    for (NSString* path in [OBJConsumer keyPaths]) {
        [self.producer removeObserver:self forKeyPath:path];
    }
}

-(atomic_int*)getCounter {
    return &_counter;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if (![[OBJConsumer keyPaths] containsObject:keyPath]) {
        NSLog(@"other: %@\n", keyPath);
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    atomic_fetch_add(&_counter, 1);
}
@end
