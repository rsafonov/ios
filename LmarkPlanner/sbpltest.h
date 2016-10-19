//
//  sbpltets.h
//  LmarkPlanner
//
//  Created by Margarita Safonova on 4/25/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

#ifndef sbpltest_h
#define sbpltest_h

#pragma once
#include <stdio.h>
#include <iostream>
#include <string>
#include <vector>

#include <cmath>
#include <cstring>

#include <sbpl/discrete_space_information/map.h>
#include <sbpl/headers.h>

using namespace std;

class MySbpl
{
    public:
        MySbpl(string docDirectory);
    
        bool setParams(int debug_mode, double policyTime, double computeTime);
        bool initPlannerByOsm(string osmJsonStr, string excludedLmarks, long long int** lmarks, int* lmarks_count, long long int** intersections, int*intersections_count);
    
        bool freePlan(int** plan);
    
        bool freeMemory(long long int** ptr);
    
        bool generatePlan(int k, long long int start_pointId, long long int start_roadId, int start_type, int start_dir, long long int goal_pointId, long long int goal_roadId, int goal_type, int goal_dir, int mode, int iter, int* pathlen, int* k0len, int* k1len, double* duration, int** plan);
        bool getIntresectionDetails(long long int point_id, int* ind, double* lat, double* lon, string& location, int* streetsCount);
        bool getLandmarkDetails(long long int point_id, int* ind, double* lat, double* lon, string& name, string& address, string& info, string& street, string& amenity, long long int* roadId, double* roadLat, double* roadLon);
    
    //bool removeLandmark(long long int point_id);

        bool getSolutionStepDetails(int currInd, int succInd, long long int* pid1, long long int* pid2, int* act1, int* act2, int* type1, int* type2, int* dir1, int* dir2, double* lat1, double* lon1, double* lat2, double* lon2,
        int* envId1, int* envId2);

    private:
    
        MapEnv env0;
        MapEnv *env = NULL;
};

#endif /* sbpltest_h */
