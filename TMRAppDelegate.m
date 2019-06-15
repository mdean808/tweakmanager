#import "TMRAppDelegate.h"

#import "TMRRootViewController.h"
#import "TMRTweakListViewController.h"

@implementation TMRAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_rootViewController = [[UINavigationController alloc] initWithRootViewController:[[TMRRootViewController alloc] init]];
	_window.rootViewController = _rootViewController;
	[_window makeKeyAndVisible];
}


- (void)dealloc {
	[_window release];
	[_rootViewController release];
	[super dealloc];
}

@end
