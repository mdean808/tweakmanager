#import "TMRGlobalData.h"
#import "TMRAppDelegate.h"
#import "TMRRootViewController.h"
#import "TMRTweakageEditViewController.h"
#import "TweakManager.h"

@implementation TMRTweakageEditViewController {
}

- (void)loadView {
	// Setup the view
	[super loadView];
	self.title = [NSString stringWithFormat:@"Edit %@", [TMRGlobalData sharedGlobalData].tweakages[_tweakageIndex].name];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Modify" style:UIBarButtonItemStylePlain target:self action:@selector(modifyButtonTapped:)] autorelease];
	[[self tableView] reloadData];
}


- (void) doneButtonTapped:(id)sender {
	// send notificaiton to update the root view controller
	[[NSNotificationCenter defaultCenter] postNotificationName:@"reload_data" object:self];
	// Display the root view controller
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void) modifyButtonTapped:(id)sender {
	UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Modify" message:@"Change tweakage settings." preferredStyle:UIAlertControllerStyleActionSheet];

	[actionSheet addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
	                                // Dissmiss the alert.
				}]];
	[actionSheet addAction:[UIAlertAction actionWithTitle:@"Change Name" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
	                                // Open name changer
	                                UIAlertController *alert = [UIAlertController
	                                                            alertControllerWithTitle:@"Tweakage Name"
	                                                            message:@"Edit your tweakage name."
	                                                            preferredStyle:UIAlertControllerStyleAlert];

	                                UIAlertAction *ok = [UIAlertAction
	                                                     actionWithTitle:@"OK"
	                                                     style:UIAlertActionStyleDefault
	                                                     handler:^(UIAlertAction *action) {
	                                                             UITextField *alertTextField = alert.textFields.firstObject;
	                                                             // Update the tweakage name
	                                                             [TMRGlobalData sharedGlobalData].tweakages[_tweakageIndex].name = alertTextField.text;
							     }];

	                                UIAlertAction *cancel =
						[UIAlertAction actionWithTitle:@"Cancel"
						 style:UIAlertActionStyleCancel
						 handler:nil];

	                                [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
	                                         textField.placeholder = [TMRGlobalData sharedGlobalData].tweakages[_tweakageIndex].name;
					 }];

	                                [alert addAction:ok];
	                                [alert addAction:cancel];

	                                [self presentViewController:alert animated:YES completion:nil];
	                                [[NSNotificationCenter defaultCenter] postNotificationName:@"reload_data" object:self];
				}]];
	[actionSheet addAction:[UIAlertAction actionWithTitle:@"Select All" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
	                                for (Tweak *tweak in [TMRGlobalData sharedGlobalData].tweakages[_tweakageIndex].tweaks) {
	                                        [tweak setValue:[NSNumber numberWithBool:YES] forKey:@"enabled"];
					}
	                                [[self tableView] reloadData];
	                                [[NSNotificationCenter defaultCenter] postNotificationName:@"reload_data" object:self];
				}]];
	[actionSheet addAction:[UIAlertAction actionWithTitle:@"Diselect All (May Cause Issues)" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
	                                for (Tweak *tweak in [TMRGlobalData sharedGlobalData].tweakages[_tweakageIndex].tweaks) {
	                                        [tweak setValue:[NSNumber numberWithBool:NO] forKey:@"enabled"];
					}
	                                [[self tableView] reloadData];
	                                [[NSNotificationCenter defaultCenter] postNotificationName:@"reload_data" object:self];
				}]];
	[actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete Tweakage" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
	                                [[TMRGlobalData sharedGlobalData].tweakages
	                                 removeObjectAtIndex:_tweakageIndex];
	                                [self dismissViewControllerAnimated:YES completion:^{}];
	                                [[NSNotificationCenter defaultCenter] postNotificationName:@"reload_data" object:self];

				}]];
	// Present action sheet.
	[self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [TMRGlobalData sharedGlobalData].tweakages[_tweakageIndex].tweaks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}

	Tweak *tweak = [TMRGlobalData sharedGlobalData].tweakages[_tweakageIndex].tweaks[indexPath.row];
	NSLog(@"FilenameFromCell: %@", tweak.name);
	cell.textLabel.text = tweak.name;
	if (tweak.enabled == [NSNumber numberWithBool:YES]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
	if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryNone) {
		[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
		[[TMRGlobalData sharedGlobalData].tweakages[_tweakageIndex].tweaks[indexPath.row] setValue:[NSNumber numberWithBool:YES] forKey:@"enabled"];
	} else {
		[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
		[[TMRGlobalData sharedGlobalData].tweakages[_tweakageIndex].tweaks[indexPath.row] setValue:[NSNumber numberWithBool:NO] forKey:@"enabled"];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSLog(@"Tweak: %@, Enabled: %@", [[TMRGlobalData sharedGlobalData].tweakages[_tweakageIndex].tweaks[indexPath.row] valueForKey:@"name"], [[TMRGlobalData sharedGlobalData].tweakages[_tweakageIndex].tweaks[indexPath.row] valueForKey:@"enabled"]);
}

@end
