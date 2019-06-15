#import "TweakManager.h"

@implementation Tweak
@synthesize name;
@synthesize enabled;

- (id)initWithCoder:(NSCoder *)decoder {
  if (self = [super init]) {
    self.name = [decoder decodeObjectForKey:@"name"];
    self.enabled = [decoder decodeObjectForKey:@"enabled"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:name forKey:@"name"];
  [encoder encodeObject:enabled forKey:@"enabled"];
}
@end

@implementation Tweakage
@synthesize name;
@synthesize tweaks;

- (id)initWithCoder:(NSCoder *)decoder {
  if (self = [super init]) {
    self.name = [decoder decodeObjectForKey:@"name"];
    self.tweaks = [decoder decodeObjectForKey:@"tweaks"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:name forKey:@"name"];
  [encoder encodeObject:tweaks forKey:@"tweaks"];
}
@end