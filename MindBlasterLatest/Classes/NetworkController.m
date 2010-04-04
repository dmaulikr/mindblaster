//
//  NetworkController.m
//  MindBlaster
//
//  Created by yaniv haramati on 21/03/10. 
//	Borrows heavily from the CFnetwork tutorial on the mac dev forum 
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NetworkController.h"


@interface NetworkController ()
// Properties that don't need to be seen by the outside world.


@property (nonatomic, readonly) BOOL              isSending;
//@property (nonatomic, retain)   NSOutputStream *  networkStream;
//@property (nonatomic, retain)   NSInputStream *   fileStream;
@property (nonatomic, readonly) uint8_t *         buffer;
@property (nonatomic, assign)   size_t            bufferOffset;
@property (nonatomic, assign)   size_t            bufferLimit;


@end

@implementation NetworkController

//@synthesize fileText;
//@synthesize connection    = _connection;

@synthesize fileStreamIn, fileStreamOut;
@synthesize fileStreamIn, fileStreamOut, networkStreamIn, networkStreamOut; 
@synthesize connection;
@synthesize statusLabel;
@synthesize activityIndicator, emailDown, emailUp;
@synthesize webView;
@synthesize uploadButton, downloadButton;


#pragma mark * Status management

// These methods are used by the core transfer code to update the UI.

// navigate back to the root menu
-(IBAction) backScreen {
	
	// navigate to the help menu
	[self.navigationController popViewControllerAnimated:TRUE];
}

// show the text field after the keyboard is gone
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[emailDown resignFirstResponder];
	[emailUp resignFirstResponder];
	return YES;
}

// updates the DB by accessing the update php URL
-(void) updateDBUpload {
	
	NSString *urlString = [[NSString alloc] initWithFormat: @"%@%@", [GlobalAdmin getUploadUpdateURL], emailUp.text];
	NSLog(@"upload url: %@", urlString);
	NSURL *url = [NSURL URLWithString: urlString];
	[urlString release];
	NSURLRequest *request = [NSURLRequest requestWithURL: url];
	
	// make sure connection established
	NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest: request delegate: self startImmediately: YES];
	if (urlConnection ){
		NSLog(@"upload script invoked.");
	}
	else {
		NSLog(@"upload script failed to invoke.");
	}
	[urlConnection release];
	//[webView loadRequest: request];
	
}

// updates the DB by accessing the update php URL with email as parameter
-(void) updateDBDownload {
	
	// attach the email to the url
	NSString *urlWithEmail = [[NSString alloc] initWithFormat: @"%@%@", 
							  [GlobalAdmin getDownloadUpdateURL], emailDown.text];
	NSLog(@"%@", urlWithEmail);
	
	NSURL *url = [NSURL URLWithString: urlWithEmail];
	[urlWithEmail release];
	NSURLRequest *request = [NSURLRequest requestWithURL: url];
	
	// make sure connection is established and wait for 20 seconds
	// to allow the server to enact the profile overwrite.
	NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest: request delegate: self startImmediately: YES];
	if (urlConnection ){
		NSLog(@"download script invoked.");
	}
	else {
		NSLog(@"download script failed to invoke.");
	}
	[urlConnection release];
	
}

// delegate method for NSURLConnection
// activated once the script for either upload or download is finished loading, and download can begin
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"connection did finish loading");
	if (connectionType == DOWNLOAD) {
		
		NSLog(@"finished loading download update script");
	}
	if (connectionType == UPLOAD) {
		
		NSLog(@"finished loading upload script");
	}
		
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

// user pressed the download button
// get their email before progressing
-(IBAction) downloadRequested {
	
	connectionType = DOWNLOAD;
	
	if ( [self getEmailFromHiddenField]) {
		
		[UIAppDelegate.currentUser setEmail: emailDown.text];
		[statusLabel setText: @""];
		[emailDown setEnabled: NO];
		emailDown.hidden = YES;
		
		[self download];
		
		// no longer necessary
		//[self updateDBDownload];
	}
	else
		[statusLabel setText: @"Must enter email."];
}

// user pressed the upload button
// get their email before progressing
-(IBAction) uploadRequested {
	
	connectionType = UPLOAD;
	
	if ( [self getEmailFromHiddenField]) {
		
		[UIAppDelegate.currentUser setEmail: emailUp.text];
		[statusLabel setText: @""];
		[emailUp setEnabled: NO];
		emailUp.hidden = YES;

		// attach the email as the url parameter
		NSString *urlWithEmail = [[NSString alloc] initWithFormat: @"%@%@", 
								  [GlobalAdmin getUploadFolderCheckURL], emailUp.text];
		NSLog(@"%@", urlWithEmail);
		
		NSURL *url = [NSURL URLWithString: urlWithEmail];
		[urlWithEmail release];
		NSURLRequest *request = [NSURLRequest requestWithURL: url];
		
		// load the url and parse the reponse to see if folder was created so we can write to it.
		NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest: request delegate: self startImmediately: YES];
		
		if (urlConnection ){
			NSLog(@"upload folder check URL connected.");
		}
		else {
			NSLog(@"upload folder check URL failed to connect.");
		}
		
		NSError *fcError;
		NSURLResponse *fcResponse;
		
		// get response
		NSData *fcData = [NSURLConnection sendSynchronousRequest: request
						returningResponse: &fcResponse error: &fcError];
		
		// response positive => folder created. write to it.
		if ([self parseFolderCheckResponse: fcData]) {
			
			NSLog(@"folder created.");
			[self upload];
		}
		// response negative => folder not created. fail.
		else {
			
			NSLog(@"failed to create folder.");
			[statusLabel setText: @"Error while uploading, try again."];
			
		}
		
		// release connection
		[urlConnection release];
		
	}
	// user didn't enter email.
	else
		[statusLabel setText: @"Must enter email."];
}

// check response of folder check URL
// returns YES if folder was created, NO otherwise.
-(BOOL) parseFolderCheckResponse: (NSData*)data {

	// for testing
	return YES;
}


// prompt the user for an email address
// or notify them of failure
- (BOOL) getEmailFromHiddenField {
	
	UITextField *email;
	if (connectionType == UPLOAD){
		email = emailUp;
	}
	else {
		email = emailDown;
	}
	// return YES if email has been already entered with a non empty value
	if (email.text != nil && ! [email.text isEqualToString:@""]) {
		
		return YES;
	}
	else  {
		
		[statusLabel setText: @"Enter your email address."];
		[email setEnabled: YES];
		email.hidden = NO;
		return NO;
	}
}


// returns YES if network connection found, otherwise NO.
// function taken from : http://www.iphonedevsdk.com/forum/iphone-sdk-development/7300-test-if-internet-connection-available.html
// with permission of author.
- (BOOL) connectedToNetwork {
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
	
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return 0;
    }
	
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	
    BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;
	
	return ((isReachable && !needsConnection) || nonWiFi) ? YES : NO;
	
}

// display help for the load profile menu
-(IBAction) helpScreen {
	
	// Navigation logic may go here -- for example, create and push another view controller.
	HelpScreenController *helpView = [[HelpScreenController alloc] initWithNibName:@"HelpScreenController" bundle:nil];
	[self.navigationController pushViewController:helpView animated:YES];
	[helpView release];
}


- (void)_updateStatus:(NSString *)statusString {
	
	NSLog(@"inside _upadateStatus");
    //assert(statusString != nil);
   // self.statusLabel.text = statusString;
}

- (void)_sendDidStopWithStatus:(NSString *)statusString {
	
	NSLog(@"starting _sendDidStopWithStatus");
    if (statusString == nil) {
        //statusString = @"Put succeeded";
    }
    //self.statusLabel.text = statusString;
   // self.cancelButton.enabled = NO;
    //[self.activityIndicator stopAnimating];
	//[[AppDelegate sharedAppDelegate] didStartNetworking];
}


#pragma mark * Core transfer code

// This is the code that actually does the networking.

@synthesize bufferOffset  = _bufferOffset;
@synthesize bufferLimit   = _bufferLimit;

// Because buffer is declared as an array, you have to use a custom getter.  
// A synthesised getter doesn't compile.

- (uint8_t *)buffer {
	
	NSLog(@"inside buffer");
    return self->_buffer;
}

- (BOOL)isSending {
	
	NSLog(@"inside isSending");
    return (self.networkStreamOut != nil);
	
}

- (void)_stopSendWithStatus:(NSString *)statusString
{
    if (self.networkStreamOut != nil) {
        [self.networkStreamOut removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.networkStreamOut.delegate = nil;
        [self.networkStreamOut close];
        self.networkStreamOut = nil;
    }
    if (self.fileStreamIn != nil) {
        [self.fileStreamIn close];
        self.fileStreamIn = nil;
    }
   // [self _sendDidStopWithStatus:statusString];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our 
// network stream.
{
#pragma unused(aStream)
	
	NSLog(@"beginning of stream");
    //assert(aStream == self.networkStream);
	
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            [self _updateStatus:@"Opened connection"];
        } break;
        case NSStreamEventHasBytesAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventHasSpaceAvailable: {
            [self _updateStatus:@"Sending"];
            
            // If we don't have any data buffered, go read the next chunk of data.
            
            if (self.bufferOffset == self.bufferLimit) {
                NSInteger   bytesRead;
                
                bytesRead = [self.fileStreamIn read:self.buffer maxLength:kSendBufferSize];
                
                if (bytesRead == -1) {
                    [self _stopSendWithStatus:@"File read error"];
                } else if (bytesRead == 0) {
                    [self _stopSendWithStatus:nil];
                } else {
                    self.bufferOffset = 0;
                    self.bufferLimit  = bytesRead;
                }
            }
            
            // If we're not out of data completely, send the next chunk.
            
            if (self.bufferOffset != self.bufferLimit) {
                NSInteger   bytesWritten;
                bytesWritten = [self.networkStreamOut write:&self.buffer[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
                assert(bytesWritten != 0);
                if (bytesWritten == -1) {
                    [self _stopSendWithStatus:@"Network write error"];
                } else {
                    self.bufferOffset += bytesWritten;
                }
            }
        } break;
        case NSStreamEventErrorOccurred: {
			NSLog(@"stream event error encountered");
			[self failedConnectionResponse];
            [self _stopSendWithStatus:@"Stream open error"];
        } break;
        case NSStreamEventEndEncountered: {
			NSLog(@"stream event end encountered");
            // ignore
        } break;
        default: {
            assert(NO);
        } break;
    }
	NSLog(@"end of stream");
}

// update the label if no internet connection is found
-(void) failedConnectionResponse {
	
	[statusLabel setText: @"Couldn't connect..."];
	
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

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	connectionType = -1;
	
	[self.navigationController setTitle: @"networkView"];
	
	// initialize email
	emailDown.text = nil;
	[emailDown setEnabled: NO];
	emailDown.hidden = YES;
	
	emailUp.text = nil;
	[emailUp setEnabled: NO];
	emailUp.hidden = YES;
	
	[self.navigationController setNavigationBarHidden:TRUE animated: NO ];
	
	// test for an internet connection
	// if none was found
	if (! [self connectedToNetwork]) {
		
		NSLog(@"no connection.");
		[downloadButton setEnabled: NO];
		[uploadButton setEnabled: NO];
		self.statusLabel.text = @"No Connection Available.";
	}
	else {
		NSLog(@"connection found.");
		[downloadButton setEnabled: YES];
		[uploadButton setEnabled: YES];
		self.statusLabel.text = @"";
		
	}
    
	NSLog(@"end of viewDidLoad");

}

// delegate function that runs whenever view appears (when returning from subview, etc.)
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	//self.activityIndicator.hidden = NO;
    //self.usernameText.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"Username"];
    //self.passwordText.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"Password"];
}


// delegate function that runs every time the view returns from "back" of another screen
- (void)viewDidAppear:(BOOL)animated {
    
	[super viewDidAppear:animated];
	NSLog(@"network view did appear.");
	[self.navigationController setTitle: @"networkView"];
	
}

- (void) viewWillDisappear:(BOOL)animated {
	
	// play button click
	[MindBlasterAppDelegate playButtonClick];
}

// converts email string to md5 string
-(id) emailToMD5: (NSString*) email {
	
	// for testing
	return [[[NSString alloc] initWithString: @"28734823"] autorelease];
}


// download a file
-(IBAction) download {	
		
	assert (emailDown.text != nil && ! [emailDown.text isEqualToString: @""]);
	
	NSString *md5Email = [self emailToMD5: emailDown.text];
	
	// run the update script before downloading
	//NSLog(@"updating the download DB script");
	//NSLog(@"email: %@",[UIAppDelegate.currentUser email]);
	//[self updateDBDownload];

	
	// save path
	//NSString *fileString = [[GlobalAdmin getPath] retain];
	NSString *fileString = [GlobalAdmin getPath];
	
	// first delete the current profile if it exists.
	if([[NSFileManager defaultManager] fileExistsAtPath: fileString ]) {
		
		if ( [[NSFileManager defaultManager] removeItemAtPath: fileString error: nil] )
			NSLog(@"existing profile deleted.");
		else
			NSLog(@"Failed to delete existing profile");
	}
	
/*
	// set the send-to-file stream
	self.fileStreamOut = [NSOutputStream outputStreamToFileAtPath: fileString append:NO];
	[self.fileStreamOut open];
*/
	
	NSLog(@"md5: %@",[GlobalAdmin getURL]);
	
	// read plist into a dictionary
	NSString *urlString = [[NSString alloc] initWithFormat: @"%@%@/UserProfile.plist", [GlobalAdmin getURL],  md5Email];
	
	// for debug: 
	NSLog(@"downloading: %@", urlString);
	
	NSURL *url = [[NSURL URLWithString: urlString] retain];
	assert (url != nil);
	[urlString release];
	
/*	
	self.connection = [NSURLConnection connectionWithRequest: request delegate: self];
	assert(self.connection != nil);
*/

	//self.activityIndicator.hidden = NO;
	//[self.activityIndicator startAnimating];
	
	//NSDictionary *profile = [[NSDictionary alloc] initWithContentsOfFile: fileString];
	NSDictionary *profile = [[NSDictionary alloc] initWithContentsOfURL: url];
	
	// start UI progress indicators
	//[self.activityIndicator stopAnimating];
	//self.activityIndicator.hidden = YES;

	NSLog(@"Saving to file: %@", fileString);

	[profile writeToFile: fileString atomically: YES];
	[url release];
	[profile release];
	
	self.statusLabel.text = @"Download Complete.";
	[UIAppDelegate didStartNetworking];
	
	NSLog(@"finished download");
	connectionType = -1;
}

// upload a file
-(IBAction)upload {
	
	connectionType == UPLOAD;
	
	NSString *md5Email = [self emailToMD5: emailDown.text];
	
	// get the ftp url from ApplicationSettings.plist
	NSString *urlString = [[NSString alloc] initWithFormat: @"%@%@/UserProfile.plist", [GlobalAdmin getURL],  md5Email];
	NSLog(@"upload URL path: %@",urlString);

	// get the local file path for the profile
	NSString *fileString = [GlobalAdmin getPath];
	
	NSLog(@"upload file path: %@",fileString);
	
	// create the url
	NSURL *url = [NSURL URLWithString: urlString];
	[urlString release];
	
	// make sure we have a file to upload
	if ( [[NSFileManager defaultManager] fileExistsAtPath: fileString ] ) 
	{
	
		// for debugging
		NSLog(@"uploading: %@", fileString);
		NSLog(@"to: %@", urlString);
	
		// update UI indicators
		self.statusLabel.text = @"Upload Started.";
		//self.activityIndicator.hidden = NO;
		//[self.activityIndicator startAnimating];
	
		// set the streams
		self.fileStreamIn = [NSInputStream inputStreamWithFileAtPath: fileString];
	
		[self.fileStreamIn open];
		CFWriteStreamRef ftpStream = CFWriteStreamCreateWithFTPURL(NULL, (CFURLRef) url);
	
		self.networkStreamOut = (NSOutputStream *) ftpStream;
	
		self.networkStreamOut.delegate = self;
		[self.networkStreamOut scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
		// and send
		[self.networkStreamOut open];
	
		// Have to release ftpStream to balance out the create.  self.networkStream 
		// has retained this for our persistent use.
		CFRelease(ftpStream);
		
		self.statusLabel.text = @"Upload Complete.";
		//[self.activityIndicator stopAnimating];
		//self.activityIndicator.hidden = YES;
		
	}
	// we have no profile to upload
	else {
		
		self.statusLabel.text = @"No profile available.";
	}
	
	//[self didStartNetworking];
	 NSLog(@"end of upload");

	// update the upload script
	NSLog(@"updating upload script");
	[self updateDBUpload];
	
	connectionType = -1;
}

// to be implemented
-(void) didStartNetworking {
	NSLog(@"inside didStartNetworking");
	//[activityIndicator startAnimating];
}


// to be implemented
-(void) didStopNetworking {
	NSLog(@"inside didStopNetworking");
	//[activityIndicator stopAnimating];
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
	NSLog(@"inside didReceieveMemoryWatning");
	// Release any cached data, images, etc that aren't in use.
}

// plays an inside click when hitting email or name text edit panes
-(IBAction) playClick {
	
	// play inside click
	[MindBlasterAppDelegate playInsideClick];
}

- (void)viewDidUnload
{
	NSLog(@"started viewDidUnload");
    self.statusLabel = nil;
    self.activityIndicator = nil;
    //self.cancelButton = nil;
	[super viewDidUnload];
}

- (void)dealloc
{

    //[self _stopSendWithStatus:@"Stopped"];
    [super dealloc];
}


@end
