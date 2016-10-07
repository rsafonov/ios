//
//  CPP-Wrapper.h
//  LmarkPlanner
//
//  Created by Margarita Safonova on 4/25/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/Mapkit.h>

@interface CPPWrapper : NSObject

- (BOOL) setParams_wrapped: (int) debug_mode error: (__autoreleasing NSError **) error;

- (BOOL) initPlannerByOsm_wrapped: (NSString*) osmJsonStr : (NSString*) excludedLmarks : (long long int **) lmarks : (int*) lmarks_count : (long long int **) intersections : (int*) intersections_count
;

- (BOOL) freePlan_wrapped: (int**) plan;
- (BOOL) freeMemory_wrapped: (long long int**) ptr;

- (BOOL) generatePlan_wrapped: (int) k : (long long int) start_pointId : (long long int) start_roadId : (int) start_type : (int) start_dir : (long long int) goal_pointId : (long long int) goal_roadId : (int) goal_type : (int) goal_dir : (int) mode : (int *) pathlen : (int *) k0len : (int *) k1len : (int**) plan;

- (BOOL) getIntersectionDetails_wrapped: (long long int) point_id : (int *) ind : (double *) lat : (double *) lon : (NSString **) location : (int *) streetsCount;
- (BOOL) getLandmarkDetails_wrapped: (long long int) point_id : (int *) ind : (double *) lat : (double *) lon : (NSString **) name : (NSString **) address : (NSString **) info : (NSString **) street : (NSString **) amenity : (long long int*) road_id : (double *) roadLat : (double *) roadLon;
- (BOOL) getSolutionStepDetails_wrapped: (int) currInd : (int) succInd : (long long int*) pid1 : (long long int*) pid2 : (int*) act1 : (int*) act2 : (int*) type1 : (int*) type2 : (int*) dir1 : (int*) dir2 : (double*) lat1 : (double*) lon1 : (double*) lat2 : (double*) lon2 : (int*) envId1 : (int*) envId2;

 @property void* ob;

@end

//#endif /* CPP_Wrapper_h */
