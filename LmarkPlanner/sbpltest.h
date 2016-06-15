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
        bool setStartPose(long long int point_id);
        bool setGoalPose(long long int point_id);
        bool generatePlan(int* pathlen, char* path);
        bool getCoordsById(long long int point_id, double* lat, double* lon);
        bool getIntresectionDetails(long long int point_id, int* ind, double* lat, double* lon, char* location);

    private:
        bool CreateStateFromOsm(long long int nid, int type, int dir, MapEnv* env, vector<Road*>* roads, EnvState* state);
    
        MapEnv env;
        vector<Road*> roads;
};

#endif /* sbpltest_h */
