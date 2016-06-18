//
//  Video.m
//  WWDC2x
//
//  Created by iMac on 8/26/15.
//  Copyright (c) 2015 iMac. All rights reserved.
//

#import "Video.h"

@implementation Video
-(NSString *)urlString
{
    if (!_urlString) {
        _urlString = [[NSString alloc]init];
    }
    return _urlString;
}

-(NSString *)videoTitle
{
    if (!_videoTitle) {
        _videoTitle = [[NSString alloc]init];
    }
    return _videoTitle;
}

-(NSString *)year
{
    if (!_year) {
        _year = [[NSString alloc]init];
    }
    return _year;
}

@end
