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
        bool setParams(string docDirectory);
        bool initPlannerByOsm(string osmJsonStr, char* lmarks, char* intersection, int buflen);
        bool generatePlan(int k, long long int start_pointId, long long int start_roadId, int start_type, int start_dir, long long int goal_pointId, long long int goal_roadId, int goal_type, int goal_dir, int* pathlen, char* path);
        bool getIntresectionDetails(long long int point_id, int* ind, double* lat, double* lon, char* location, int* streetsCount);
        bool getLandmarkDetails(long long int point_id, int* ind, double* lat, double* lon, char* name, char* address, char* info, char* street, char* amenity, long long int* roadId, double* roadLat, double* roadLon);
        bool getSolutionStepDetails(int currInd, int succInd, long long int* pid1, long long int* pid2, int* act1, int* act2, int* type1, int* type2, int* dir1, int* dir2, double* lat1, double* lon1, double* lat2, double* lon2,
        int* envId1, int* envId2);

    private:
    
        MapEnv env0;
        MapEnv *env = NULL;
        vector<Road*> roads;
};

#endif /* sbpltest_h */
