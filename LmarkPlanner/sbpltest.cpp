//
//  sbpltest.cpp
//  LmarkPlanner
//
//  Created by Margarita Safonova on 4/23/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

#include "sbpltets.h"

#include <stdio.h>
#include <cmath>
#include <cstring>
#include <iostream>
#include <string>

#include "/Users/rsafonov/dev/sbpl_maps/src/include/sbpl/discrete_space_information/map.h"
#include "/Users/rsafonov/dev/sbpl_maps/src/include/sbpl/headers.h"


//#include "sbpltets.hpp"


void getPlanFromSbpl()
{
    int sol_cost;
    std::vector<EnvState*> solutionstates;
    std::vector<int> solutionIds;
    EnvState startState, goalState;
    
    MapEnv env;
    startState = env.CreateState(143, 1, 0, 0);
    goalState = env.CreateState(183, 171, 0, 0);
    
    std::string dir = "/Users/rsafonov/dev/LandmarkPlanner/";
    std::string roads_file = dir + "Roads.txt";
    std::string landmarks_file = dir + "Landmarks.txt";
    
    env.InitializeEnv(roads_file, landmarks_file);
    env.setStartState(startState);
    env.setGoalState(goalState);
    
    env.findOptimalPath(&sol_cost, solutionstates, solutionIds);
    std::cout << "Done! path has been found." << "\n";
    
}

EnvState CreateStateFromOsm(long long int nid, MapEnv* env, vector<Road*>* roads)
{
    EnvState state;
    long long int rid;
    
    printf("CreateStateFromOsm start: nid = %lld\n", nid);
    fflush(stdout);
    
    for (int i=0; i<roads->size(); i++)
    {
        if ((*roads)[i]->roadends[0] == nid) // || (*roads)[i]->roadends[1] == nid)
        {
            rid = (*roads)[i]->id;
            break;
        }
    }
    printf("rid = %lld nid = %lld\n", rid, nid);
    fflush(stdout);
    
    state = env->CreateState(rid, nid, 0, 1);
    return state;
}

vector<long long int> getPlanFromSbplByJson(string str)
{
    int sol_cost;
    std::vector<EnvState*> solutionstates;
    std::vector<int> solutionIds;
    EnvState startState, goalState;
    
    MapEnv env;
    boost::unordered_map<long, int> replaceIds;
    vector<Road*> roads;
    
    OsmParams params;
    params.mode = 0;
    params.roads_file_name = "out/myroads.txt";
    params.landmarks_file_name = "out/mylandmarks.txt";
    params.amenities_file_name = "out/myamenities.txt";
    params.ways_file_name = "out/myways.txt";
    params.roadinfo_file_name = "out/myroadinfo.txt";
    
    env.InitializeEnvByJson(str, &roads, params);
    startState = CreateStateFromOsm(105013433, &env, &roads);
    goalState = CreateStateFromOsm(105097518, &env, &roads);
    
    //std::cout << "press any key to continue...";
    //getchar();
    
    env.setStartState(startState);
    env.setGoalState(goalState);
    env.ComputeHeuristic();
    
    env.findOptimalPath(&sol_cost, solutionstates, solutionIds);
    //environment.findOptimalPPCPPath(&ppcpSolutionIds);
    
    printf("sol_cost = %d solutionIds.size = %d solutionstates.size = %d\n", sol_cost, (int)solutionIds.size(), (int)solutionstates.size());
    fflush(stdout);
    
    
    //int len = (int)solutionstates.size();
    vector<long long int> pid;
    for (int i=0; i<(int)solutionstates.size(); i++)
    {
        printf("i=%d %lld %lld %u\n", i, solutionstates[i]->roadId, solutionstates[i]->pointId, solutionstates[i]->roadDir);
        pid.push_back(solutionstates[i]->pointId);
    }
    
    return pid;
    
    //vector<Spoint*> latLonPath;
    //env.ConvertStatePathToLatLonPath(solutionstates, &latLonPath);
    
    //vector< vector<double> > latlon;
    //int len = (int)latLonPath.size();
    //latlon.resize(len);
    
    //for (int i=0; i<(int)latLonPath.size(); i++)
    //{
    //    printf("%lld %f %f\n", latLonPath[i]->id, latLonPath[i]->latitude, latLonPath[i]->longitude);
    //    latlon[i].resize(2);
    //    latlon[i][0] = latLonPath[i]->latitude;
    //    latlon[i][1] = latLonPath[i]->longitude;
        
    //}
    
    //std::cout << "Done! path has been found." << "\n";
    
    //return latLonPath;
    
}









