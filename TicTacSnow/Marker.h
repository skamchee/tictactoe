//
//  Marker.h
//  TicTacSnow
//
//  Created by Spencer Kamchee on 2/21/14.
//  Copyright (c) 2014 Spencer Kamchee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Marker : UIImageView

-(id)initWithFrame:(CGRect)frame WithMarker:(NSString*)m;

@property (strong,nonatomic)NSString* markerType;
@property (nonatomic)CGPoint centerPoint;
@end
