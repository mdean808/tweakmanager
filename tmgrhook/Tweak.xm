#import "libactivator/libactivator.h"
#import "../src/TweakManager.h"
#import <Foundation/Foundation.h>
#import <spawn.h>
#import <sys/wait.h>
@interface NSTask : NSObject

@property (copy) NSURL * executableURL;
@property (copy) NSArray * arguments;
@property (copy) NSDictionary * environment;
@property (copy) NSURL * currentDirectoryURL;
@property (retain) id standardInput;
@property (retain) id standardOutput;
@property (retain) id standardError;
@property (readonly) int processIdentifier;
@property (getter=isRunning,readonly) BOOL running;
@property (readonly) int terminationStatus;
@property (readonly) long long terminationReason;
@property (copy) id terminationHandler;
@property (assign) long long qualityOfService;
+(id)currentTaskDictionary;
+(id)launchedTaskWithDictionary:(id)arg1;
+(id)launchedTaskWithLaunchPath:(id)arg1 arguments:(id)arg2;
+(id)launchedTaskWithExecutableURL:(id)arg1 arguments:(id)arg2 error:(out id*)arg3 terminationHandler:(/*^block*/ id)arg4;
+(id)allocWithZone:(NSZone*)arg1;
-(NSURL *)executableURL;
-(id)currentDirectoryPath;
-(void)setArguments:(NSArray *)arg1;
-(void)setCurrentDirectoryPath:(id)arg1;
-(id)launchPath;
-(void)setLaunchPath:(id)arg1;
-(int)terminationStatus;
-(void)launch;
-(BOOL)launchAndReturnError:(id*)arg1;
-(void)setCurrentDirectoryURL:(NSURL *)arg1;
-(NSURL *)currentDirectoryURL;
-(void)setExecutableURL:(NSURL *)arg1;
-(void)interrupt;
-(long long)suspendCount;
-(void)setStandardInput:(id)arg1;
-(void)setStandardOutput:(id)arg1;
-(void)setStandardError:(id)arg1;
-(id)standardInput;
-(id)standardOutput;
-(id)standardError;
-(long long)terminationReason;
-(long long)qualityOfService;
-(void)terminate;
-(NSArray *)arguments;
-(id)init;
-(BOOL)isRunning;
-(BOOL)resume;
-(NSDictionary *)environment;
-(void)setEnvironment:(NSDictionary *)arg1;
-(BOOL)suspend;
-(void)setQualityOfService:(long long)arg1;
-(int)processIdentifier;
-(void)setTerminationHandler:(id)arg1;
-(id)terminationHandler;
@end

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

@interface SBHomeScreenViewController : UIViewController
@end
// Set up the activator Listener
@interface TweakManagerListener : NSObject<LAListener>
@end

@implementation TweakManagerListener

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event forListenerName:(NSString *)listenerName {
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Applications/TweakManager.app/tweakmanager_prefs.plist"];
	NSData *data = [prefs objectForKey:@"tweakages"];
	NSArray *tweakages = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	NSInteger activeIndex = [[prefs valueForKey:@"activeTweakageIndex"] intValue];
	NSInteger listenIndex = [[[listenerName componentsSeparatedByString:@" "][1] substringToIndex:[[listenerName componentsSeparatedByString:@" "][1] length] - 1] intValue];
	// Check if tweakage is active already
	if (activeIndex != listenIndex) {
		NSLog(@"TMGRHook: Enabling Tweakage: %@", listenerName);
		Tweakage * tweakage = tweakages[0];
		// Set enable default tweakage
		for (Tweak *tweak in tweakage.tweaks) {
			NSFileManager *fileManager = [NSFileManager defaultManager];
			NSString *tweakPath = [@"/Library/MobileSubstrate/DynamicLibraries/"
			                       stringByAppendingString:tweak.name];
			NSString *disabledTweakPath = [tweakPath stringByAppendingString:@".TMRDisabled"];

			//Re-enalbe disabled Tweak
			if (![fileManager fileExistsAtPath:tweakPath]) {
				NSLog(@"TMGRHook: Enabling tweak.");
				NSLog(@"TMGRHook: Attempting /usr/bin/crux /bin/mv %@ %@", disabledTweakPath, tweakPath);
				pid_t pid;
				int status;
				const char *args[] = {
					//(const char*)[@"bash" UTF8String],
					(const char*)[@"crux" UTF8String],
					(const char*)[@"/bin/mv" UTF8String],
					(const char*)[disabledTweakPath UTF8String],
					(const char*)[tweakPath UTF8String],
				};
				posix_spawn(&pid, "/bin/bash", NULL, NULL, (char* const*)args, NULL);
				waitpid(pid, &status, 0);
				NSLog(@"TMGRHook: posix_spawn status: %d", status);
			}
		}
		// Set the index of the new tweakage
		prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Applications/TweakManager.app/tweakmanager_prefs.plist"];
		[prefs setValue:[NSString stringWithFormat: @"%ld", listenIndex] forKey:@"activeTweakageIndex"];
		[prefs writeToFile:@"/Applications/TweakManager.app/tweakmanager_prefs.plist" atomically:YES];

		// Disable tweaks!
		tweakage = tweakages[listenIndex];
		for (Tweak *tweak in tweakage.tweaks) {
			NSFileManager *fileManager = [NSFileManager defaultManager];
			NSString *tweakPath = [@"/Library/MobileSubstrate/DynamicLibraries/"
			                       stringByAppendingString:tweak.name];
			NSString *disabledTweakPath = [tweakPath stringByAppendingString:@".TMRDisabled"];
			if (tweak.enabled == [NSNumber numberWithBool:YES]) {
				if (![fileManager fileExistsAtPath:tweakPath]) {
					NSLog(@"TMGRHook: Enabling tweak.");
					NSLog(@"TMGRHook: Attempting /usr/bin/crux /bin/mv %@ %@", disabledTweakPath, tweakPath);
					pid_t pid;
					int status;
					const char *args[] = {
						//(const char*)[@"bash" UTF8String],
						(const char*)[@"crux" UTF8String],
						(const char*)[@"/bin/mv" UTF8String],
						(const char*)[disabledTweakPath UTF8String],
						(const char*)[tweakPath UTF8String],
					};

					posix_spawn(&pid, "/bin/bash", NULL, NULL, (char* const*)args, NULL);
					waitpid(pid, &status, 0);
					NSLog(@"TMGRHook: posix_spawn status: %d", status);
				}
			} else {
				NSLog(@"TMGRHook: Disabling tweak.");
				if ([fileManager fileExistsAtPath:tweakPath]) {
					NSLog(@"TMGRHook: Attempting /usr/bin/crux /bin/mv %@ %@", tweakPath, disabledTweakPath);
					pid_t pid;
					int status;
					const char *args[] = {
						//(const char*)[@"bash" UTF8String],
						(const char*)[@"crux" UTF8String],
						(const char*)[@"/bin/mv" UTF8String],
						(const char*)[tweakPath UTF8String],
						(const char*)[disabledTweakPath UTF8String],
					};

					posix_spawn(&pid, "/bin/bash", NULL, NULL, (char* const*)args, NULL);
					waitpid(pid, &status, 0);
					NSLog(@"TMGRHook: posix_spawn status: %d", status);
				}
			}
		}
	} else {
		NSLog(@"TMGRHook: Tweakage already enabled: %@", listenerName);

	}

}

@end

%hook SBLockScreenViewControllerBase

-(void)viewDidLoad {
	%orig;
	// Only register the listener if activator is installed
	dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
	Class la = objc_getClass("LAActivator");

	// Only register the listener if activator is installed
	if (la) {
		NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Applications/TweakManager.app/tweakmanager_prefs.plist"];
		NSData *data = [prefs objectForKey:@"tweakages"];
		NSArray *tweakages = [NSKeyedUnarchiver unarchiveObjectWithData:data];

		for (int i = 0; i < tweakages.count; i++) {
			Tweakage *tweakage = tweakages[i];
			// Register the activator listener
			NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
			[[LAActivator sharedInstance] registerListener:[TweakManagerListener new] forName:[NSString stringWithFormat:@"Tweakage %d: %@", i, tweakage.name]];
			[p release];
		}
	} else {
		NSLog(@"TMGRHook: Failed to register tweakage listeners - Activator not installed.");
	}

}
%end