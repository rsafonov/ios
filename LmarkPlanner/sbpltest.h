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
        bool initPlannerByOsm(string osmJsonStr, char* lmarks, char* intersection, int buflen);
        bool setStartPose(long long int point_id, long long int* rid, int* type, int dir);
        bool setGoalPose(long long int point_id, long long int* rid, int* type, int dir);
        bool resetStartPose(long long int point_id, long long road_id, int type, int dir);
        bool resetGoalPose(long long int point_id, long long road_id, int type, int dir);
    
        bool generatePlan(int k, int* pathlen, char* path);
        bool getCoordsById(long long int point_id, double* lat, double* lon);
        bool getIntresectionDetails(long long int point_id, int* ind, double* lat, double* lon, char* location, int* streetsCount);
        bool getLandmarkDetails(long long int point_id, int* ind, double* lat, double* lon, char* name, char* address, char* info, char* street, char* amenity, long long int* roadId, double* roadLat, double* roadLon);
        bool getSolutionStepDetails(int currInd, int succInd, long long int* pid1, long long int* pid2, int* act1, int* act2, int* type1, int* type2, int* dir1, int* dir2, double* lat1, double* lon1, double* lat2, double* lon2);

    private:
        bool CreateStateFromOsm(long long int nid, long long int* rid, int* type, int dir, MapEnv* env, vector<Road*>* roads, EnvState* state);
    
        MapEnv env;
        vector<Road*> roads;
};

#endif /* sbpltest_h */
