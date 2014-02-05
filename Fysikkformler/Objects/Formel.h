//
//  Formel.h
//  Fys1Formel
//
//  Created by Oscar Apeland on 18.12.13.
//  Copyright (c) 2013 Oscar Apeland. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Formel : NSObject
@property NSString *note;
@property NSString *solvingFor;
@property NSArray *contains;
@property UIImage *mainFormelImage;
@property UIImage *flipFormelImage;
-(id)initWithDict:(NSDictionary *)dict forChar:(NSString*)unit andNumber:(int)num scaleBy:(float)scale;
@end
