
#import "Asteroids.h"
#import "ASHEngine.h"
#import "EntityCreator.h"
#import "GameConfig.h"
#import "ASHFrameTickProvider.h"
#import "SystemPriorities.h"
#import "GameManager.h"
#import "MotionControlSystem.h"
#import "GunControlSystem.h"
#import "BulletAgeSystem.h"
#import "DeathThroesSystem.h"
#import "MovementSystem.h"
#import "CollisionSystem.h"
#import "AnimationSystem.h"
#import "RenderSystem.h"

@implementation Asteroids
{
    UIView * container;
    ASHEngine * engine;
    ASHFrameTickProvider * tickProvider;
    EntityCreator * creator;
    TriggerPoll * triggerPoll;
    GameConfig * config;
}

@synthesize triggerPoll;

- (id)initWithContainer:(UIView *)aContainer
                  width:(float)width
                 height:(float)height
{
    self = [super init];
    
    if (self != nil)
    {
        container = aContainer;
        [self prepareWithWidth:width
                    height:height];
    }
    
    return self;
}

- (void)prepareWithWidth:(float)width
                  height:(float)height
{
    engine = [[ASHEngine alloc] init];
    creator = [[EntityCreator alloc] initWithEngine:engine];
    triggerPoll = [[TriggerPoll alloc] init];
    config = [[GameConfig alloc] init];
    config.width = width;
    config.height = height;
    
    [engine addSystem:[[GameManager alloc] initWithCreator:creator
                                                    config:config]
             priority:preUpdate];
    
    [engine addSystem:[[MotionControlSystem alloc] initWithTriggerPoll:triggerPoll]
             priority:update];
    
    [engine addSystem:[[GunControlSystem alloc] initWithTriggerPoll:triggerPoll
                                                            creator:creator]
             priority:update];
    
    [engine addSystem:[[BulletAgeSystem alloc] initWithCreator:creator]
             priority:update];
    
    [engine addSystem:[[DeathThroesSystem alloc] initEntityCreator:creator]
             priority:update];
    
    [engine addSystem:[[MovementSystem alloc] initWithConfig:config]
             priority:move];
    
    [engine addSystem:[[CollisionSystem alloc] initWithCreator:creator]
             priority:resolveCollisions];
    
    [engine addSystem:[[AnimationSystem alloc] initSystem] priority:animate];
    
    [engine addSystem:[[RenderSystem alloc] initWithContainer:container]
             priority:render];
    
    [creator createGame];
}

- (void)start
{
    tickProvider = [[ASHFrameTickProvider alloc] initWithMaximumFrameTime:1. / 60.];
    [tickProvider addListener:self
                       action:@selector(update:)];
    [tickProvider start];
}

- (void)update:(NSNumber *)time
{
    [engine update:time.doubleValue];
}

@end
