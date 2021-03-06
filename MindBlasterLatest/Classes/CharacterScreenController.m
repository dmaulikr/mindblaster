//
//  CharacterScreenController.m
//  MindBlaster
//
//  Created by Steven Verner on 2/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CharacterScreenController.h"
#import "GlobalAdmin.h"

@implementation CharacterScreenController
@synthesize charOne;
@synthesize charTwo;
@synthesize charThree;
@synthesize charFour;

-(IBAction) helpScreen {
	// Navigation logic may go here -- for example, create and push another view controller.
	HelpScreenController *helpView = [[HelpScreenController alloc] initWithNibName:@"HelpScreenController" bundle:nil];
	[self.navigationController pushViewController:helpView animated:YES];
	[helpView release];
}

/*
 The following will save an image to the user profile data.
 */
- (IBAction) firstCharacterSelected {
	
	[UIAppDelegate.currentUser setProfilePic: PICTURE_BOY];
	
    // Navigation logic may go here -- for example, create and push another view controller.
	UserNameScreenController *userNameView = [[UserNameScreenController alloc] initWithNibName:@"UserNameScreenController" bundle:nil];
	[self.navigationController pushViewController:userNameView animated:YES];
	[userNameView release];
}

- (IBAction) secondCharacterSelected {
	
	[UIAppDelegate.currentUser setProfilePic: PICTURE_GIRL];
	
    // Navigation logic may go here -- for example, create and push another view controller.
	UserNameScreenController *userNameView = [[UserNameScreenController alloc] initWithNibName:@"UserNameScreenController" bundle:nil];
	[self.navigationController pushViewController:userNameView animated:YES];
	[userNameView release];
}

- (IBAction) thirdCharacterSelected {
	
	[UIAppDelegate.currentUser setProfilePic: PICTURE_DOG];
	
    // Navigation logic may go here -- for example, create and push another view controller.
	UserNameScreenController *userNameView = [[UserNameScreenController alloc] initWithNibName:@"UserNameScreenController" bundle:nil];
	[self.navigationController pushViewController:userNameView animated:YES];
	[userNameView release];
}

- (IBAction) fourthCharacterSelected {
	
	[UIAppDelegate.currentUser setProfilePic: PICTURE_CAT];
	
    // Navigation logic may go here -- for example, create and push another view controller.
	UserNameScreenController *userNameView = [[UserNameScreenController alloc] initWithNibName:@"UserNameScreenController" bundle:nil];
	[self.navigationController pushViewController:userNameView animated:YES];
	[userNameView release];
}

// go back to the previous screen
-(IBAction)backScreen {
	
	[self.navigationController popViewControllerAnimated:TRUE];
	
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */


// animate the space background
-(void)animateBackground {
	
	[background move];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	[self.navigationController setTitle: @"characterView"];
	
	[self.navigationController setNavigationBarHidden:TRUE animated: NO ];
	
	[NSTimer scheduledTimerWithTimeInterval:0.03 target:self
								   selector:@selector(animateBackground) userInfo:nil repeats:YES];
	[background setSpeedX:0.2 Y:0.2];
	
}

// delegate function that runs every time the view returns from "back" of another screen
- (void)viewWillAppear:(BOOL)animated {
	
    [super viewWillAppear:animated];
	NSLog(@"character view will appear.");
}


// delegate function that runs every time the view returns from "back" of another screen
- (void)viewDidAppear:(BOOL)animated {
    
	[super viewDidAppear:animated];
	NSLog(@"charcter view did appear.");
	[self.navigationController setTitle: @"characterView"];
	
	[[UIApplication sharedApplication] setStatusBarHidden: YES animated: NO];
	
}

- (void) viewWillDisappear:(BOOL)animated {
	
	// play button click
	[MindBlasterAppDelegate playButtonClick];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

// override to allow orientations other than the default portrait orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc {
    [super dealloc];
}


@end
