//
//  CPP-Wrapper.m
//  LmarkPlanner
//
//  Created by Margarita Safonova on 4/25/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

#import "CPPWrapper.h"

@implementation CPPWrapper

#include "sbpltest.h"

- (BOOL) initPlannerByOsm_wrapped: (NSString*) osmJsonStr : (NSString **) lmarks :(NSString **) intersections
{
    self.buflen = 16384*2;
    char c_lmarks[self.buflen];
    char c_intersections[self.buflen];
    
    self.ob = new MySbpl();
    MySbpl* sb = (MySbpl*)self.ob;
    
    bool res =(MySbpl*) sb->initPlannerByOsm([osmJsonStr cStringUsingEncoding:NSUTF8StringEncoding], c_lmarks, c_intersections, self.buflen);
    if (res)
    {
        *lmarks = [NSString stringWithFormat:@"%s", c_lmarks];
        *intersections = [NSString stringWithFormat:@"%s", c_intersections];
    }
    return res;
}

- (BOOL) setStartPose_wrapped: (long long int) point_id
{
    MySbpl* sb = (MySbpl*)self.ob;
    bool res = (MySbpl*) sb->setStartPose(point_id);
    return res;
}

- (BOOL) setGoalPose_wrapped: (long long int) point_id
{
    MySbpl* sb = (MySbpl*)self.ob;
    bool res = (MySbpl*) sb->setGoalPose(point_id);
    return res;
}

- (BOOL) generatePlan_wrapped: (int *) pathlen : (NSString **) path
{
    char c_path[self.buflen];
    MySbpl* sb = (MySbpl*)self.ob;
    bool res =(MySbpl*) sb->generatePlan(pathlen, c_path);
    if(res)
    {
        *path = [NSString stringWithFormat:@"%s", c_path];
    }
    return res;
}

- (BOOL) getCoordsById_wrapped: (long long int) point_id : (double *) lat : (double *) lon
{
    MySbpl* sb = (MySbpl*)self.ob;
    bool res = (MySbpl*)sb->getCoordsById(point_id, lat, lon);
    return res;
}

- (BOOL) getIntersectionDetails_wrapped: (long long int) point_id : (int *) ind : (double *) lat : (double *) lon : (NSString **) location
{
    char c_loc[self.buflen];
    MySbpl* sb = (MySbpl*)self.ob;
    bool res = (MySbpl*)sb->getIntresectionDetails(point_id, ind, lat, lon, c_loc);
    if(res)
    {
        *location = [NSString stringWithFormat:@"%s", c_loc];
    }
    return res;
}
@end
