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

- (BOOL) setParams_wrapped: (NSString*) docDirectory
{
    self.buflen = 16384*10;
    self.ob = new MySbpl();
    MySbpl* sb = (MySbpl*)self.ob;
    bool res = (MySbpl*) sb->setParams([docDirectory cStringUsingEncoding:NSUTF8StringEncoding]);
    return res;
}

- (BOOL) initPlannerByOsm_wrapped: (NSString*) osmJsonStr : (NSString **) lmarks :(NSString **) intersections
{
    char c_lmarks[self.buflen];
    char c_intersections[self.buflen];
    
    MySbpl* sb = (MySbpl*)self.ob;
    
    bool res =(MySbpl*) sb->initPlannerByOsm([osmJsonStr cStringUsingEncoding:NSUTF8StringEncoding], c_lmarks, c_intersections, self.buflen);
    if (res)
    {
        *lmarks = [NSString stringWithFormat:@"%s", c_lmarks];
        *intersections = [NSString stringWithFormat:@"%s", c_intersections];
    }
    return res;
}

- (BOOL) generatePlan_wrapped: (int) k : (long long int) start_pointId : (long long int) start_roadId : (int) start_type : (int) start_dir : (long long int) goal_pointId : (long long int) goal_roadId : (int) goal_type : (int) goal_dir : (int *) pathlen : (NSString **) path
{
    char c_path[self.buflen];
    MySbpl* sb = (MySbpl*)self.ob;
    bool res =(MySbpl*) sb->generatePlan(k, start_pointId, start_roadId, start_type, start_dir, goal_pointId, goal_roadId, goal_type, goal_dir, pathlen, c_path);
    if(res)
    {
        *path = [NSString stringWithFormat:@"%s", c_path];
    }
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

- (BOOL) getLandmarkDetails_wrapped: (long long int) point_id : (int *) ind : (double *) lat : (double *) lon : (NSString **) name : (NSString **) address : (NSString **) info : (NSString **) street : (NSString **) amenity : (long long int*) road_id : (double *) roadLat : (double *) roadLon
{
    int len = self.buflen/5;
    char c_name[len];
    char c_address[len];
    char c_info[len];
    char c_street[len];
    char c_amenity[len];
    MySbpl* sb = (MySbpl*)self.ob;
    bool res = (MySbpl*)sb->getLandmarkDetails(point_id, ind, lat, lon, c_name, c_address, c_info, c_street, c_amenity, road_id, roadLat, roadLon);
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

- (BOOL) getSolutionStepDetails_wrapped: (int) currInd : (int) succInd : (long long int*) pid1 : (long long int*) pid2 : (int*) act1 : (int*) act2 : (int*) type1 : (int*) type2 : (int*) dir1 : (int*) dir2 : (double*) lat1 : (double*) lon1 : (double*) lat2 : (double*) lon2 : (int*) envId1 : (int*) envId2;
{
    MySbpl* sb = (MySbpl*)self.ob;
    bool res = (MySbpl*)sb->getSolutionStepDetails(currInd, succInd, pid1, pid2, act1, act2, type1, type2, dir1, dir2, lat1, lon1, lat2, lon2, envId1, envId2);
    return res;
}
@end
