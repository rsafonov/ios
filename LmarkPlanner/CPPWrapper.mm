//
//  CPP-Wrapper.m
//  LmarkPlanner
//
//  Created by Margarita Safonova on 4/25/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPPWrapper.h"

@implementation CPPWrapper

#include "sbpltest.h"

- (BOOL) setParams_wrapped: (int) debug_mode
{
    NSURL *DocumentDirURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    const char* buf = [DocumentDirURL.path UTF8String];
   
    try {
        self.ob = new MySbpl(buf);
    }
    catch(...)
    {
    }
    
    MySbpl* sb = (MySbpl*)self.ob;
    bool res = (MySbpl*) sb->setParams(debug_mode);
    return res;
}

- (BOOL) initPlannerByOsm_wrapped: (NSString*) osmJsonStr : (long long int **) lmarks : (int*) lmarks_count : (long long int **) intersections : (int*) intersections_count
{
    MySbpl* sb = (MySbpl*)self.ob;
    
    bool res =(MySbpl*) sb->initPlannerByOsm([osmJsonStr cStringUsingEncoding:NSUTF8StringEncoding], lmarks, lmarks_count, intersections, intersections_count);
    if (res)
    {
    }
    return res;
}

- (BOOL) freePlan_wrapped: (int**) plan
{
    MySbpl* sb = (MySbpl*)self.ob;
    bool res =(MySbpl*)sb->freePlan(plan);
    return res;
}

- (BOOL) freeMemory_wrapped: (long long int**) ptr;
{
    MySbpl* sb = (MySbpl*)self.ob;
    bool res =(MySbpl*)sb->freeMemory(ptr);
    return res;
}

- (BOOL) generatePlan_wrapped: (int) k : (long long int) start_pointId : (long long int) start_roadId : (int) start_type : (int) start_dir : (long long int) goal_pointId : (long long int) goal_roadId : (int) goal_type : (int) goal_dir : (int) mode : (int *) pathlen : (int *) k0len : (int *) k1len : (int**) plan

{
    MySbpl* sb = (MySbpl*)self.ob;
    bool res =(MySbpl*) sb->generatePlan(k, start_pointId, start_roadId, start_type, start_dir, goal_pointId, goal_roadId, goal_type, goal_dir, mode, pathlen, k0len, k1len, plan);
    return res;
}
 
- (BOOL) getIntersectionDetails_wrapped: (long long int) point_id : (int *) ind : (double *) lat : (double *) lon : (NSString **) location : (int *) streetsCount
{
    string loc;
    
    MySbpl* sb = (MySbpl*)self.ob;
    bool res = (MySbpl*)sb->getIntresectionDetails(point_id, ind, lat, lon, loc, streetsCount);
    if(res)
    {
        *location = [NSString stringWithFormat:@"%s", loc.c_str()];
    }
    return res;
}

- (BOOL) getLandmarkDetails_wrapped: (long long int) point_id : (int *) ind : (double *) lat : (double *) lon : (NSString **) name : (NSString **) address : (NSString **) info : (NSString **) street : (NSString **) amenity : (long long int*) road_id : (double *) roadLat : (double *) roadLon
{
    string sname, saddress, sinfo, sstreet, samenity;
    
    MySbpl* sb = (MySbpl*)self.ob;
    bool res = (MySbpl*)sb->getLandmarkDetails(point_id, ind, lat, lon, sname, saddress, sinfo, sstreet, samenity, road_id, roadLat, roadLon);
    if(res)
    {
        
        *name = [NSString stringWithFormat:@"%s", sname.c_str()];
        *address = [NSString stringWithFormat:@"%s", saddress.c_str()];
        *info = [NSString stringWithFormat:@"%s", sinfo.c_str()];
        *street = [NSString stringWithFormat:@"%s", sstreet.c_str()];
        *amenity = [NSString stringWithFormat:@"%s", samenity.c_str()];
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
