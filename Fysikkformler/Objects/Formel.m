//
//  Formel.m
//  Fys1Formel
//
//  Created by Oscar Apeland on 18.12.13.
//  Copyright (c) 2013 Oscar Apeland. All rights reserved.
//

#import "Formel.h"
#import "UIImage+PDF.h"
@implementation Formel
-(id)initWithDict:(NSDictionary *)dictionary forChar:(NSString *)unit andNumber:(int)num scaleBy:(float)scale{
    self = [super init];
    if(self)
    {
        //NOTE
        NSString *note = [dictionary objectForKey:@"note"];
        if ([note isEqualToString:@"-"]) {
            note = @"";
        }
        self.note = note;
        
        //CONTAINS
        self.contains = [dictionary objectForKey:@"contains"];
       
        
        //MAINIMAGE
        NSString *imageString = [[NSString alloc]initWithFormat:@"%@%i.pdf",unit,num];
        UIImage *originalImage = [UIImage originalSizeImageWithPDFNamed:imageString];
        float scaleX = originalImage.size.width * scale;
        self.mainFormelImage = [UIImage imageWithPDFNamed:imageString atWidth:scaleX];

        
        //FLIPPEDIMAGE
        NSString *flipImageString = [[NSString alloc]initWithFormat:@"%@%isnudd.pdf",unit,num];
        UIImage *flippedImage = [UIImage originalSizeImageWithPDFNamed:flipImageString];
        scaleX = flippedImage.size.width * scale;
        self.flipFormelImage = [UIImage imageWithPDFNamed:flipImageString atWidth:scaleX];
        
    }
    return self;
}

@end
