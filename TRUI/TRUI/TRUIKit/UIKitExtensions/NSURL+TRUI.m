//
//  NSURL+TRUI.m
//  TRUI
//
//  Created by Mac on 2020/4/28.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "NSURL+TRUI.h"

@implementation NSURL (TRUI)

- (NSDictionary<NSString *,NSString *> *)trui_queryItems
{
    if (!self.absoluteString.length) {
        return nil;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:self.absoluteString];
    
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.name) {
            [params setObject:obj.value?:[NSNull null] forKey:obj.name];
        }
    }];
    return [params copy];
}

@end
