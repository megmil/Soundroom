//
//  SearchViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "SearchViewController.h"
#import "Song.h"
#import "QueueSong.h"
#import "UIImageView+AFNetworking.h"
#import "SpotifyAPIManager.h"
#import "ParseUserManager.h"
#import "SearchCell.h"

@interface SearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchTypeControl;

@property (nonatomic, strong) NSMutableArray<Song *> *songs;
@property (nonatomic, strong) NSMutableArray<PFUser *> *users;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // TODO: simplify
    if (self.isUserSearch) {
        self.searchTypeControl.selectedSegmentIndex = 1;
        self.searchTypeControl.userInteractionEnabled = NO;
    } else {
        self.searchTypeControl.selectedSegmentIndex = 0;
        self.searchTypeControl.userInteractionEnabled = YES;
    }
    
    [self.tableView registerClass:[SearchCell class] forCellReuseIdentifier:@"SearchCell"];
    
    self.searchBar.delegate = self;
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isSongSearch]) {
        return self.songs.count;
    }
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    
    if ([self isSongSearch]) {
        Song *song = self.songs[indexPath.row];
        cell.title = song.title;
        cell.subtitle = song.artist;
        cell.image = song.albumImage;
        cell.objectId = song.spotifyId;
        cell.isAddSongCell = YES;
        cell.isUserCell = NO;
        cell.isQueueSongCell = NO;
        return cell;
    }
    
    PFUser *user = self.users[indexPath.row];
    cell.title = [user valueForKey:@"displayName"];
    cell.subtitle = [user valueForKey:@"username"];
    cell.image = [UIImage imageNamed:@"check"]; // TODO: avatar images
    cell.objectId = user.objectId;
    cell.isAddSongCell = NO;
    cell.isUserCell = YES;
    cell.isQueueSongCell = NO;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.f;
}

#pragma mark - Search Bar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length == 0) {
        return;
    }
    
    if ([self isSongSearch]) {
        [self searchSongsWithQuery:searchText];
        return;
    }
    
    [self searchUsersWithQuery:searchText];
}

- (void)searchSongsWithQuery:(NSString *)query {
    [[SpotifyAPIManager shared] getSongsWithQuery:query completion:^(NSArray *songs, NSError *error) {
        if (songs) {
            self.songs = (NSMutableArray<Song *> *)songs;
            [self.tableView reloadData];
        }
    }];
}

- (void)searchUsersWithQuery:(NSString *)query {
    [ParseUserManager getUsersWithUsername:query completion:^(NSArray *users, NSError *error) {
        if (users) {
            self.users = (NSMutableArray<PFUser *> *)users;
            [self.tableView reloadData];
        }
    }];
}

- (BOOL)isSongSearch {
    return self.searchTypeControl.selectedSegmentIndex == 0;
}

@end
