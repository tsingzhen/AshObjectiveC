
#import "ASHNodePool.h"

@implementation ASHNodePool
{
    ASHNode * _tail;
    Class _nodeClass;
    ASHNode * _cacheTail;
    NSMutableDictionary * _components;
}

- (id)initWithNodeClass:(Class)aNodeClass
             components:(NSMutableDictionary *)components
{
    self = [super init];
    
    if(self != nil)
    {
        _nodeClass = aNodeClass;
        _components = components;
    }
    
    return self;
}

- (ASHNode *)getNode
{
    if(_tail != nil)
    {
        ASHNode * node = _tail;
        _tail = _tail.previous;
        node.previous = nil;
        return node;
    }
    else
    {
        return [[_nodeClass alloc] init];
    }
}

- (void)disposeNode:(ASHNode *)node
{
    for (NSString * componentClass in _components)
    {
        NSString * propertyName = _components[componentClass];
        [node setValue:nil
                forKey:propertyName];
    }

    node.entity = nil;

    node.next = nil;
    node.previous = _tail;
    _tail = node;
}

- (void)cacheNode:(ASHNode *)node
{
    node.previous = _cacheTail;
    _cacheTail = node;
}

- (void)releaseCache
{
    while (_cacheTail != nil)
    {
        ASHNode * node = _cacheTail;
        _cacheTail = node.previous;
        [self disposeNode:node];
    }
}

@end
