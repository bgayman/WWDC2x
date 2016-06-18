//
//  MasterViewController.m
//  WWDC2x
//
//  Created by iMac on 8/26/15.
//  Copyright (c) 2015 iMac. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "VideoLists.h"
#import "VideoList.h"
#import "Video.h"

@interface MasterViewController () <UISearchControllerDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) VideoLists *videoLists;
@property (nonatomic, strong) NSMutableArray *filteredVideoList;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.title = @"Videos";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

-(VideoLists *)videoLists
{
    if (!_videoLists) {
        _videoLists = [[VideoLists alloc]init];
    }
    return _videoLists;
}

-(NSMutableArray *)filteredVideoList
{
    if (!_filteredVideoList) {
        _filteredVideoList = [[NSMutableArray alloc]init];
    }
    return _filteredVideoList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    /*UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.searchResultsUpdater = self;
    searchController.dimsBackgroundDuringPresentation = NO;
    searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = searchController.searchBar;
    searchController.searchBar.showsScopeBar = YES;
    searchController.searchBar.scopeButtonTitles = @[@"Left",@"Right"];
    self.definesPresentationContext = YES;
    [searchController.searchBar sizeToFit];*/
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        Video *object = [[Video alloc]init];
        if ([[sender class]isSubclassOfClass:[Video class]]) {
            object =sender;
        }
        
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView){
        return [self.videoLists.videoLists count];
    }else{
        return 1;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return [(VideoList *)[self.videoLists.videoLists objectAtIndex:section] year];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView){
        return [[[self.videoLists.videoLists objectAtIndex:section] videoList]  count];
    }else{
        return [self.filteredVideoList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    Video *video = [[Video alloc]init];
    if (tableView == self.tableView) {
        video = [[[self.videoLists.videoLists objectAtIndex:indexPath.section] videoList] objectAtIndex:indexPath.row];
        cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:video.videoTitle];
    }else{
        video = [self.filteredVideoList objectAtIndex:indexPath.row];
        NSMutableAttributedString *searchTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - %@",video.videoTitle,video.year]];
        NSRange range = [[NSString stringWithFormat:@"%@ - %@",video.videoTitle,video.year] rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
        if (range.length) {
            [searchTitle addAttribute:NSForegroundColorAttributeName value:self.tableView.tintColor range:range];

        }
        cell.textLabel.attributedText = searchTitle;
    }
    if (video.didWatch) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Video *videoForRow = [[[self.videoLists.videoLists objectAtIndex:indexPath.section] videoList] objectAtIndex:indexPath.row];
    if (videoForRow.didWatch) {
        UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Unmark as\nViewed" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            videoForRow.didWatch = NO;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            NSMutableArray *watchedVideos = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"Watched Videos"]];
            NSMutableArray *videosToBeRemoved = [[NSMutableArray alloc]init];
            for (NSString *string in watchedVideos) {
                if ([string isEqualToString:[NSString stringWithFormat:@"%@ %@",videoForRow.videoTitle, videoForRow.year]]) {
                    [videosToBeRemoved addObject:string];
                }
            }
            [watchedVideos removeObjectsInArray:videosToBeRemoved];
            [[NSUserDefaults standardUserDefaults] setObject:watchedVideos forKey:@"Watched Videos"];
            [[NSUbiquitousKeyValueStore defaultStore] setObject:watchedVideos forKey:@"Watched Videos"];

            [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
        }];
        return @[rowAction];
    }else{
        UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Mark as\nViewed" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            videoForRow.didWatch = YES;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            NSMutableArray *watchedVideos = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"Watched Videos"]];
            [watchedVideos addObject:[NSString stringWithFormat:@"%@ %@",videoForRow.videoTitle,videoForRow.year]];
            
            [[NSUserDefaults standardUserDefaults] setObject:watchedVideos forKey:@"Watched Videos"];
            [[NSUbiquitousKeyValueStore defaultStore] setObject:watchedVideos forKey:@"Watched Videos"];

            [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
        }];
        return @[rowAction];
    }
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    if (tableView == self.tableView) {
        [self performSegueWithIdentifier:@"showDetail" sender:[[[self.videoLists.videoLists objectAtIndex:indexPath.section] videoList] objectAtIndex:indexPath.row]];
    }else{
        [self performSegueWithIdentifier:@"showDetail" sender:self.filteredVideoList[indexPath.row]];
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self.filteredVideoList removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.videoTitle contains[c] %@",searchText];
    NSMutableArray *tempArray =  [[NSMutableArray alloc]initWithArray:[[self.videoLists.videoLists[0] videoList]  filteredArrayUsingPredicate:predicate]];
    for(int i = 1; i<[self.videoLists.videoLists count];i++ ){
        [tempArray addObjectsFromArray:[[self.videoLists.videoLists[i] videoList]  filteredArrayUsingPredicate:predicate]];
    }
    self.filteredVideoList = tempArray;
}

-(BOOL)searchDisplayController:(UISearchController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[controller.searchBar scopeButtonTitles]
                                                         objectAtIndex:[controller.searchBar selectedScopeButtonIndex]]];
    return YES;
}


@end
