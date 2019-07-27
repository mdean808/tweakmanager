#import "TMRRootViewController.h"
#import "TMRAppDelegate.h"
#import "TMRGlobalData.h"
#import "TMRTweakListViewController.h"
#import "TMRTweakageEditViewController.h"
#import "TweakManager.h"
#import <spawn.h>
// Start app
@implementation TMRRootViewController

- (void)loadView {
	[super loadView];

	self.title = @"All Tweakages";
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
	                                          initWithTitle:@"Respring"
	                                          style:UIBarButtonItemStylePlain
	                                          target:self
	                                          action:@selector(respringButtonTapped:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
	                                           initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
	                                           target:self
	                                           action:@selector(addButtonTapped:)] autorelease];
	// Wait for reload to load table
	[[NSNotificationCenter defaultCenter] addObserver:self
	 selector:@selector(handle_data)
	 name:@"reload_data"
	 object:nil];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] init];

	if ([fileManager fileExistsAtPath: @"/Applications/TweakManager.app/tweakmanager_prefs.plist"]) {
		prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Applications/TweakManager.app/tweakmanager_prefs.plist"];
		NSData *data = [prefs objectForKey:@"tweakages"];
		if ([NSKeyedUnarchiver unarchiveObjectWithData:data]) {
			[TMRGlobalData sharedGlobalData].tweakages =
				[NSKeyedUnarchiver unarchiveObjectWithData:data];
			[TMRGlobalData sharedGlobalData].enabledTweakageIndex =
				[[prefs valueForKey:@"activeTweakageIndex"] intValue];
			NSLog(@"TMGRLog: Active Tweakage: %@", [[TMRGlobalData sharedGlobalData].tweakages[[TMRGlobalData sharedGlobalData].enabledTweakageIndex] name]);
			// Load new tweaks into defaults
			NSMutableArray *tweaks = [[NSMutableArray alloc] init];
			NSString *sourcePath = @"/Library/MobileSubstrate/DynamicLibraries/";
			NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourcePath
			                 error:NULL];
			[dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			         NSString *filename = (NSString *)obj;
			         NSString *extension = [filename pathExtension];
			         if ([extension isEqualToString:@"dylib"]) {
			                 Tweak *newTweak = [[Tweak alloc] init];
			                 newTweak.name = filename;
			                 newTweak.enabled = [NSNumber numberWithBool:YES];
			                 [tweaks addObject: newTweak];
				 }
			         if ([ extension isEqualToString:@"TMRDisabled"]) {
			                 Tweak *newTweak = [[Tweak alloc] init];
			                 newTweak.name = [filename stringByReplacingOccurrencesOfString:@".TMRDisabled" withString:@""];
			                 newTweak.enabled = [NSNumber numberWithBool:YES];
			                 [tweaks addObject: newTweak];
				 }
			 }];

			// Build the default tweakge
			Tweakage *defaultTweakage = [[Tweakage alloc] init];
			defaultTweakage.tweaks = tweaks;
			defaultTweakage.name = @"Default";
			// Add the default tweakage
			[TMRGlobalData sharedGlobalData].tweakages[0] = defaultTweakage;
		}
	} else {
		[prefs writeToFile:@"/Applications/TweakManager.app/tweakmanager_prefs.plist" atomically:YES];
		NSLog(@"TMGRLog: No Defaults to load");
	}
}

- (void)respringButtonTapped:(id)sender {
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Applications/TweakManager.app/tweakmanager_prefs.plist"];
	[prefs setValue:[NSString stringWithFormat: @"%ld", [TMRGlobalData sharedGlobalData].enabledTweakageIndex]
	 forKey:@"activeTweakageIndex"];
	[prefs writeToFile:@"/Applications/TweakManager.app/tweakmanager_prefs.plist" atomically:YES];

	// Respring
	pid_t pid;
	const char *args[] = {"sbreload", NULL, NULL, NULL};
	posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char *const *)args, NULL);
}

- (void)addButtonTapped:(id)sender {
	// Load the Tweakage builder
	TMRTweakListViewController *tweakListViewController =
		[[TMRTweakListViewController alloc] init];
	UINavigationController *navigationController = [[UINavigationController alloc]
	                                                initWithRootViewController:tweakListViewController];

	// Ask for a name
	UIAlertController *alert = [UIAlertController
	                            alertControllerWithTitle:@"Tweakage Name"
	                            message:@"Create a name for your tweakage."
	                            preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction *ok = [UIAlertAction
	                     actionWithTitle:@"OK"
	                     style:UIAlertActionStyleDefault
	                     handler:^(UIAlertAction *action) {
	                             UITextField *alertTextField = alert.textFields.firstObject;
	                             tweakListViewController.tweakageName = alertTextField.text;
	                             // Load the tweaklistviewcontroller after dismissing the alert
	                             [self presentViewController:navigationController
	                              animated:YES
	                              completion:nil];
			     }];

	UIAlertAction *cancel =
		[UIAlertAction actionWithTitle:@"Cancel"
		 style:UIAlertActionStyleCancel
		 handler:nil];

	[alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
	         textField.placeholder = @"Darkmode";
	 }];

	[alert addAction:ok];
	[alert addAction:cancel];

	[self presentViewController:alert animated:YES completion:nil];
}

- (void)handle_data {
	// Update the data
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Applications/TweakManager.app/tweakmanager_prefs.plist"];
	NSData *data = [NSKeyedArchiver
	                archivedDataWithRootObject:[TMRGlobalData sharedGlobalData].tweakages];
	[prefs setObject:data forKey:@"tweakages"];
	[prefs writeToFile:@"/Applications/TweakManager.app/tweakmanager_prefs.plist" atomically:YES];

	[[self tableView] reloadData];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
        numberOfRowsInSection:(NSInteger)section {
	if (section == 0)
		return 1;
	if (section == 1)
		return [[[TMRGlobalData sharedGlobalData] tweakages] count];
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell =
		[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (indexPath.section == 1) {
		if (!cell) {
			cell =
				[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
				  reuseIdentifier:CellIdentifier] autorelease];
		}

		NSString *name =
			[[TMRGlobalData sharedGlobalData].tweakages[indexPath.row] name];
		// If it's the enabled tweak, do visual disabling
		if ([TMRGlobalData sharedGlobalData].enabledTweakageIndex ==
		    indexPath.row) {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.text = [name stringByAppendingString:@" (Enabled)"];
			cell.textLabel.textColor = [UIColor grayColor];
		} else {
			cell.textLabel.text = name;
			cell.textLabel.textColor = [UIColor blackColor];
		}
		return cell;
	} else {
		if (!cell) {
			cell =
				[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
				  reuseIdentifier:CellIdentifier] autorelease];
		}

		NSString *name = [[TMRGlobalData sharedGlobalData].tweakages[
					  [TMRGlobalData sharedGlobalData].enabledTweakageIndex] name];
		cell.textLabel.text = name;
		return cell;
	}
}

- (NSArray *)tableView:(UITableView *)tableView
        editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Don't add options if the tweak is enabled
	if (indexPath.row != [TMRGlobalData sharedGlobalData].enabledTweakageIndex &&
	    indexPath.section == 1 &&
	    ![[[TMRGlobalData sharedGlobalData].tweakages[indexPath.row] name]
	      isEqual:@"Default"]) {
		// Copy Action
		UITableViewRowAction *copyAction = [UITableViewRowAction
		                                    rowActionWithStyle:UITableViewRowActionStyleNormal
		                                    title:@"Copy"
		                                    handler:^(UITableViewRowAction *action,
		                                              NSIndexPath *indexPath) {
		                                            // Ask for a name
		                                            UIAlertController *alert = [UIAlertController
		                                                                        alertControllerWithTitle:[NSString stringWithFormat:@"%@ Copy.", [TMRGlobalData sharedGlobalData]
		                                                                                                  .tweakages[indexPath.row].name]
		                                                                        message:@"Use a different name."
		                                                                        preferredStyle:UIAlertControllerStyleAlert];

		                                            UIAlertAction *ok = [UIAlertAction
		                                                                 actionWithTitle:@"OK"
		                                                                 style:UIAlertActionStyleDefault
		                                                                 handler:^(UIAlertAction *action) {
		                                                                         UITextField *alertTextField = alert.textFields.firstObject;
		                                                                         Tweakage *newTweakage = [[Tweakage alloc] init];
		                                                                         newTweakage.name = alertTextField.text;
		                                                                         newTweakage.tweaks = [TMRGlobalData sharedGlobalData]
		                                                                                              .tweakages[indexPath.row].tweaks;
		                                                                         [[TMRGlobalData sharedGlobalData].tweakages addObject:newTweakage];
		                                                                         NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Applications/TweakManager.app/tweakmanager_prefs.plist"];
		                                                                         NSData *data = [NSKeyedArchiver
		                                                                                         archivedDataWithRootObject:[TMRGlobalData sharedGlobalData].tweakages];
		                                                                         [prefs setObject:data forKey:@"tweakages"];
		                                                                         [prefs writeToFile:@"/Applications/TweakManager.app/tweakmanager_prefs.plist" atomically:YES];

		                                                                         [[self tableView] reloadData];
										 }];

		                                            UIAlertAction *cancel =
								    [UIAlertAction actionWithTitle:@"Cancel"
								     style:UIAlertActionStyleCancel
								     handler:nil];

		                                            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
		                                                     textField.placeholder = @"Darkmode";
							     }];

		                                            [alert addAction:ok];
		                                            [alert addAction:cancel];

		                                            [self presentViewController:alert animated:YES completion:nil];
						    }];
		copyAction.backgroundColor = [UIColor orangeColor];


		// Edit action
		UITableViewRowAction *editAction = [UITableViewRowAction
		                                    rowActionWithStyle:UITableViewRowActionStyleNormal
		                                    title:@"Edit"
		                                    handler:^(UITableViewRowAction *action,
		                                              NSIndexPath *indexPath) {
		                                            // Display the tweakage edit view controller and pass the
		                                            // index to the controller
		                                            TMRTweakageEditViewController *tweakageEditViewController =
								    [[TMRTweakageEditViewController alloc] init];
		                                            UINavigationController *navigationController =
								    [[UINavigationController alloc]
								     initWithRootViewController:
								     tweakageEditViewController];

		                                            // Pass index of tweakage to view controller
		                                            tweakageEditViewController.tweakageIndex = indexPath.row;

		                                            [self presentViewController:navigationController
		                                             animated:YES
		                                             completion:nil];
						    }];
		editAction.backgroundColor = [UIColor blueColor];

		// Delete action
		UITableViewRowAction *deleteAction = [UITableViewRowAction
		                                      rowActionWithStyle:UITableViewRowActionStyleNormal
		                                      title:@"Delete"
		                                      handler:^(UITableViewRowAction *action,
		                                                NSIndexPath *indexPath) {
		                                              // Create the confirmation alert
		                                              UIAlertController *alert = [UIAlertController
		                                                                          alertControllerWithTitle:@"Are you sure?"
		                                                                          message:@"Are you sure you want to "
		                                                                          @"delete this tweakage?"
		                                                                          preferredStyle:UIAlertControllerStyleAlert];

		                                              UIAlertAction *yesAction = [UIAlertAction
		                                                                          actionWithTitle:@"Yes"
		                                                                          style:UIAlertActionStyleDefault
		                                                                          handler:^(UIAlertAction *action) {
		                                                                                  [[TMRGlobalData sharedGlobalData].tweakages
		                                                                                   removeObjectAtIndex:indexPath.row];
		                                                                                  [tableView
		                                                                                   deleteRowsAtIndexPaths:
		                                                                                   [NSArray arrayWithObject:indexPath]
		                                                                                   withRowAnimation:
		                                                                                   UITableViewRowAnimationFade];
		                                                                                  NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Applications/TweakManager.app/tweakmanager_prefs.plist"];
		                                                                                  NSData *data = [NSKeyedArchiver
		                                                                                                  archivedDataWithRootObject:[TMRGlobalData sharedGlobalData].tweakages];
		                                                                                  [prefs setValue:[NSString stringWithFormat: @"%ld", [TMRGlobalData sharedGlobalData].enabledTweakageIndex]
		                                                                                   forKey:@"activeTweakageIndex"];
		                                                                                  [prefs setObject:data forKey:@"tweakages"];
		                                                                                  [prefs writeToFile:@"/Applications/TweakManager.app/tweakmanager_prefs.plist" atomically:YES];
											  }];

		                                              UIAlertAction *cancelAction =
								      [UIAlertAction actionWithTitle:@"Cancel"
								       style:UIAlertActionStyleCancel
								       handler:nil];
		                                              // Add actions
		                                              [alert addAction:yesAction];
		                                              [alert addAction:cancelAction];

		                                              // Present
		                                              [self presentViewController:alert
		                                               animated:YES
		                                               completion:nil];
						      }];
		deleteAction.backgroundColor = [UIColor redColor];

		return @[ deleteAction, editAction, copyAction];
	} else {
		return @[];
	}
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView
        didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	// Only run if the tweakage tapped is disabled
	if (indexPath.section == 1 &&
	    indexPath.row != [TMRGlobalData sharedGlobalData].enabledTweakageIndex) {
		// Load the default tweak
		for (Tweak *tweak in [TMRGlobalData sharedGlobalData].tweakages[0].tweaks) {
			NSFileManager *fileManager = [NSFileManager defaultManager];
			NSString *tweakPath = [@"/Library/MobileSubstrate/DynamicLibraries/"
			                       stringByAppendingString:tweak.name];
			if (tweak.enabled == [NSNumber numberWithBool:YES]) {

				if (![fileManager fileExistsAtPath:tweakPath]) {
					[[NSFileManager defaultManager]
					 moveItemAtPath:[tweakPath stringByAppendingString:@".TMRDisabled"]
					 toPath:tweakPath
					 error:nil];
				}
			} else {
				if ([fileManager fileExistsAtPath:tweakPath]) {
					[[NSFileManager defaultManager]
					 moveItemAtPath:tweakPath
					 toPath:[tweakPath stringByAppendingString:@".TMRDisabled"]
					 error:nil];
				}
			}
		}
		// Set the index of the new tweakage
		[TMRGlobalData sharedGlobalData].enabledTweakageIndex = indexPath.row;
		NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Applications/TweakManager.app/tweakmanager_prefs.plist"];
		[prefs setValue:[NSString stringWithFormat: @"%ld", [TMRGlobalData sharedGlobalData].enabledTweakageIndex]
		 forKey:@"activeTweakageIndex"];
		[prefs writeToFile:@"/Applications/TweakManager.app/tweakmanager_prefs.plist" atomically:YES];
		for (Tweak *tweak in [TMRGlobalData sharedGlobalData]
		     .tweakages[[TMRGlobalData sharedGlobalData].enabledTweakageIndex]
		     .tweaks) {
			NSFileManager *fileManager = [NSFileManager defaultManager];
			NSString *tweakPath = [@"/Library/MobileSubstrate/DynamicLibraries/"
			                       stringByAppendingString:tweak.name];
			if (tweak.enabled == [NSNumber numberWithBool:YES]) {

				if (![fileManager fileExistsAtPath:tweakPath]) {
					NSError *error = nil;
					BOOL fileWorked = [fileManager
					                   moveItemAtPath:[tweakPath stringByAppendingString:@".TMRDisabled"]
					                   toPath:tweakPath
					                   error:&error];
					if (!fileWorked) {
						NSLog(@"TMGRLog: Renaming Error: %@", [error localizedDescription]);
					}
				}
			} else {
				if ([fileManager fileExistsAtPath:tweakPath]) {
					NSError *error = nil;
					BOOL fileWorked = [fileManager
					                   moveItemAtPath:tweakPath
					                   toPath:[tweakPath stringByAppendingString:@".TMRDisabled"]
					                   error:&error];
					if (!fileWorked) {
						NSLog(@"TMGRLog: Renaming Error: %@", [error localizedDescription]);
					}
				}
			}
		}

		[[self tableView] reloadData];
	}
}

- (NSString *)tableView:(UITableView *)tableView
        titleForHeaderInSection:(NSInteger)section {
	if (section == 0)
		return @"Enabled";
	if (section == 1)
		return @"Disabled";
	return @"What the hell have you done!!!!";
}

@end
