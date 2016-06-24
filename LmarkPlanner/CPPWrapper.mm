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

- (BOOL) setStartPose_wrapped: (long long int) point_id : (long long int*) road_id : (int*) type : (int) dir
{
    MySbpl* sb = (MySbpl*)self.ob;
    bool res = (MySbpl*) sb->setStartPose(point_id, road_id, type, dir);
    return res;
}

- (BOOL) setGoalPose_wrapped: (long long int) point_id : (long long int*) road_id : (int*) type : (int) dir
{
    MySbpl* sb = (MySbpl*)self.ob;
    bool res = (MySbpl*) sb->setGoalPose(point_id, road_id, type, dir);
    return res;
}

- (BOOL) resetStartPose_wrapped: (long long int) point_id : (long long int) road_id : (int) type : (int) dir
{
    MySbpl* sb = (MySbpl*)self.ob;
    bool res = (MySbpl*) sb->resetStartPose(point_id, road_id, type, dir);
    return res;
}
- (BOOL) resetGoalPose_wrapped: (long long int) point_id : (long long int) road_id : (int) type : (int) dir;
{
    MySbpl* sb = (MySbpl*)self.ob;
    bool res = (MySbpl*) sb->resetGoalPose(point_id, road_id, type, dir);
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

- (BOOL) getIntersectionDetails_wrapped: (long long int) point_id : (int *) ind : (double *) lat : (double *) lon : (NSString **) location : (int *) streetsCount
{
    char c_loc[self.buflen];
    MySbpl* sb = (MySbpl*)self.ob;
    bool res = (MySbpl*)sb->getIntresectionDetails(point_id, ind, lat, lon, c_loc, streetsCount);
    if(res)
    {
        *location = [NSString stringWithFormat:@"%s", c_loc];
    }
    return res;
}

- (BOOL) getLandmarkDetails_wrapped: (long long int) point_id : (int *) ind : (double *) lat : (double *) lon : (NSString **) name : (NSString **) address : (NSString **) info : (NSString **) street : (NSString **) amenity
{
    char c_name[self.buflen];
    char c_address[self.buflen];
    char c_info[self.buflen];
    char c_street[self.buflen];
    char c_amenity[self.buflen];
    MySbpl* sb = (MySbpl*)self.ob;
    bool res = (MySbpl*)sb->getLandmarkDetails(point_id, ind, lat, lon, c_name, c_address, c_info, c_street, c_amenity);
    if(res)
    {
        *name = [NSString stringWithFormat:@"%s", c_name];
        *address = [NSString stringWithFormat:@"%s", c_address];
        *info = [NSString stringWithFormat:@"%s", c_info];
        *street = [NSString stringWithFormat:@"%s", c_street];
        *amenity = [NSString stringWithFormat:@"%s", c_amenity];
    }
    return res;
}
@end
