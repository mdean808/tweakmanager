#import "TweakManager.h"

@interface TMRGlobalData : NSObject {
NSMutableArray <Tweakage*> *tweakages; // global variable
NSInteger enabledTweakageIndex;
}
 
@property (nonatomic, retain) NSMutableArray <Tweakage*> *tweakages;
@property (nonatomic, assign) NSInteger enabledTweakageIndex;

+ (TMRGlobalData*)sharedGlobalData;
 
@end