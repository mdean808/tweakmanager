#import "TMRGlobalData.h"

@implementation TMRGlobalData;
@synthesize tweakages;
@synthesize enabledTweakageIndex;
static TMRGlobalData *sharedGlobalData = nil;
 
+ (TMRGlobalData*)sharedGlobalData {
    if (sharedGlobalData == nil) {
        sharedGlobalData = [[super allocWithZone:NULL] init];
 
		// Get all the tweaks
		NSMutableArray *tweaks = [[NSMutableArray alloc] init];
		NSString *sourcePath = @"/Library/MobileSubstrate/DynamicLibraries/";
		NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourcePath
																		error:NULL];
		[dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSString *filename = (NSString *)obj;
			NSString *extension = [[filename pathExtension] lowercaseString];
			if ([extension isEqualToString:@"dylib"]) {
				Tweak *newTweak = [[Tweak alloc] init];
				newTweak.name = filename;
				newTweak.enabled = [NSNumber numberWithBool:YES];
				[tweaks addObject: newTweak];
			}
		}];

		// Initialize the variables
		sharedGlobalData.tweakages = [[NSMutableArray alloc] init];
		sharedGlobalData.enabledTweakageIndex = 0;

		// Build the default tweakge
		Tweakage *defaultTweakage = [[Tweakage alloc] init];
		defaultTweakage.tweaks = tweaks;
		defaultTweakage.name = @"Default";
		// Add the default tweakage
		[sharedGlobalData.tweakages addObject: defaultTweakage];
    }
    return sharedGlobalData;
}
 
+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self)
	{
		if (sharedGlobalData == nil)
		{
			sharedGlobalData = [super allocWithZone:zone];
			return sharedGlobalData;
		}
	}
	return nil;
}
 
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
 
- (id)retain {
    return self;
}
 
- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}
 
- (oneway void)release {
    //do nothing
}
 
- (id)autorelease {
    return self;
}
 
@end