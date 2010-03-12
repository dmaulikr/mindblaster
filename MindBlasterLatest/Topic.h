//
//  Topic.h
//  MindBlaster
//
//  Created by yaniv haramati on 10/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

static const int TOPIC_ADDITION = 0;
static const int TOPIC_SUBTRACTION = 1;
static const int TOPIC_MULTIPLICATION = 2;
static const int TOPIC_DIVISION = 3;

@interface Topic : NSObject {
	
	int difficulty;
	int topic;
	NSString *description;
	char *operator;
}

@property (nonatomic) int difficulty;
@property (nonatomic) int topic;
@property (nonatomic) char *operator;
@property (nonatomic,retain) NSString *description;

-(id)initWithTopic:(int)newTopic;

@end