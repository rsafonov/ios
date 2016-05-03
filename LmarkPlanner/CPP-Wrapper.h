//
//  CPP-Wrapper.h
//  LmarkPlanner
//
//  Created by Margarita Safonova on 4/25/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

//#ifndef CPP_Wrapper_h
//#define CPP_Wrapper_h

#import <Foundation/Foundation.h>
#import <MapKit/Mapkit.h>

@interface CPP_Wrapper : NSObject
- (NSInteger*) getPlanFromSbplByJson_wrapped: (NSString*) name;

@end

//#endif /* CPP_Wrapper_h */
