//
//  sbpltets.h
//  LmarkPlanner
//
//  Created by Margarita Safonova on 4/25/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

#ifndef sbpltets_h
#define sbpltets_h

#pragma once
#include <string>

void getPlanFromSbpl();
//EnvState CreateStateFromOsm(long long int nid, MapEnv* env, vector<Road*>* roads);
void getPlanFromSbplByJson(std::string str);

#endif /* sbpltets_h */
