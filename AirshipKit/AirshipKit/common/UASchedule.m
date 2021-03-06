/* Copyright Airship and Contributors */

#import "UASchedule+Internal.h"

@implementation UASchedule

- (instancetype)initWithIdentifier:(NSString *)identifier
                              info:(UAScheduleInfo *)info
                          metadata:(NSDictionary *)metadata {
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.info = info;
        self.metadata = metadata;
    }

    return self;
}

+ (instancetype)scheduleWithIdentifier:(NSString *)identifier
                                  info:(UAScheduleInfo *)info
                              metadata:(NSDictionary *)metadata {
    return [[UASchedule alloc] initWithIdentifier:identifier
                                             info:info
                                         metadata:metadata];
}

- (BOOL)isEqualToSchedule:(UASchedule *)schedule {
    if (!schedule) {
        return NO;
    }

    if (![self.identifier isEqualToString:schedule.identifier]) {
        return NO;
    }

    if (![self.metadata isEqualToDictionary:schedule.metadata]) {
        return NO;
    }

    if (![self.info isEqualToScheduleInfo:schedule.info]) {
        return NO;
    }

    return YES;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[UASchedule class]]) {
        return NO;
    }

    return [self isEqualToSchedule:(UASchedule *)object];
}

- (NSUInteger)hash {
    NSUInteger result = 1;
    result = 31 * result + [self.info hash];
    result = 31 * result + [self.identifier hash];
    result = 31 * result + [self.metadata hash];

    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"UASchedule: %@ metadata: %@", self.identifier, self.metadata];
}

@end
