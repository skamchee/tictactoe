//
//  Marker.m
//  TicTacSnow
//
//  Created by Spencer Kamchee on 2/21/14.
//  Copyright (c) 2014 Spencer Kamchee. All rights reserved.
//

#import "Marker.h"

@implementation Marker

- (id)initWithFrame:(CGRect)frame WithMarker:(NSString*)m
{
    self = [super initWithFrame:frame];
    if (self) {
        if([m isEqualToString:@"X"])
            self.image = [UIImage imageNamed:@"X.png"];
        else if([m isEqualToString:@"O"])
            self.image = [UIImage imageNamed:@"O.png"];
        
        self.markerType = m;
        self.userInteractionEnabled = YES;
        self.centerPoint = self.center;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
