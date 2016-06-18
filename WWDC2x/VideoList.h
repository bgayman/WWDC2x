//
//  VideoList.h
//  WWDC2x
//
//  Created by iMac on 8/26/15.
//  Copyright (c) 2015 iMac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoList : NSObject
@property (strong, nonatomic) NSMutableArray *videoList;
@property (strong, nonatomic) NSString *year;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
