//
//  sbpltest.cpp
//  LmarkPlanner
//
//  Created by Margarita Safonova on 4/23/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

#include "sbpltest.h"

bool MySbpl::CreateStateFromOsm(long long int nid, int type, int dir, MapEnv* env, vector<Road*>* roads, EnvState* state)
{
    long long int rid;
    int real_type = -1, real_dir = dir;
    
    printf("CreateStateFromOsm start: nid = %lld\n", nid);
    fflush(stdout);
    
    rid = -1;
    bool found = false;
    
    
    for (int i=0; i<roads->size(); i++)
    {
        if ((*roads)[i]->roadends[0] == nid || (*roads)[i]->roadends[1] == nid)
        {
            rid = (*roads)[i]->id;
            found = true;
            real_type = 0;
            break;
        }
    }
    printf("As intersection: found = %d rid = %lld nid = %lld type = 0\n", found, rid, nid);
    fflush(stdout);
    
    if (!found)
    {
        for (int i=0; i<roads->size(); i++)
        {
            for (int j=0; j < (*roads)[i]->landmarkConnections.size(); j++)
            {
                if ((*roads)[i]->landmarkConnections[j] == nid)
                {
                    rid = (*roads)[i]->id;
                    found = true;
                    real_type = 1;
                    break;
                }
            }
        }
        printf("As landmark: found = %d rid = %lld nid = %lld type = 1\n", found, rid, nid);
        fflush(stdout);
    }
        
    if (found)
    {
        if (real_type == 1) real_dir = 0;
        *state = env->CreateState(rid, nid, real_type, real_dir);
        //*state = env->CreateState(rid, nid, 0, 1);
        printf("State found: rid = %lld nid = %lld type = %d dir = %d\n", rid, nid, real_type, real_dir);
    }
    return found;
}

bool MySbpl::initPlannerByOsm(string osmJsonStr, char* lmarks, char* intersections, int buflen)
{
    //OsmParams params;
    env.dbg_params.mode = 0;
    env.dbg_params.roads_file_name = "out/myroads.txt";
    env.dbg_params.landmarks_file_name = "out/mylandmarks.txt";
    env.dbg_params.amenities_file_name = "out/myamenities.txt";
    env.dbg_params.ways_file_name = "out/myways.txt";
    env.dbg_params.roadinfo_file_name = "out/myroadinfo.txt";
    
    env.dbg_params.max_landmark_road_distance = 50.0; //meters
    
    string slmarks = lmarks;
    string sintersections = intersections;
    bool res = env.InitializeEnvByJson(osmJsonStr, &roads, &slmarks, buflen,  &sintersections);
    
    //printf("--- lmarks ---\n");
    //printf("%s\n", slmarks.c_str());
    //printf("\n");

    if (res)
    {
        strcpy(lmarks, slmarks.c_str());
        strcpy(intersections, sintersections.c_str());
    }
    else
        printf("Error: initPlannerByOsm failed!\n");
    return res;
}

bool MySbpl::setStartPose(long long int point_id)
{
    EnvState state;
    int type = 1, dir = 1;
    
    //bool found = CreateStateFromOsm(105013433, 0, 1, &env, &roads, &state);
    bool found = CreateStateFromOsm(point_id, type, dir, &env, &roads, &state);
    
    if (!found)
    {
        printf("Start state can not be created for node %lld\n", point_id);
        return false;
    }
    else
    {
        env.setStartState(state);
        printf("Start state created for node %lld\n", point_id);
        return true;
    }
}

bool MySbpl::setGoalPose(long long int point_id)
{
    EnvState state;
    int type = 1, dir = 1;

    //bool found = CreateStateFromOsm(105097518, 0, 1, &env, &roads, &state);
    bool found = CreateStateFromOsm(point_id, type, dir, &env, &roads, &state);
    if (!found)
    {
        printf("Goal state can not be created for node %lld\n", point_id);
        return false;
    }
    else
    {
        env.setGoalState(state);
        printf("Goal state created for node %lld\n", point_id);
        return true;
    }
}

bool MySbpl::getCoordsById(long long int point_id, double* lat, double* lon)
{
    bool res = env.GetCoordsById(point_id, lat, lon);
    return res;
}

bool MySbpl::getIntresectionDetails(long long int point_id, int* ind, double* lat, double* lon, char* location)
{
    string slocation = location;
    bool res = env.GetIntersectionDetails(point_id, ind, lat, lon, &slocation);
    if (res)
    {
        strcpy(location, slocation.c_str());
    }
    else
        printf("Error: getIntersectionDetails failed!\n");
    return res;
}

bool MySbpl::generatePlan(int* pathlen, char* path)
{
    std::vector<int*> ppcpSolutionIds;
    string spath = "";  //= path;
    printf("generatePlan: pathlen = %d", *pathlen);
    fflush(stdout);

    env.ComputeHeuristic();
    env.setSafetyNetDegree(0);
    env.findOptimalPPCPPath(&ppcpSolutionIds);
    
    *pathlen = (int)ppcpSolutionIds.size();
    if (*pathlen <= 0)
    {
        printf("Error: path not found!\n");
        fflush(stdout);
        return false;
    }
    else
    {
        printf("pathlen = %d\n", *pathlen);
        spath = env.ConvertStatePathToLatLonPath(&ppcpSolutionIds);
        printf("Length of spath string: %lu", spath.length());
        fflush(stdout);
        //printf("--- path ---\n");
        //printf("%s\n", spath.c_str());
        //printf("\n");
        strcpy(path, spath.c_str());
    }
    
    *pathlen = (int)ppcpSolutionIds.size();
    printf("pathlen = %d\n", *pathlen);
    return true;
}












