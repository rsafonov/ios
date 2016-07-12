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

- (BOOL) initPlannerByOsm_wrapped: (NSString*) osmJsonStr : (NSString **) lmarks :(NSString **) intersections
;

- (BOOL) setStartPose_wrapped: (long long int) point_id : (long long int*) road_id : (int*) type : (int) dir;
- (BOOL) setGoalPose_wrapped: (long long int) point_id : (long long int*) road_id : (int*) type : (int) dir;
- (BOOL) resetStartPose_wrapped: (long long int) point_id : (long long int) road_id : (int) type : (int) dir;
- (BOOL) resetGoalPose_wrapped: (long long int) point_id : (long long int) road_id : (int) type : (int) dir;


- (BOOL) generatePlan_wrapped: (int) k : (int *) pathlen : (NSString **) path;
- (BOOL) getCoordsById_wrapped: (long long int) point_id : (double *) lat : (double *) lon;
- (BOOL) getIntersectionDetails_wrapped: (long long int) point_id : (int *) ind : (double *) lat : (double *) lon : (NSString **) location : (int *) streetsCount;
- (BOOL) getLandmarkDetails_wrapped: (long long int) point_id : (int *) ind : (double *) lat : (double *) lon : (NSString **) name : (NSString **) address : (NSString **) info : (NSString **) street : (NSString **) amenity : (long long int*) road_id : (double *) roadLat : (double *) roadLon;
- (BOOL) getSolutionStepDetails_wrapped: (int) currInd : (int) succInd : (long long int*) pid1 : (long long int*) pid2 : (int*) act1 : (int*) act2 : (int*) type1 : (int*) type2 : (int*) dir1 : (int*) dir2 : (double*) lat1 : (double*) lon1 : (double*) lat2 : (double*) lon2;

 @property void* ob;
 @property int buflen;

@end

//#endif /* CPP_Wrapper_h */
