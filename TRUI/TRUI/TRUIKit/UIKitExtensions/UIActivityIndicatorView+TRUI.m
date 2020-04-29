//
//  UIActivityIndicatorView+TRUI.m
//  TRUI
//
//  Created by Mac on 2020/4/28.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "UIActivityIndicatorView+TRUI.h"

@implementation UIActivityIndicatorView (TRUI)

- (instancetype)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style size:(CGSize)size
{
    if (self = [self initWithActivityIndicatorStyle:style]) {
        CGSize initialSize = self.bounds.size;
        CGFloat scale = size.width/initialSize.width;
        self.transform = CGAffineTransformMakeScale(scale, scale);
    }
    return self;
}

@end
