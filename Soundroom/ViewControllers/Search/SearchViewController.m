//
//  SearchViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "SearchViewController.h"
#import "SpotifyAPIManager.h"
#import "ParseQueryManager.h"
#import "Song.h" // need for VoteStatus
#import "SongCell.h"
#import "UITableView+AnimationControl.h"

@interface SearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchTypeControl;

@property (nonatomic, strong) NSMutableArray<Track *> *tracks;
@property (nonatomic, strong) NSMutableArray<PFUser *> *users;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 66.f;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // TODO: simplify
    if (self.isUserSearch) {
        self.searchTypeControl.selectedSegmentIndex = 1;
        self.searchTypeControl.userInteractionEnabled = NO;
    } else {
        self.searchTypeControl.selectedSegmentIndex = 0;
        self.searchTypeControl.userInteractionEnabled = YES;
    }
    
    [self.tableView registerClass:[SongCell class] forCellReuseIdentifier:@"SearchCell"];
    
    self.searchBar.delegate = self;
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isTrackSearch]) {
        return self.tracks.count;
    }
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    
    if ([self isTrackSearch]) {
        Track *track = self.tracks[indexPath.row];
        cell.title = track.title;
        cell.subtitle = track.artist;
        cell.image = track.albumImage;
        cell.objectId = track.spotifyId;
        cell.cellType = TrackCell;
        return cell;
    }
    
    PFUser *user = self.users[indexPath.row];
    cell.title = [user valueForKey:@"displayName"];
    cell.subtitle = [user valueForKey:@"username"];
    cell.image = [UIImage imageNamed:@"check"]; // TODO: avatar images
    cell.objectId = user.objectId;
    cell.cellType = UserCell;
    return cell;
    
}

#pragma mark - Search Bar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendSearchRequest) object:nil];
    [self performSelector:@selector(sendSearchRequest) withObject:nil afterDelay:0.4f];
}

- (void)sendSearchRequest {
    
    NSString *searchText = _searchBar.text;
    
    if (searchText.length == 0) {
        [self clearSearchData];
        return;
    }
    
    if ([self isTrackSearch]) {
        [self searchTracksWithQuery:searchText];
        return;
    }
    
    [self searchUsersWithQuery:searchText];
    
}

- (void)clearSearchData {
    _tracks = nil;
    _users = nil;
    [_tableView reloadDataWithAnimation];
}

- (void)searchTracksWithQuery:(NSString *)query {
    [[SpotifyAPIManager shared] getTracksWithQuery:query completion:^(NSArray *tracks, NSError *error) {
        if (tracks) {
            self->_tracks = (NSMutableArray<Track *> *)tracks;
            [self->_tableView reloadDataWithAnimation];
        }
    }];
}

- (void)searchUsersWithQuery:(NSString *)query {
    [ParseQueryManager getUsersWithUsername:query completion:^(NSArray *users, NSError *error) {
        if (users) {
            self->_users = (NSMutableArray<PFUser *> *)users;
            [self->_tableView reloadDataWithAnimation];
        }
    }];
}

- (BOOL)isTrackSearch {
    return self.searchTypeControl.selectedSegmentIndex == 0;
}

- (IBAction)didTapScreen:(id)sender {
    [self.view endEditing:YES];
}

@end
