//
//  Video.h
//  WWDC2x
//
//  Created by iMac on 8/26/15.
//  Copyright (c) 2015 iMac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Video : NSObject
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *videoTitle;
@property (nonatomic, strong) NSString *year;
@property (nonatomic) BOOL didWatch;
@end
