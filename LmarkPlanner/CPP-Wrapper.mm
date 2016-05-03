//
//  CPP-Wrapper.m
//  LmarkPlanner
//
//  Created by Margarita Safonova on 4/25/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

#import "CPP-Wrapper.h"
#include "sbpltets.h"

@implementation CPP_Wrapper

- (NSInteger*)getPlanFromSbplByJson_wrapped : (NSString *) str {
    
    vector<long long int> v;
    v = getPlanFromSbplByJson([str cStringUsingEncoding:NSUTF8StringEncoding]);
    
    //int len = (int)v.size();
    
    //printf("len = %d\n", (int)v.size());
    int len = (int)v.size();
    
    NSInteger *pid = (NSInteger*)malloc(len* sizeof(NSInteger));
    
    for (int i=0; i<len; i++)
    {
        //latlonPlan[i] = CLLocationCoordinate2DMake(v[i][0], v[i][1]);
        printf("i=%d %lld\n", i, v[i]);
        pid[i] = v[i];
    }
    return pid;
}
@end
