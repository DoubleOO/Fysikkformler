//
//  Fysformel.h
//  Fysikkformler
//
//  Created by Oscar Apeland on 17.03.14.
//  Copyright (c) 2014 Oscar Apeland. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Singleton : NSObject
+ (Singleton *)sharedData;
@property NSArray *menuObjects;
@property NSDictionary *JSONDict;
@end
