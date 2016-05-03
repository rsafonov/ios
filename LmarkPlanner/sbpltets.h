//
//  sbpltets.h
//  LmarkPlanner
//
//  Created by Margarita Safonova on 4/25/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

#ifndef sbpltets_h
#define sbpltets_h

//#import <Foundation/Foundation.h>
//#import <MapKit/Mapkit.h>

#pragma once
#include <stdio.h>
//#include <cmath>
//#include <cstring>
#include <iostream>
#include <string>

//#include "/Users/rsafonov/dev/sbpl_maps/src/include/sbpl/discrete_space_information/map.h"
#//include "/Users/rsafonov/dev/sbpl_maps/src/include/sbpl/headers.h"

//#include <string>
#include <vector>
//#include <sbpl/discrete_space_information/map.h>


using namespace std;

void getPlanFromSbpl();
vector<long long int>  getPlanFromSbplByJson(std::string str);

#endif /* sbpltets_h */
