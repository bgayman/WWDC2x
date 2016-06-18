//
//  VideoLists.m
//  WWDC2x
//
//  Created by iMac on 8/29/15.
//  Copyright (c) 2015 iMac. All rights reserved.
//

#import "VideoLists.h"
#import "VideoList.h"

@implementation VideoLists

-(NSMutableArray *)videoLists
{
    if (!_videoLists) {
        _videoLists = [[NSMutableArray alloc]init];
    }
    return _videoLists;
}

-(instancetype)init
{
    self = [super init];
    NSURL *plistURL = [NSURL URLWithString:@"http://bradgayman.com/VideoPList.plist"];
    NSArray *array = [[NSArray alloc]initWithContentsOfURL:plistURL];
    for (NSDictionary *dict in array) {
        VideoList *videoList = [[VideoList alloc]initWithDictionary:dict];
        [self.videoLists addObject:videoList];
    }
    return self;
}

@end
