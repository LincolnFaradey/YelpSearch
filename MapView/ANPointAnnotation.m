//
//  ANPointAnnotation.m
//  MapView
//
//  Created by Aditya Narayan on 2/20/15.
//  Copyright (c) 2015 Aditya. All rights reserved.
//

#import "ANPointAnnotation.h"

@implementation ANPointAnnotation

- (void)dealloc
{
    [_image release];
    [super dealloc];
}

@end
