@interface Tweak : NSObject 
{
NSString *name;
NSNumber *enabled;
}
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSNumber *enabled;

@end

@interface Tweakage : NSObject 
{
NSString *name;
NSMutableArray *tweaks;
}

@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain, readwrite) NSMutableArray *tweaks;

@end