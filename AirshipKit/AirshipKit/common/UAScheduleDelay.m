
/* Copyright Airship and Contributors */

#import "UAScheduleDelay.h"

NSUInteger const UAScheduleDelayMaxCancellationTriggers = 10;

// JSON Keys
NSString *const UAScheduleDelaySecondsKey = @"seconds";
NSString *const UAScheduleDelayRegionKey = @"region";
NSString *const UAScheduleDelayScreensKey = @"screen";
NSString *const UAScheduleDelayCancellationTriggersKey = @"cancellation_triggers";
NSString *const UAScheduleDelayAppStateKey = @"app_state";
NSString *const UAScheduleDelayAppStateForegroundName = @"foreground";
NSString *const UAScheduleDelayAppStateBackgroundName = @"background";

// Error domain
NSString * const UAScheduleDelayErrorDomain = @"com.urbanairship.schedule_delay";

@interface UAScheduleDelay()
@property(nonatomic, assign) NSTimeInterval seconds;
@property(nonatomic, strong) NSArray *screens;
@property(nonatomic, strong) NSString *regionID;
@property(nonatomic, assign) UAScheduleDelayAppState appState;
@property(nonatomic, strong) NSArray<UAScheduleTrigger *> *cancellationTriggers;
@end

@implementation UAScheduleDelayBuilder

@end

@implementation UAScheduleDelay


- (instancetype)initWithBuilder:(UAScheduleDelayBuilder *)builder {
    self = [super init];
    if (self) {
        self.seconds = builder.seconds;
        self.screens = builder.screens;
        self.regionID = builder.regionID;
        self.appState = builder.appState;
        self.cancellationTriggers = builder.cancellationTriggers ?: @[];
    }

    return self;
}

+ (instancetype)delayWithBuilderBlock:(void (^)(UAScheduleDelayBuilder *))builderBlock {
    UAScheduleDelayBuilder *builder = [[UAScheduleDelayBuilder alloc] init];

    if (builderBlock) {
        builderBlock(builder);
    }

    return [[UAScheduleDelay alloc] initWithBuilder:builder];
}

+ (nullable instancetype)delayWithJSON:(id)json error:(NSError * _Nullable *)error {
    if (![json isKindOfClass:[NSDictionary class]]) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"Attempted to deserialize invalid object: %@", json];
            *error =  [NSError errorWithDomain:UAScheduleDelayErrorDomain
                                          code:UAScheduleDelayErrorCodeInvalidJSON
                                      userInfo:@{NSLocalizedDescriptionKey:msg}];
        }

        return nil;
    }

    // Seconds
    id seconds = json[UAScheduleDelaySecondsKey];
    if (seconds && ![seconds isKindOfClass:[NSNumber class]]) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"Seconds must be a number. Invalid value: %@", seconds];
            *error =  [NSError errorWithDomain:UAScheduleDelayErrorDomain
                                          code:UAScheduleDelayErrorCodeInvalidJSON
                                      userInfo:@{NSLocalizedDescriptionKey:msg}];
        }

        return nil;
    }

    // Region ID
    id regionID = json[UAScheduleDelayRegionKey];
    if (regionID && ![regionID isKindOfClass:[NSString class]]) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"Region ID must be a string. Invalid value: %@", regionID];
            *error =  [NSError errorWithDomain:UAScheduleDelayErrorDomain
                                          code:UAScheduleDelayErrorCodeInvalidJSON
                                      userInfo:@{NSLocalizedDescriptionKey:msg}];
        }

        return nil;
    }

    // Screens
    id screens = json[UAScheduleDelayScreensKey];

    if (screens && (![screens isKindOfClass:[NSString class]] && ![screens isKindOfClass:[NSArray class]])) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"Screens must be a string or an array of strings. Invalid value: %@", screens];
            *error =  [NSError errorWithDomain:UAScheduleDelayErrorDomain
                                          code:UAScheduleDelayErrorCodeInvalidJSON
                                      userInfo:@{NSLocalizedDescriptionKey:msg}];
        }
        return nil;
    }

    if ([screens isKindOfClass:[NSString class]]) {
        screens = @[screens];
    }

    for (NSString *screen in screens) {
        if (screen && ![screen isKindOfClass:[NSString class]]) {
            if (error) {
                NSString *msg = [NSString stringWithFormat:@"Screens must be a string or an array of strings. Invalid value: %@", screen];
                *error =  [NSError errorWithDomain:UAScheduleDelayErrorDomain
                                              code:UAScheduleDelayErrorCodeInvalidJSON
                                          userInfo:@{NSLocalizedDescriptionKey:msg}];
            }
            return nil;
        }
    }

    // App state
    UAScheduleDelayAppState appState = UAScheduleDelayAppStateAny;
    id appStateContents = json[UAScheduleDelayAppStateKey];
    if (appStateContents) {
        if (![appStateContents isKindOfClass:[NSString class]]) {
            if (error) {
                NSString *msg = [NSString stringWithFormat:@"App state must be a string."];
                *error =  [NSError errorWithDomain:UAScheduleDelayErrorDomain
                                              code:UAScheduleDelayErrorCodeInvalidJSON
                                          userInfo:@{NSLocalizedDescriptionKey:msg}];
            }
            return nil;
        }
        
        NSString *stateName = [json[UAScheduleDelayAppStateKey] lowercaseString];

        if ([UAScheduleDelayAppStateForegroundName isEqualToString:stateName]) {
            appState = UAScheduleDelayAppStateForeground;
        } else if ([UAScheduleDelayAppStateBackgroundName isEqualToString:stateName]) {
            appState = UAScheduleDelayAppStateBackground;
        } else {
            if (error) {
                NSString *msg = [NSString stringWithFormat:@"Invalid app state: %@", stateName];
                *error =  [NSError errorWithDomain:UAScheduleDelayErrorDomain
                                              code:UAScheduleDelayErrorCodeInvalidJSON
                                          userInfo:@{NSLocalizedDescriptionKey:msg}];
            }

            return nil;
        }
    }

    // Cancellation triggers
    NSMutableArray *triggers = [NSMutableArray array];
    id triggersJSONArray = json[UAScheduleDelayCancellationTriggersKey];
    if (triggersJSONArray && ![triggersJSONArray isKindOfClass:[NSArray class]]) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"Cancellation triggers must be an array. Invalid value %@", triggersJSONArray];
            *error =  [NSError errorWithDomain:UAScheduleDelayErrorDomain
                                          code:UAScheduleDelayErrorCodeInvalidJSON
                                      userInfo:@{NSLocalizedDescriptionKey:msg}];
        }

        return nil;
    }

    for (id triggerJSON in triggersJSONArray) {
        UAScheduleTrigger *trigger = [UAScheduleTrigger triggerWithJSON:triggerJSON error:error];
        if (!trigger) {
            return nil;
        }

        [triggers addObject:trigger];
    }

    return [UAScheduleDelay delayWithBuilderBlock:^(UAScheduleDelayBuilder *builder) {
        builder.appState = appState;
        builder.screens = screens;
        builder.regionID = regionID;
        builder.seconds = [seconds doubleValue];
        builder.cancellationTriggers = triggers;
    }];
}

- (BOOL)isValid {
    if (self.cancellationTriggers.count > UAScheduleDelayMaxCancellationTriggers) {
        return NO;
    }

    return YES;
}

- (BOOL)isEqualToDelay:(nullable UAScheduleDelay *)delay {
    if (!delay) {
        return NO;
    }

    if (self.seconds != delay.seconds) {
        return NO;
    }

    if (self.appState != delay.appState) {
        return NO;
    }

    if (self.screens != nil) {
        for (NSString *screen in delay.screens) {
            if (![self.screens containsObject:screen]) {
                return NO;
            }
        }
    }

    if (self.regionID != delay.regionID && ![self.regionID isEqualToString:delay.regionID]) {
        return NO;
    }

    if (self.cancellationTriggers != delay.cancellationTriggers && ![self.cancellationTriggers isEqualToArray:delay.cancellationTriggers]) {
        return NO;
    }

    return YES;
}


#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[UAScheduleDelay class]]) {
        return NO;
    }

    return [self isEqualToDelay:(UAScheduleDelay *)object];
}

- (NSUInteger)hash {
    NSUInteger result = 1;
    result = 31 * result + self.seconds;
    result = 31 * result + self.appState;
    result = 31 * result + [self.regionID hash];
    result = 31 * result + [self.screens hash];
    result = 31 * result + [self.cancellationTriggers hash];
    return result;
}
@end
