//
//  sbpltest.cpp
//  LmarkPlanner
//
//  Created by Margarita Safonova on 4/23/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

#include "sbpltest.h"

bool MySbpl::setParams(string docDirectory)
{
    env0.dbg_params.dir = docDirectory;
    return true;
}

bool MySbpl::initPlannerByOsm(string osmJsonStr, char* lmarks, char* intersections, int buflen)
{
    env0.dbg_params.mode = 2;
    env0.dbg_params.roads_file_name = "myroads.txt";
    env0.dbg_params.landmarks_file_name = "mylandmarks.txt";
    env0.dbg_params.amenities_file_name = "myamenities.txt";
    env0.dbg_params.ways_file_name = "myways.txt";
    env0.dbg_params.roadinfo_file_name = "myroadinfo.txt";
    
    env0.dbg_params.max_landmark_road_distance = 50.0; //meters
    
    string slmarks = lmarks;
    string sintersections = intersections;
    bool res = env0.InitializeEnvByJson(osmJsonStr, &roads, &slmarks, buflen,  &sintersections);
    
    //printf("--- lmarks ---\n");
    //printf("%s\n", slmarks.c_str());
    //printf("\n");

    if (res)
    {
        strcpy(lmarks, slmarks.c_str());
        strcpy(intersections, sintersections.c_str());
        //env.heuristicComputed = false;
    }
    else
        printf("Error: initPlannerByOsm failed!\n");
    return res;
}
 
bool MySbpl::getIntresectionDetails(long long int point_id, int* ind, double* lat, double* lon, char* location, int* streetsCount)
{
    string slocation = location;
    bool res = env0.GetIntersectionDetails(point_id, ind, lat, lon, &slocation, streetsCount);
    if (res)
    {
        strcpy(location, slocation.c_str());
    }
    else
        printf("Error: getIntersectionDetails failed!\n");
    return res;
}

bool MySbpl::getLandmarkDetails(long long int point_id, int* ind, double* lat, double* lon, char* name, char* address, char* info, char* street, char* amenity, long long int* roadId, double* roadLat, double* roadLon)
{
    string saddress, sname, sinfo, sstreet, samenity;
    bool res = env0.GetLandmarkDetails(point_id, ind, lat, lon, &sname, &saddress, &sinfo, &sstreet, &samenity, roadId, roadLat, roadLon);
    if (res)
    {
        strcpy(address, saddress.c_str());
        strcpy(name, sname.c_str());
        strcpy(info, sinfo.c_str());
        strcpy(street, sstreet.c_str());
        strcpy(amenity, samenity.c_str());
    }
    else
        printf("Error: getLandmarkDetails failed!\n");
    return res;
}

bool MySbpl::getSolutionStepDetails(int currInd, int succInd, long long int* pid1, long long int* pid2, int* act1, int* act2, int* type1, int* type2, int* dir1, int* dir2, double* lat1, double* lon1, double* lat2, double* lon2,
    int* envId1, int* envId2)
{
    bool res = env->GetSolutionStepDetails(currInd, succInd, pid1, pid2, act1, act2, type1, type2, dir1, dir2, lat1, lon1, lat2, lon2, envId1, envId2);
    return res;
}

bool MySbpl::generatePlan(int k, long long int start_pointId, long long int start_roadId, int start_type, int start_dir, long long int goal_pointId, long long int goal_roadId, int goal_type, int goal_dir, int*pathlen, char* path)
{
    std::vector<int*> ppcpSolutionIds;
    string spath = "";
    double computeTime = 10.00;
    double policyTime = 100.00;
    
    //env.Reset();
    //MapEnv env;
    
    if (env != NULL)
    {
        delete env;
    }
    
    env = new MapEnv();
    env->InitializeEnvByEnv(&env0);
    
    EnvState start_state = env->CreateState(start_roadId, start_pointId, start_type, start_dir);
    env->setStartState(start_state);
    EnvState goal_state = env->CreateState(goal_roadId, goal_pointId, goal_type, goal_dir);
    env->setGoalState(goal_state);

    //if (!env.heuristicComputed)
    //{
        env->ComputeHeuristic();
        //env.heuristicComputed = true;
    //}
    
    //env.ppcp.ResetPlanner(&env, k, 0);
    env->setSafetyNetDegree(k);
    env->setTimes(policyTime, computeTime);
    bool ret = env->findOptimalPPCPPath(&ppcpSolutionIds);
    
    *pathlen = (int)ppcpSolutionIds.size();
    if (!ret || *pathlen <= 0)
    {
        //printf("Error: path not found!\n");
        //fflush(stdout);
        return false;
    }
    else
    {
        spath = env->ConvertStatePathToLatLonPath(&ppcpSolutionIds);
        fflush(stdout);
        strcpy(path, spath.c_str());
    }
    
    *pathlen = (int)ppcpSolutionIds.size();
    //printf("pathlen = %d\n", *pathlen);
    return true;
}