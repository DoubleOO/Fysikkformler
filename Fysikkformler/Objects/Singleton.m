//
//  Singleton.m
//  Fysikkformler
//
//  Created by Oscar Apeland on 17.03.14.
//  Copyright (c) 2014 Oscar Apeland. All rights reserved.
//

#import "Singleton.h"

@implementation Singleton
+ (Singleton *)sharedData
{
    static Singleton *sharedSingleton;
    
    @synchronized(self)
    {
        if (!sharedSingleton)
            sharedSingleton = [[Singleton alloc] init];
        
        return sharedSingleton;
    }
}
@end
