#import "TMRAppDelegate.h"

int main(int argc, char *argv[]) {
	@autoreleasepool {
		
		
        setgid(0);
        setuid(0);
		
        return UIApplicationMain(argc, argv, nil, NSStringFromClass(TMRAppDelegate.class));
	}
}