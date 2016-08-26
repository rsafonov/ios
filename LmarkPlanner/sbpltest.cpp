//
//  sbpltest.cpp
//  LmarkPlanner
//
//  Created by Margarita Safonova on 4/23/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

#include "sbpltest.h"

MySbpl::MySbpl(string iosDocDir)
{
    SBPL_PRINTF("iOS Document Directory:");
    SBPL_PRINTF("%s", iosDocDir.c_str());
    
    env0.dbg_params.dir.assign(iosDocDir);
    printTargetOS();
}

bool MySbpl::setParams(int debug_mode)
{
    env0.dbg_params.mode = debug_mode;
    return true;
}

bool MySbpl::initPlannerByOsm(string osmJsonStr, long long int** lmarks, int* lmarks_count, long long int** intersections, int*intersections_count)
{
    env0.dbg_params.max_landmark_road_distance = 50.0; //meters

    env0.dbg_params.roads_file_name = "myroads.txt";
    env0.dbg_params.landmarks_file_name = "mylandmarks.txt";
    env0.dbg_params.amenities_file_name = "amenities.txt";
    env0.dbg_params.ways_file_name = "ways.txt";
    env0.dbg_params.roadinfo_file_name = "roadinfo.txt";
    env0.dbg_params.streets_file_name = "streets.txt";
    env0.dbg_params.isections_file_name = "isections.txt";
    env0.dbg_params.pois_file_name = "pois.txt";
    
    bool res = env0.InitializeEnvByJson(osmJsonStr, lmarks, lmarks_count, intersections, intersections_count);
    
    if (res)
    {
        //env.heuristicComputed = false;
        SBPL_PRINTF("env0.InitializeEnvByJson succeeded!");
    }
    else
    {
        SBPL_PRINTF("Error: env0.InitializeEnvByJson failed!");
    }
    return res;
}
 
bool MySbpl::getIntresectionDetails(long long int point_id, int* ind, double* lat, double* lon, string& location, int* streetsCount)

{
    bool res = env0.GetIntersectionDetails(point_id, ind, lat, lon, location, streetsCount);

    if (res)
    {
        //printf("%s\n", location.c_str());
    }
    else
        printf("Error: getIntersectionDetails failed!\n");
    return res;
}

bool MySbpl::getLandmarkDetails(long long int point_id, int* ind, double* lat, double* lon, string& name, string& address, string& info, string& street, string& amenity, long long int* roadId, double* roadLat, double* roadLon)
{
    bool res = env0.GetLandmarkDetails(point_id, ind, lat, lon, name, address, info, street, amenity, roadId, roadLat, roadLon);
    if (res)
    {
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

bool MySbpl::freePlan(int** plan)
{
    delete [] *plan;
    
    int rcount = (int)env0.roads_.size();
    int lcount = (int)env0.landmarks_.size();
    SBPL_PRINTF("freePlan: rcount = %d, lcount = %d", rcount, lcount);

    return true;
}

bool MySbpl::freeMemory(long long int** ptr)
{
    delete [] *ptr;
    
    int rcount = (int)env0.roads_.size();
    int lcount = (int)env0.landmarks_.size();
    SBPL_PRINTF("freeMemory: rcount = %d, lcount = %d", rcount, lcount);
    return true;
}

bool MySbpl::generatePlan(int k, long long int start_pointId, long long int start_roadId, int start_type, int start_dir, long long int goal_pointId, long long int goal_roadId, int goal_type, int goal_dir, int mode, int* pathlen, int* k0len, int* k1len, int** plan)
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
    int rcount = (int)env0.roads_.size();
    int lcount = (int)env0.landmarks_.size();
    SBPL_PRINTF("generatePlan for env0: rcount = %d, lcount = %d", rcount, lcount);

    rcount = (int)env->roads_.size();
    lcount = (int)env->landmarks_.size();
    SBPL_PRINTF("generatePlan for env: rcount = %d, lcount = %d", rcount, lcount);

    
    //env->OpenDebugFiles(docDirectory);
    printf("roads: %d roadIds: %d landmarks: %d landmarkIds %d\n", (int)env->roads_.size(), (int)env->roadIds_.size(), (int)env->landmarks_.size(), (int)env->landmarkIds_.size());
    
    
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
    printf("pathlen = %d ret = %d\n", *pathlen, ret);
    
    if (!ret || *pathlen <= 0)
    {
        //printf("Error: Path not found!\n");
        //fflush(stdout);
        return false;
    }
    else
    {
        //spath = env->ConvertStatePathToLatLonPath(&ppcpSolutionIds);
        //fflush(stdout);
        //strcpy(path, spath.c_str());

        *k0len = 0;
        *k1len = 0;
        for (int i = 0; i < *pathlen; i++)
        {
            int currInd = ppcpSolutionIds[i][0];
            int succInd = ppcpSolutionIds[i][1];
            
            PPCPState* curstate = env->ppcp.ppcpStates_[currInd];
            PPCPState* succstate = env->ppcp.ppcpStates_[succInd];
            
            if (curstate->k == succstate->k)
            {
                if (curstate->k == 0)
                    (*k0len)++;
                else if (curstate->k == 1)
                    (*k1len)++;
            }
        }

        if (mode == 1)
        {
            int count = 3*(*pathlen);
            *plan = new int[count];
            int j = 0;
        
            for (int i = 0; i < *pathlen; i++)
            {
                int currInd = ppcpSolutionIds[i][0];
                int succInd = ppcpSolutionIds[i][1];
            
                PPCPState* curstate = env->ppcp.ppcpStates_[currInd];
                PPCPState* succstate = env->ppcp.ppcpStates_[succInd];
                
                //printf("%d %d %d %d %d\n", i, curstate->k, currInd, succstate->k, succInd);
            
                if (curstate->k == succstate->k)
                {
                    (*plan)[j*3] = curstate->k;
                    (*plan)[j*3+1] = currInd;
                    (*plan)[j*3+2] = succInd;
                    j++;
                }
            }
        
            SBPL_PRINTF("k0len = %d k1len = %d j = %d pathlen = %d", *k0len, *k1len, j, *pathlen);
        }
        
        //Delete Policy and deallocate the memory
        for (int i = 0; i < *pathlen; i++)
        {
            delete ppcpSolutionIds[i];
        }
    }
    return true;
}