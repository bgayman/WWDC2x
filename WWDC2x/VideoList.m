//
//  VideoList.m
//  WWDC2x
//
//  Created by iMac on 8/26/15.
//  Copyright (c) 2015 iMac. All rights reserved.
//

#import "VideoList.h"
#import "Video.h"

@implementation VideoList
-(NSMutableArray *) videoList
{
    if (!_videoList) {
        _videoList = [[NSMutableArray alloc]init];
    }
    return _videoList;
}

-(NSString *) year
{
    if (!_year) {
        _year = [[NSString alloc]init];
    }
    return _year;
}

-(instancetype) init
{
    NSDictionary *dict = [[NSDictionary alloc]init];
    self = [self initWithDictionary:dict];
    return self;
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    //NSString *plistPath = [[NSBundle mainBundle]pathForResource:@"VideoPList" ofType:@"plist"];
    self.year = [dictionary objectForKey:@"Year"];
    NSArray *array = [dictionary objectForKey:@"Videos"];
    NSArray *watchedVideoArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"Watched Videos"];
    for (NSDictionary * dict in array) {
        
        
        Video *video = [[Video alloc]init];
        video.year = self.year;
        if ([dict objectForKey:@"URL"]) {
            video.urlString = [dict objectForKey:@"URL"];
        }
        if ([dict objectForKey:@"Title"]) {
            video.videoTitle = [dict objectForKey:@"Title"];
        }
        if (watchedVideoArray!=nil && [watchedVideoArray count]) {
            for (NSString *string in watchedVideoArray) {
                if ([string isEqualToString:[NSString stringWithFormat:@"%@ %@",video.videoTitle,self.year]]) {
                    video.didWatch = YES;
                }
            }
        }
        [self.videoList addObject:video];
    }
    return self;
}

@end
