//
//  sbpltest.cpp
//  LmarkPlanner
//
//  Created by Margarita Safonova on 4/23/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

#include <stdio.h>
#include <cmath>
#include <cstring>
#include <iostream>
#include <string>

#include "/Users/rsafonov/dev/sbpl_maps/src/include/sbpl/discrete_space_information/map.h"
#include "/Users/rsafonov/dev/sbpl_maps/src/include/sbpl/headers.h"


#include "sbpltets.hpp"

using namespace std;

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

void getPlanFromSbplByJson(string str)
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
    
    vector<Point*> latLonPath;
    env.ConvertStatePathToLatLonPath(solutionstates, &latLonPath);
    
    for (int i=0; i<(int)latLonPath.size(); i++)
    {
        printf("%lld %f %f\n", latLonPath[i]->id, latLonPath[i]->latitude, latLonPath[i]->longitude);
    }
    
    std::cout << "Done! path has been found." << "\n";
    
}









