//
//  GameScreenController.m
//  MindBlaster
//
//  Created by Steven Verner on 2/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//test comment

#import "GameScreenController.h"


@implementation GameScreenController

@synthesize background, profilePic, difficultyLabel;

@synthesize shipIcon, ship;
@synthesize asteroid0, asteroid1, asteroid2, asteroid3, asteroid4, asteroid5, asteroid6, asteroid7, asteroid8, asteroid9;
//@synthesize asteroidIcons;  //this is the vector which will hold all of the above asteroid objects

@synthesize rotationBall;

@synthesize bullet0, bullet1, bullet2, bullet3, bullet4, bullet5;
//@synthesize bullets; //this is the vector which will hold all of the above bullet objects

@synthesize question, questionLabel, scoreLabel;
@synthesize solutionLabel0,solutionLabel1,solutionLabel2,solutionLabel3,solutionLabel4,solutionLabel5;
//@synthesize solutionLabels; //this is the vector which will hold all of the above solution objects


// animate the space background
-(void)animateBackground {
	[background move];
}


// switches between play mode and pause
-(void)setGameTimer; {

	if(gamePaused == FALSE) {
		
		gamePlayTimer = [NSTimer scheduledTimerWithTimeInterval: gamePlayTimerInterval target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
		gamePaused = TRUE;
	}
	else {
		
		[gamePlayTimer invalidate];
		gamePaused = FALSE;
	}
}





// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"started viewDidLoad");
		
	gamePaused = FALSE;
	gamePlayTimerInterval = 0.05;
	
	asteroidIcons = [[NSMutableArray alloc] initWithObjects: asteroid0, asteroid1, asteroid2, asteroid3,
					 asteroid4, asteroid5, asteroid6, asteroid7, asteroid8, asteroid9,nil];
	NSLog(@"allocated asteroidIcons");

	solutionLabels  = [[NSMutableArray alloc] initWithObjects: solutionLabel0, solutionLabel1, solutionLabel2, 
									 solutionLabel3, solutionLabel4, solutionLabel5, nil];
	
	asteroids = [[NSMutableArray alloc] init];
	bullets = [[NSMutableArray alloc] init];
	
	NSLog(@"allocated solutionLabels");
	// set the gamescreen label for the selected difficulty
	[self setDifficultyLabel];
	
	// create a temp object for the initialization
	Asteroid *asteroid;
	
	// initialize shield
	shield = 3;
	
	// initialize lives
	lives = 3;

	NSLog(@"allocated asteroids");
	
	// for all 6 correct/incorrect solution asteroids in the array, attach an image andd a label

	for (int i = 0; i < 10; i++) {
		
		if (i < 6) {
			
			// for the first 6 asteroids attach an image and a label
			[asteroids addObject: [[Asteroid alloc] initWithElements: 
											 [asteroidIcons objectAtIndex: i]: 
											 [solutionLabels objectAtIndex: i]]];
		}
	
		// for all remaining 4 blank asteroids in the array, attach an image but no label
		else {
			NSLog(@"allocating non labled asteroids");
			asteroid = [[Asteroid alloc] init];
			[asteroid setAsteroidIcon: [asteroidIcons objectAtIndex: i]];
			[asteroid setAsteroidSize: CGPointMake(ASTEROID_SIZE_X,ASTEROID_SIZE_Y)];
			[asteroids addObject: asteroid];
			//[asteroid release];
		}
	}
	
	// check their position (debug)
	/*
	for (int i = 0; i < 10; i++) {
		int x = [[asteroids objectAtIndex: i] asteroidPosition].x;
		NSLog(@"class at index %d : %f", i, x);
	}
	 */
 
	// allocate bullet icons to each bullet object
	bulletIcons = [[NSMutableArray alloc] initWithObjects: bullet0,bullet1,bullet2,bullet3,bullet4,bullet5,nil];
	for (int i = 0; i < 6; i++) {
		
		Bullet *bullet = [[Bullet alloc] init];
		[bullet setBulletIcon: [bulletIcons objectAtIndex: i]];
		[bullet setBulletPosition: 0 :500];	// set initial position offscreen so they won't hit asteroids.
		[bullets addObject: bullet];

	}
	
	// reset the position of the bullets to be offscreen
//	[self initializeBulletPosition];
	

	//set the profile pic!
	int picIndex = [UIAppDelegate.currentUser profilePic];
	[profilePic setImage: [GlobalAdmin getPic: picIndex] forState:0];
	//[temp setImage:[(UIAppDelegate.currentUser) getPic] forState:0];

	
	[NSTimer scheduledTimerWithTimeInterval:0.01 target:self
									   selector:@selector(animateBackground) userInfo:nil repeats:YES];
	[background setSpeedX:0.09 Y:0.09];
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem
	//[background move];
	
	// create game objects
	ship = [[Ship alloc] init];				// create the ship object
	[ship setIcon: shipIcon];				// connect the ship icon to the Ship object so it can be rotated
	[ship setPos: CGPointMake(shipIcon.center.x , shipIcon.center.y)];
	
	
	// create game objects
	ship = [[Ship alloc] init];				// create the ship object
	[ship setIcon: shipIcon];				// connect the ship icon to the Ship object so it can be rotated
	[ship setPos: CGPointMake(shipIcon.center.x , shipIcon.center.y)];
	
	// controls movement of bullets and asteroids.
	[self setGameTimer];
	
	// set the initial question
	[self setQuestion];						

	
	// set the score initially to 0
	[UIAppDelegate.currentUser.score setScore: 0];
	
	//values used to describe the direction the ship is facing, derived from the rotation wheel
	shipDirectionX = 0;  
	shipDirectionY = -15;
	//NSLog(@"Post load:   shipX = %f,   shipY = %f", shipDirectionX, shipDirectionY);
	
	//incrementor which denotes the next bullet to be fired, the 0th bullet is fired first
	bulletsFired = 0;
		
    [super viewDidLoad];
}

-(IBAction) pauseButton
{
		[self setGameTimer];
}

// sets the initial location of bullets on screen
/*
-(void)initializeBulletPosition {

	//NSLog(@"starting initializeBulletPosition");
	UIImageView *tempBullet;  //temperary UIImageView allows manipulation of the elements of the bullets array
	for(int i = 0; i < 6;  i++)
	{
		tempBullet = [bulletIcons objectAtIndex:i];
		tempBullet.center = CGPointMake(0,500); //set all bullets starting location as off-screen so they don't destroy any asteroids yet
	}
	
	//NSLog(@"finished initializeBulletPosition");
}
 */


// handle bullet animation and interaction with asteroids
-(IBAction) fireButton{
	
	Bullet *tempBullet  = [bullets objectAtIndex:bulletsFired];
	//assigns element of bullets array to tempBullet to allow manipulation of that element
	
	//sets the bullet being fired's movement vector to the vector defined by the direction in which the ship is pointing
	bulletPos[bulletsFired] = CGPointMake(shipDirectionX,shipDirectionY); 

	// set it to the location of the ship icon
	[tempBullet setBulletPosition: ship.pos.x : ship.pos.y];
	//[tempBullet setBulletDirection: shipDirectionX :shipDirectionY];
	
	tempBullet.bulletIcon.hidden = NO;
	
	
	if(bulletsFired == 5)   //there are only six bullets so once all 6 have been fired start at 0 again
		bulletsFired = 0;
	else
		bulletsFired++;
}

// sets the label for the question according to the profile settings
-(IBAction) setQuestion {
	
	//NSLog(@"starting setQuestion");
	question = [[Question alloc] init];						// create a new question object
	question.questionLabelOutletPointer = questionLabel;	// connect the local outlet to the object outlet

	//set the question on the screen
	//NSLog(@"Calling SetQuestion for question class\n");
	[question setQuestion];

	// set the answers on the asteroid labels
	//NSLog(@"Calling setAnswer on self, next function\n");
	[self setAnswer];
	//[question release];
}

// sets the answers on the asteroid labels
-(void)setAnswer {
	
	// define the solution set of labels on asteroids
	//NSLog(@"starting setAnswer");	
		 
	// determine the correct_answer asteroid randomly and set its value and type
	// because we have 6 labeled asteroids
	int randomCorrectAsteroid = arc4random() % 5;	 // from 0 to 5
	NSString *inputString = [[NSString alloc] initWithFormat:@"%d",(int)[question answer]];
	[[[asteroids objectAtIndex: randomCorrectAsteroid] asteroidLabel] setText: inputString];
		

	// set asteroid type
	[[asteroids objectAtIndex: randomCorrectAsteroid] setAsteroidType:CORRECT_ASTEROID];
	[inputString release];
				
	//NSLog(@"inside setAnswer and random correct asteroid index is : %d", randomCorrectAsteroid);
	
	// sort through the incorrect_answer asteroids and set their value and type and direction
	for(int asteroidIndex = 0; asteroidIndex < 6; asteroidIndex++)
	{
		if (asteroidIndex != randomCorrectAsteroid) {
			
			// set wrong answer equal to some random value of + [1-7] from the correct answer

			// that isn't the correct answer
			int wrongAnswer = 0;
			do {
					wrongAnswer = [question answer] + (arc4random() % 7 * pow(-1, (int)(arc4random() % 7)));
			} while (wrongAnswer == [question answer]);
			NSString *inputString = [[NSString alloc] initWithFormat:@"%d",wrongAnswer];
			[[[asteroids objectAtIndex: asteroidIndex] asteroidLabel] setText: inputString];
			
			// and set the incorrect type
			[[asteroids objectAtIndex: asteroidIndex] setAsteroidType:INCORRECT_ASTEROID];
			
			// then send it on a random path
			[[asteroids objectAtIndex: asteroidIndex] 
			 //setAsteroidDirection:((arc4random() %30 ) / 5  -3) :((arc4random() % 30) / 5 -3)];
								setAsteroidDirection:	arc4random() % ([UIAppDelegate.currentUser.currentTopic difficulty]) : 
														arc4random() % ([UIAppDelegate.currentUser.currentTopic difficulty])];
			[inputString release];
			
			[[asteroids objectAtIndex: asteroidIndex] move]; // this was commented out
		}
	}

	
	// set the blank type on a random path
	for (int asteroidIndex = 6; asteroidIndex < 10; asteroidIndex++) {
		
		[[asteroids objectAtIndex: asteroidIndex] setAsteroidType:BLANK_ASTEROID];
		[[asteroids objectAtIndex: asteroidIndex] 
							setAsteroidDirection:	arc4random() % ([UIAppDelegate.currentUser.currentTopic difficulty]) : 
													arc4random() % ([UIAppDelegate.currentUser.currentTopic difficulty])];
		[[asteroids objectAtIndex: asteroidIndex] move];
	}
	//NSLog(@"end of answer");
}

// updates the difficulty label to the current difficulty in the user profile
-(IBAction) setDifficultyLabel {
	//NSLog(@"start setDifficultyLabel");
	[[UIAppDelegate.currentUser currentTopic] setDifficulty: UIAppDelegate.currentUser.currentTopic.difficulty];
	int diff = [[UIAppDelegate.currentUser currentTopic] difficulty];
	
	//int diff = [UIAppDelegate.currentUser currentDifficulty];
	
	NSString *diffMsg;
	if (diff == 1) diffMsg = @"Easiest";
	if (diff == 2) diffMsg = @"Easy";
	if (diff == 3) diffMsg = @"Hard";
	if (diff == 4) diffMsg = @"Hardest";
	
	NSString *msg = [[NSString alloc] initWithFormat:@"Difficulty: %@", diffMsg];
	[difficultyLabel setText:msg];
	[diffMsg release];
	[msg release];
	//NSLog(@"finished setDifficultyLabel");
	
}

/*
 *	this function is the animation selector for the asteroids and the bullets
 *	it is also where we check for collisions
 */
-(void) onTimer {
	
	
	Bullet *tempBullet;
	
	
	//updates asteroid movement for each of the 10 asteroids, 0-9
	for(int asteroidIndex = 0; asteroidIndex < 10; asteroidIndex++)
	{
		
		[[asteroids objectAtIndex: asteroidIndex] move];
		
	}
	
	
	//updates the bullet movement for each of the 6 bullets and checks for collisions with asteroids 
	//in which case both bullet and asteroid are destroyed
	for(int bulletIndex = 0; bulletIndex < 6; bulletIndex++)
	{
		
		tempBullet = [bullets objectAtIndex: bulletIndex];
		
		//moves bullet
		[tempBullet setBulletPosition: (tempBullet.bulletPosition.x + bulletPos[bulletIndex].x) 
									 : (tempBullet.bulletPosition.y + bulletPos[bulletIndex].y)];
		
		
		
		// hide the bullet if it's offscreen
		if( tempBullet.bulletPosition.x > 486 ||  tempBullet.bulletPosition.x < -6 
		   || tempBullet.bulletPosition.y > 300  ||  tempBullet.bulletPosition.y < -6 ) {
			
			bulletPos[bulletIndex].x = 0;
			bulletPos[bulletIndex].y = 0;
			
			[tempBullet setBulletPosition: 0 : 500];
			tempBullet.bulletIcon.hidden = YES;
		}
		
		//for every asteroid (10 asteroids) check for collision 
		for( int asteroidIndex = 0; asteroidIndex < 10; asteroidIndex++)
		{
			
			//if there is a collision then destroy both asteroid and bullet, hide the bullet and move it off screen and
			//move the asteroid to just above and to the left of the screen so it can move back into the screen area
			//as a new asteroid
			
			// if bullets collide with ANY of the 10 asteroids
			if(  ((tempBullet.bulletPosition.x < [[asteroids objectAtIndex: asteroidIndex] asteroidPosition].x + 20 ) 
				  && (tempBullet.bulletPosition.x > [[asteroids objectAtIndex: asteroidIndex] asteroidPosition].x - 20))
			   &&((tempBullet.bulletPosition.y < [[asteroids objectAtIndex: asteroidIndex] asteroidPosition].y + 20) 
				  && (tempBullet.bulletPosition.y > [[asteroids objectAtIndex: asteroidIndex] asteroidPosition].y - 20)) ) {		
				
				//NSLog(@"asteroid position: %f",[[asteroids objectAtIndex:asteroidIndex]asteroidIcon].center.x);
				//NSLog(@"bullet position: %f", tempBullet.center.x);
				
				// destroy asteroid and bullet by hiding them off screen
				[[asteroids objectAtIndex: asteroidIndex] setAsteroidPosition: -10 :-10];
				[tempBullet setBulletPosition: 0 :500];
				tempBullet.bulletIcon.hidden = YES;
				bulletPos[bulletIndex] = CGPointMake(0,0);
				
			}
			
			// if we have no collision, check the next bullet.
			else continue;
			
			// handle correct/incorrect collision with bullets scenarios
			[self asteroidCollision: asteroidIndex];
			
			// no need to check the other asteroids if we made a hit.
			break;

		} // end of asteroidIndex
	
	} // end of bulletIndex
	
	
	/*
	 *	check for asteroid-asteroid collision and collision with the ship
	 */
	// for every asteroid i
	for (int i = 0; i < 10; i++) {
		
		// and for every asteroid j > i
		for (int j = i + 1; j < 10; j++) {
			
			// check for collision with other asteroids
			[self checkCollisionOf: [asteroids objectAtIndex: i] with : [asteroids objectAtIndex: j]];
		}
		
		// check for collision with the ship
		[self checkCollisionOf: [asteroids objectAtIndex: i] withShip: ship];
		
	}
}

// check collision of asteroid with ship
-(BOOL) checkCollisionOf:(Asteroid*)as withShip:(Ship*)aShip {
	
	if(  ((as.asteroidPosition.x < ship.pos.x + SHIP_SIZE_X / 2 ) 
		  && (as.asteroidPosition.x > ship.pos.x - SHIP_SIZE_X	/ 2))
	   && ((as.asteroidPosition.y < ship.pos.y + SHIP_SIZE_Y / 2) 
		   && (as.asteroidPosition.y > ship.pos.y - SHIP_SIZE_Y / 2)) ) {
		
		// set the asteroid somewhere off screen
		[as setAsteroidPosition: -10 :-10];

		// decrease the shield by a third of its power
		[self decreaseShield];
	
	}
	return NO;
	
}

// reduce the shield of the ship by a third of its power
// and check if lives are lost
-(void) decreaseShield {
	
	// check that shield isn't at 0
	if (shield > 0)  {
		
		shield--;
	}
	else {
		// if shield is at 0, reset it, and decrease lives.
		shield = 3;
		[self decreaseLives];
	}
}

// decrease lives by one and update the livesLabel
-(void) decreaseLives {
	if (lives == 0) [self loseScenario];
	else {
		lives--;
		[self updateLivesTo: lives];
	}
}

// update the lives representing UI elements
-(void) updateLivesTo:(int)newVal {
	
	lives = newVal;
	NSString *msg = [[NSString alloc] initWithFormat:@"Lives: %d",lives];
	[livesLabel setText:msg];
	[msg release];
}

// updates the shield and whatever UI elements represent it
-(void) updateShieldTo:(int)newVal {
	
	shield = newVal;
}

// updates the score and its UI elements
-(void) updateScoreTo:(int)newScore {
	
	[UIAppDelegate.currentUser.score setScore: newScore];
	[self updateScoreLabel];
}

// reset : score = 0, lives = 3, shield = 3
-(void) resetValues {
	
	[self updateLivesTo: 3];
	[self updateShieldTo: 3];
	[self updateScoreTo: 0];
}

// checks if two asteroids collide
-(BOOL) checkCollisionOf:(Asteroid*)as1 with:(Asteroid*)as2 {
	
	if(  ((as1.asteroidPosition.x < as2.asteroidPosition.x + ASTEROID_SIZE_X ) 
		  && (as1.asteroidPosition.x > as2.asteroidPosition.x - ASTEROID_SIZE_X	))
	   && ((as1.asteroidPosition.y < as2.asteroidPosition.y + ASTEROID_SIZE_Y) 
		  && (as1.asteroidPosition.y > as2.asteroidPosition.y - ASTEROID_SIZE_Y)) ) {
	
		// if they collide, handle the collision.
		[self handle2AsteroidsColliding: as1 with : as2];
		return YES;
	}
	return NO;
}
	
// handle the case of asteroids colliding with each other
-(void) handle2AsteroidsColliding: (Asteroid*)as1 with:(Asteroid*)as2 {
	
	// reverse their x directions
	//NSLog(@"asteroid x: %f asteroid y: %f", as1.asteroidSize.x , as1.asteroidSize.y);

	// currently leads to very funky results
	/*
	[as1 setAsteroidDirection: -as1.asteroidDirection.x : as1.asteroidDirection.y];
	[as1 setAsteroidDirection: as1.asteroidDirection.x : -as1.asteroidDirection.y];
	[as2 setAsteroidDirection: -as2.asteroidDirection.x : as2.asteroidDirection.y];
	[as2 setAsteroidDirection: as2.asteroidDirection.x : -as2.asteroidDirection.y];
	 */
	
	
}

// handles the asteroid collision scenarios
-(void) asteroidCollision: (int) asteroidIndex {
	
	// if we hit the right asteroid
	if([[asteroids objectAtIndex: asteroidIndex] asteroidType] == CORRECT_ASTEROID) 
	{
		// update the score and reset asteroid positions/labels/types
		[self hitCorrectAsteroid: asteroidIndex];
	}
	
	// if we hit a wrong asteroid
	else if ([[asteroids objectAtIndex: asteroidIndex] asteroidType] == INCORRECT_ASTEROID) 
	{
		// update the score and reset only position/label of current asteroid
		[self hitWrongAsteroid: asteroidIndex];
	}
	
	// if we hit a blank asteroid
	else if ([[asteroids objectAtIndex: asteroidIndex] asteroidType] == BLANK_ASTEROID)
	{
		[self hitBlankAsteroid: asteroidIndex];
	}
}

// what to do when a bullet collides with the correct_answer asteroid
-(void) hitCorrectAsteroid: (int) index {
	
	NSLog(@"hit correct asteroid.");
	int score = [UIAppDelegate.currentUser.score score];
	
	// update the scoreboard 
	score = score + CORRECT_ANSWER_REWARD;
	NSString *inputString = [[NSString alloc] initWithFormat:@"Score: %d", score ];
	[scoreLabel setText: inputString];
	[inputString release];
	
	// update the location of the asteroid to a random point on the screen
	[[asteroids objectAtIndex: index] setAsteroidPosition: (arc4random() % 460) : (arc4random() % 320)];
	
	[UIAppDelegate.currentUser.score setScore: score];
	
	// check if gameover
	[self checkScore];
	
	// reset question and asteroid labels
	[self setQuestion];
}

// hit wrong asteroid
-(void) hitWrongAsteroid:(int)index {
	
	NSLog(@"hit incorrect asteroid.");
	int score = [UIAppDelegate.currentUser.score score];
	
	// decrement score by 2 and update the scoreboard
	score = score - INCORRECT_ANSWER_PENALTY;
	NSString *inputString = [[NSString alloc] initWithFormat: @"Score: %d", score ];
	[scoreLabel setText: inputString];
	[inputString release];
	
	// update the location of the asteroid to a random point on the screen
	[[asteroids objectAtIndex: index] setAsteroidPosition: (arc4random() % 460) : (arc4random() % 320)];
	
	[UIAppDelegate.currentUser.score setScore: score];
	
	// check if game is over
	[self checkScore];
	
	// set the next question
	[self setQuestion];
}

// hit a blank asteroid
-(void) hitBlankAsteroid:(int)index {

	NSLog(@"hit blank asteroid.");
	
	int score = [UIAppDelegate.currentUser.score score];
	
	// increase score by 1 and update the scoreboard
	score = score + BLANK_REWARD;
	NSString *inputString = [[NSString alloc] initWithFormat:@"Score: %d", score ];
	[scoreLabel setText:inputString];
	[inputString release];
	
	// update the location of the asteroid to a random point on the screen
	[[asteroids objectAtIndex: index] setAsteroidPosition: (arc4random() % 460) : (arc4random() % 320)];
	
	[UIAppDelegate.currentUser.score setScore: score];
	
	// check if game is over
	[self checkScore];
}

// raise the difficulty if the user reached the limit and as long as it's not already on hardest
// if it's lower than 0 then the game is over (lose scenario)
// if it's over the limit of the hardest difficulty then the game is over (win scenario)
-(void) checkScore {
	
	int diff = [UIAppDelegate.currentUser.currentTopic difficulty];
	int score = [UIAppDelegate.currentUser.score score];
	
	// if the current score is higher than highestScore, update the AppDelegate profile.
	if (score > [UIAppDelegate.currentUser.highestScore score]) {
		
		[UIAppDelegate.currentUser setHighestScore: [UIAppDelegate.currentUser score]];
	}
	
	// if current topic is higher than lastTopicCompleted (highest topic achieved yet) then update the AppDelegate profile.
	if (UIAppDelegate.currentUser.currentTopic.topic > UIAppDelegate.currentUser.lastTopicCompleted.topic) {
		
		[UIAppDelegate.currentUser setLastTopicCompleted: UIAppDelegate.currentUser.currentTopic];
	}
	
	// if score is higher than set limit for difficulty, then raise the difficulty
	if (score > DIFFICULTY_LIMIT * diff && diff < DIFFICULTY_HARDEST) {

		// raise difficulty by one
		[[UIAppDelegate.currentUser currentTopic] setDifficulty: diff + 1];
		
				
		// reset the label
		[self setDifficultyLabel];
	}
	
	// if negative score, game is over (lose)
	if (score < 0 ) {

		// reset the score
		score = 0;
		[UIAppDelegate.currentUser.score setScore: score];
		
		[self updateScoreLabel];

		
		// initiate lose scenario
		[self loseScenario];
	}
	
	// if the current topic is the highest we've done so far, update the highest difficulty.
	if ([UIAppDelegate.currentUser.currentTopic topic] == [UIAppDelegate.currentUser.lastTopicCompleted topic] &&
		diff > [UIAppDelegate.currentUser.lastTopicCompleted difficulty]) {
		
		// then update the highestDifficulty in the AppDelegate profile
		[UIAppDelegate.currentUser.lastTopicCompleted setDifficulty: diff];
	}
	
	// if the score is higher than the set limit for topic
	if (score > DIFFICULTY_HARDEST * DIFFICULTY_LIMIT) {
		
		// if we haven't yet exhaused all our topics, progress to the next topic
		if ([UIAppDelegate.currentUser.currentTopic nextTopic]) {
			
			// update the profile's lastTopicCompleted if this one is higher
			if (UIAppDelegate.currentUser.currentTopic.topic > UIAppDelegate.currentUser.lastTopicCompleted.topic) {
				
				[UIAppDelegate.currentUser setLastTopicCompleted: UIAppDelegate.currentUser.currentTopic];
			}
			else {};	// avoid nested ambiguities.
			
			
			// reset the score
			score = 0;
			[UIAppDelegate.currentUser.score setScore: score];
			
			// reset the labels
			[self setDifficultyLabel];
			[self updateScoreLabel];
		}
		
		// otherwise, you've won.
		else {
			[self winScenario];
		}
	}
}

// update the score label to the current score value
-(void) updateScoreLabel {
	
	NSString *inputString = [[NSString alloc] initWithFormat:@"Score: %d", [UIAppDelegate.currentUser.score score]];
	[scoreLabel setText:inputString];
	[inputString release];
}

// begin lose scenario
-(void) loseScenario {
	
	// first save settings to plist
	[GlobalAdmin saveSettings];
	
	// reset score, shield and lives
	[self resetValues];
	
	[self nextScreen];
}

// begin win scenario
-(void) winScenario {
	
	// first save settings to plist
	[GlobalAdmin saveSettings];
	
	[self nextScreen];
}


// navigate to the help screen
-(IBAction) helpScreen {
	
	[self setGameTimer];
	
	// first save settings to plist as the player may opt to quit back to the root menu
	[GlobalAdmin saveSettings];
	
	// Navigation logic may go here -- for example, create and push another view controller.
	HelpScreenController *helpView = [[HelpScreenController alloc] initWithNibName:@"HelpScreenController" bundle:nil];
	[self.navigationController pushViewController:helpView animated:YES];
	//[self setGameTimer];
	[helpView release];
	
}

// navigate to the gameover screen
-(IBAction) nextScreen {
	
	// pause the game if it's running.
	[self setGameTimer];
	
	GameOverScreenController *gamesOverScreenView = [[GameOverScreenController alloc] initWithNibName:@"GameOverScreenController" bundle:nil];
	[self.navigationController pushViewController:gamesOverScreenView animated:YES];
	[gamesOverScreenView release];
}


// update the touch events (rotation wheel)
-(void) touchesUpdate:(NSSet*)touches :(UIEvent*)event {
	
	UITouch *touch = [[event allTouches] anyObject];		//records touch as touch object
    CGPoint location = [touch locationInView:touch.view];	//records touch's location
    //NSLog(@"X: %f",location.x);
    //NSLog(@"Y: %f",location.y);
	
	
	double x,y;
	double radius = 48;  //radius of rotation wheel
	double radiusSquared = radius*radius; //radius squared
	double xcenter = 80; //center of rotation wheel, x coordinate
	double ycenter = 222; //center of rotation wheel, y coordinate
	
	//if location of a touch is in the area of the rotation wheel, update the 
	//rotation wheel
	if(location.x > 22 && location.x < 160 && location.y > 146 && location.y < 285)
	{
		
		//code to approximate the closest point on the rotation wheel to the point
		//where the user touched the screen (they usually will not touch the 
		//rotation wheel right on so an approximation is necessary:
		
		if(location.y < ycenter-radius)
			location.y = ycenter-radius;
		else if (location.y > ycenter+radius )
			location.y = ycenter+radius ;
		
		if(location.x < xcenter-radius)
			location.x = xcenter-radius;
		else if (location.x > xcenter+radius )
			location.x = xcenter+radius ;
		
		if(location.y >= ycenter)
			y = sqrt( radiusSquared - pow(xcenter- location.x , 2) ) + ycenter; 
		else
		{
			y = -sqrt( radiusSquared - pow(xcenter- location.x , 2) ) + ycenter; 
		}
		
		y = (y + location.y) / 2.0;
		
		if(location.x >= xcenter)
			x = sqrt(radiusSquared - pow(ycenter - y,2) ) + xcenter;
		else
			x = -sqrt(radiusSquared - pow(ycenter - y, 2) ) + xcenter;
		
		//rotation ball is moved to the approximation of the closest point on the
		//rotation wheel to the point where to user actually touched the screen
		rotationBall.center = CGPointMake(x,y); 
		
		//shipDirection (used for ship rotation and firing direction) is updated
		shipDirectionX = (x - xcenter);
		shipDirectionY = (y - ycenter);
		
		CGFloat rotationAngle = atan2( shipDirectionY,shipDirectionX) + M_PI_2;
		[ship rotate: rotationAngle]; 		
	}
	
}

/*This function is called when a touch on the screen is first detected
 */
- (void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event {
	
	[self touchesUpdate:touches : event];
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"touchesEnded");
}

/*This function is called when a finger is dragged on the screen */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{ 
	[self touchesUpdate:touches : event];
	
}

// override to allow orientations other than the default portrait orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

// release all created objects
- (void)dealloc {
	[ship release];
	[question release];
    [super dealloc];
}


@end
