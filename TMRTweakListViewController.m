#import "TMRGlobalData.h"
#import "TMRAppDelegate.h"
#import "TMRRootViewController.h"
#import "TMRTweakListViewController.h"
#import "TweakManager.h"


@implementation TMRTweakListViewController {
	NSMutableArray *_tweaks;
	Tweakage *_newTweakage;
}

- (void)loadView {
	// Setup the view
	[super loadView];
	self.title = @"Select Tweaks";
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)] autorelease];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)] autorelease];

	// Create a new tweakage
	_newTweakage = [[Tweakage alloc] init];

	_newTweakage.name = _tweakageName;

	// Populate _tweaks with found tweaks
	_tweaks = [[NSMutableArray alloc] init];
	NSString *sourcePath = @"/Library/MobileSubstrate/DynamicLibraries/";
	NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourcePath
	                 error:NULL];
	[dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
	         NSString *filename = (NSString *)obj;
	         NSString *extension = [filename pathExtension];
			 NSLog(@"TMRLog: extension: %@", extension);
	         if ([extension isEqualToString:@"dylib"]) {
	                 Tweak *newTweak = [[Tweak alloc] init];
	                 newTweak.name = filename;
	                 newTweak.enabled = [NSNumber numberWithBool:YES];
	                 [_tweaks addObject: newTweak];
	                 [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
		 } else if ([ extension isEqualToString:@"TMRDisabled"]) {
	                 Tweak *newTweak = [[Tweak alloc] init];
	                 newTweak.name = [filename stringByReplacingOccurrencesOfString:@".TMRDisabled" withString:@""];
	                 newTweak.enabled = [NSNumber numberWithBool:YES];
	                 [_tweaks addObject: newTweak];
	                 [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
		 }
	 }];
}


- (void) doneButtonTapped:(id)sender {
	_newTweakage.tweaks = _tweaks;
	// udpate the global var
	[[TMRGlobalData sharedGlobalData].tweakages addObject:_newTweakage];
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSData *data = [NSKeyedArchiver
	                archivedDataWithRootObject:[TMRGlobalData sharedGlobalData].tweakages];
	[prefs setObject:data forKey:@"tweakages"];
	[prefs synchronize];
	// send notificaiton to update the root view controller
	[[NSNotificationCenter defaultCenter] postNotificationName:@"reload_data" object:self];
	// Display the root view controller
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void) cancelButtonTapped:(id)sender {
	// Cancel Tweakage creation
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _tweaks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}

	Tweak *tweak = _tweaks[indexPath.row];
	cell.textLabel.text = tweak.name;
	if (tweak.enabled == [NSNumber numberWithBool:YES]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}   return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
	if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryNone) {
		[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
		[_tweaks[indexPath.row] setValue:[NSNumber numberWithBool:YES] forKey:@"enabled"];
	} else {
		[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
		[_tweaks[indexPath.row] setValue:[NSNumber numberWithBool:NO] forKey:@"enabled"];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSLog(@"Tweak: %@, Enabled: %@", [_tweaks[indexPath.row] valueForKey:@"name"], [_tweaks[indexPath.row] valueForKey:@"enabled"]);
}

@end
