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

bool MySbpl::setParams(int debug_mode, double policyTime, double computeTime)
{
    env0.dbg_params.mode = debug_mode;
    env0.dbg_params.max_landmark_road_distance = 200.0; //meters

    env0.dbg_params.roads_file_name = env0.dbg_params.dir + "/myroads.txt";
    env0.dbg_params.landmarks_file_name = env0.dbg_params.dir + "/mylandmarks.txt";
    env0.dbg_params.amenities_file_name = env0.dbg_params.dir + "/amenities.txt";
    env0.dbg_params.ways_file_name = env0.dbg_params.dir + "/ways.txt";
    env0.dbg_params.roadinfo_file_name = env0.dbg_params.dir + "/roadinfo.txt";
    env0.dbg_params.streets_file_name = env0.dbg_params.dir + "/streets.txt";
    env0.dbg_params.isections_file_name = env0.dbg_params.dir + "/isections.txt";
    env0.dbg_params.pois_file_name = env0.dbg_params.dir + "/pois.txt";
    env0.dbg_params.expands_file_name = env0.dbg_params.dir + "/expands.txt";
    env0.dbg_params.debug_file_name = env0.dbg_params.dir + "/debug.txt";
    env0.dbg_params.heuristics_file_name = env0.dbg_params.dir + "/heuristics.txt";
    
    env0.setTimes(policyTime, computeTime);
    return true;
}

bool MySbpl::initPlannerByOsm(string osmJsonStr, string excludedLmarks, string excludedIsections, long long int** lmarks, int* lmarks_count, long long int** intersections, int* intersections_count)
{
    bool res = env0.InitializeEnvByJson(osmJsonStr, excludedLmarks, excludedIsections, lmarks, lmarks_count, intersections, intersections_count);
    if (res)
    {
        //env.heuristicComputed = false;
        SBPL_PRINTF("env0.InitializeEnvByJson succeeded!");
        
        double computeTime = 0.0;
        double policyTime = 0.0;
        env0.ppcp.getTimes(&policyTime, &computeTime);
        
        FILE* fdbg = fopen(env0.dbg_params.debug_file_name.c_str(), "a");
        fprintf(fdbg, "computeTime: %f\n", computeTime);
        fprintf(fdbg, "policyTime:  %f\n", policyTime);
        fclose(fdbg);
    }
    else
    {
        SBPL_ERROR("Error: env0.InitializeEnvByJson failed!");
    }
    return res;
}
 
bool MySbpl::getIntresectionDetails(long long int point_id, int* ind, double* lat, double* lon, string& location, int* streetsCount)

{
    bool res = env0.GetIntersectionDetails(point_id, ind, lat, lon, location, streetsCount);
    if (!res)
        SBPL_ERROR("Error: getIntersectionDetails failed!\n");
    return res;
}

bool MySbpl::getLandmarkDetails(long long int point_id, int* ind, double* lat, double* lon, string& name, string& address, string& info, string& street, string& amenity, long long int* roadId, double* roadLat, double* roadLon)
{
    bool res = env0.GetLandmarkDetails(point_id, ind, lat, lon, name, address, info, street, amenity, roadId, roadLat, roadLon);
    if (!res)
        SBPL_ERROR("Error: getLandmarkDetails failed!\n");
    return res;
}

bool MySbpl::getSolutionStepDetails(int currInd, int succInd, long long int* pid1, long long int* pid2, int* act1, int* act2, int* type1, int* type2, int* dir1, int* dir2, double* lat1, double* lon1, double* lat2, double* lon2,
    int* envId1, int* envId2)
{
    bool res = env->GetSolutionStepDetails(currInd, succInd, pid1, pid2, act1, act2, type1, type2, dir1, dir2, lat1, lon1, lat2, lon2, envId1, envId2);
    if (!res)
        SBPL_ERROR("Error: getSolutionStepDetails failed!\n");
    return res;
}

bool MySbpl::freePlan(int** plan)
{
    delete [] *plan;
    return true;
}

bool MySbpl::freeMemory(long long int** ptr)
{
    delete [] *ptr;
    return true;
}

bool MySbpl::generatePlan(int k, long long int start_pointId, long long int start_roadId, int start_type, int start_dir, long long int goal_pointId, long long int goal_roadId, int goal_type, int goal_dir, int mode, int iter, int* pathlen, int* k0len, int* k1len, double* duration, int** plan)
{
    std::vector<int*> ppcpSolutionIds;
    string spath = "";
    double computeTime;
    double policyTime;
    bool plan_found = false;
    
    clock_t start_time = clock();
    
    if (env != NULL) delete env;

    env = new MapEnv();
    env->InitializeEnvByEnv(&env0, iter);
    //env->ppcp.debug_file_name = env0.dbg_params.debug_file_name;
    
    env0.ppcp.getTimes(&policyTime, &computeTime);
    SBPL_PRINTF("policyTyme = %f computeTime = %f", policyTime, computeTime);
    
    //FILE* fdbg = fopen(env->dbg_params.debug_file_name.c_str(), "a");
    //fprintf(fdbg, )

    
    SBPL_PRINTF("roads: %d roadIds: %d landmarks: %d landmarkIds %d", (int)env->roads_.size(), (int)env->roadIds_.size(), (int)env->landmarks_.size(), (int)env->landmarkIds_.size());
    
    EnvState start_state = env->CreateState(start_roadId, start_pointId, start_type, start_dir);
    env->setStartState(start_state);
    EnvState goal_state = env->CreateState(goal_roadId, goal_pointId, goal_type, goal_dir);
    env->setGoalState(goal_state);
    env->ComputeHeuristic();
    
    env->setSafetyNetDegree(k);
    env->setTimes(policyTime, computeTime);
    *duration = 0.0;
    bool ret = env->findOptimalPPCPPath(&ppcpSolutionIds, duration);
    
    *pathlen = (int)ppcpSolutionIds.size();
    SBPL_PRINTF("pathlen = %d ret = %d duration = %f", *pathlen, ret, *duration);
    
    if (!ret || *pathlen <= 0)
    {
        //SBPL_ERROR("Error: Path not found!");
        //fflush(stdout);
        //return false;
    }
    else
    {
        plan_found = true;
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
        SBPL_PRINTF("k0len = %d k1len = %d", *k0len, *k1len);

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
    
    if (env->dbg_params.mode > 0 && mode == 0)
    {
        FILE* fdbg = fopen(env->dbg_params.debug_file_name.c_str(), "a");
        
        fprintf(fdbg, "k=%d Start: r %lld p %lld t %d d %d ", k, start_roadId, start_pointId, start_type, start_dir);
        fprintf(fdbg, "Goal: r %lld p %lld t %d d %d ", goal_roadId, goal_pointId, goal_type, goal_dir);
        fprintf(fdbg, "time %f res %d k0len %d k1len %d\n", *duration, plan_found, *k0len, *k1len);
        fclose(fdbg);
    }
    
    double duration0 = ( clock() - start_time) / (double) CLOCKS_PER_SEC;
    SBPL_PRINTF("Execution time: %10.5f", duration0);
    return plan_found;
}