//
//  CPP-Wrapper.m
//  LmarkPlanner
//
//  Created by Margarita Safonova on 4/25/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

#import "CPP-Wrapper.h"
#include "sbpltets.hpp"

@implementation CPP_Wrapper

- (void)getPlanFromSbplByJson_wrapped : (NSString *) str {
    
     getPlanFromSbplByJson([str cStringUsingEncoding:NSUTF8StringEncoding]);
     
}
@end
