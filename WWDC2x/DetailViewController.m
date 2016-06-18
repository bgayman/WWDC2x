//
//  DetailViewController.m
//  WWDC2x
//
//  Created by iMac on 8/26/15.
//  Copyright (c) 2015 iMac. All rights reserved.
//

#import "DetailViewController.h"
@import AVFoundation;
@import AVKit;

typedef NS_ENUM(NSInteger, WWDCVideoPlayBackRate) {
    WWDCVideoPlayBackRateNormal = 0,
    WWDCVideoPlayBackRateOneHalf,
    WWDCVideoPlayBackRateDouble
};

@interface DetailViewController ()
@property (nonatomic, strong)AVPlayer *player;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@end

@implementation DetailViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.title = @"";
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        [self configureView];
    }
}

- (void)configureView {
    if (self.detailItem) {
        self.title = self.detailItem.videoTitle;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"PlayVideo"])
    {
        AVPlayerViewController *playerViewController = segue.destinationViewController;
        
        NSURL *videoURL = [NSURL URLWithString:self.detailItem.urlString];
        playerViewController.player = [AVPlayer playerWithURL:videoURL];
        [self setUpPrerollWithPlayer];
        self.player = playerViewController.player;
        self.player.allowsExternalPlayback = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [self.player addObserver:self forKeyPath:@"rate" options:0 context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"rate"])
    {
        if ([self.player rate]<=1.0)
        {
            self.segmentedControl.selectedSegmentIndex = WWDCVideoPlayBackRateNormal;
        }
        else if ([self.player rate]<=1.5)
        {
            self.segmentedControl.selectedSegmentIndex = WWDCVideoPlayBackRateOneHalf;
        }
        else
        {
            self.segmentedControl.selectedSegmentIndex = WWDCVideoPlayBackRateDouble;
        }
    }
}

-(void)itemDidFinishPlaying
{
    self.detailItem.didWatch = YES;
    NSMutableArray *watchedVideos = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"Watched Videos"]];
    [watchedVideos addObject:[NSString stringWithFormat:@"%@ %@",self.detailItem.videoTitle,self.detailItem.year]];
    
    [[NSUserDefaults standardUserDefaults] setObject:watchedVideos forKey:@"Watched Videos"];
    [[NSUbiquitousKeyValueStore defaultStore] setObject:watchedVideos forKey:@"Watched Videos"];
}

- (IBAction)segmentedControlChanged:(UISegmentedControl *)sender {
    NSString *rateString = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
    rateString = [rateString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"×"]];
    float rate = [rateString floatValue];
    [self playAtSpeed:rate];
}

-(void)playAtSpeed:(float)rate
{
    [self.player play];
    self.player.rate = rate;
}

-(void)setUpPrerollWithPlayer
{
    if (self.player.status ==AVPlayerStatusReadyToPlay) {
        [self.player prerollAtRate:1.0 completionHandler:^(BOOL finished){
            if (finished) {
                [self playAtSpeed:1.0];
            }
        }];
    }else{
        [self performSelector:@selector(setUpPrerollWithPlayer) withObject:nil afterDelay:0.25];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.player removeObserver:self forKeyPath:@"rate"];
}

@end
