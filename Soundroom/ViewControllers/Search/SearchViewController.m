//
//  SearchViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "SearchViewController.h"
#import "SpotifyAPIManager.h"
#import "ParseQueryManager.h"
#import "ParseUserManager.h"
#import "Song.h" // need for VoteStatus
#import "ParseObjectManager.h"
#import "SongCell.h"
#import "UITableView+AnimationControl.h"
#import "UITableView+ReuseIdentifier.h"

@interface SearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, AddCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchTypeControl;

@property (nonatomic, strong) NSMutableArray<Track *> *tracks;
@property (nonatomic, strong) NSMutableArray<PFUser *> *users;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView];
    [self configureSearch];
}

- (void)configureTableView {
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 66.f;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[SongCell class] forCellReuseIdentifier:[SongCell reuseIdentifier]];
}

- (void)configureSearch {
    _searchBar.delegate = self;
    _searchTypeControl.selectedSegmentIndex = (_searchType == SearchTypeUser) ? 1 : 0;
    _searchTypeControl.userInteractionEnabled = (_searchType == SearchTypeTrackAndUser);
    [_searchTypeControl addTarget:self action:@selector(clearSearchData) forControlEvents:UIControlEventValueChanged];
}

# pragma mark - Actions

- (IBAction)didTapScreen:(id)sender {
    [self.view endEditing:YES];
}

- (void)didAddObjectWithId:(NSString *)objectId {
    
    // warning if current user is not in a room
    if (![ParseUserManager isInRoom]) {
        [self missingRoomAlert];
        return;
    }
    
    // request song in queue
    if (self.searchType == SearchTypeTrack) {
        [ParseObjectManager createRequestInCurrentRoomWithSpotifyId:objectId];
        return;
    }
    
    // invite user to room
    [ParseObjectManager createInvitationToCurrentRoomForUserWithId:objectId];
    
}

# pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchType == SearchTypeTrack) {
        return _tracks.count;
    }
    return _users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:[SongCell reuseIdentifier]];
    cell.cellType = SearchCell;
    cell.addDelegate = self;
    
    if (self.searchType == SearchTypeTrack) {
        Track *track = _tracks[indexPath.row];
        cell.title = track.title;
        cell.subtitle = track.artist;
        cell.image = track.albumImage;
        cell.objectId = track.spotifyId;
        return cell;
    }
    
    PFUser *user = _users[indexPath.row];
    cell.title = [user valueForKey:@"displayName"]; // TODO: implement
    cell.subtitle = user.username;
    cell.image = [UIImage systemImageNamed:@"check"]; // TODO: avatar images
    cell.objectId = user.objectId;
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
    
    if (self.searchType == SearchTypeTrack) {
        [self searchTracksWithQuery:searchText];
        return;
    }
    
    [self searchUsersWithQuery:searchText];
    
}

- (void)searchTracksWithQuery:(NSString *)query {
    [[SpotifyAPIManager shared] getTracksWithQuery:query completion:^(NSArray *tracks, NSError *error) {
        if (tracks) {
            if ([query isEqualToString:self->_searchBar.text]) {
                self->_tracks = (NSMutableArray<Track *> *)tracks;
                [self->_tableView reloadDataWithAnimation];
            }
        }
    }];
}

- (void)searchUsersWithQuery:(NSString *)query {
    [ParseQueryManager getUsersWithUsername:query completion:^(NSArray *users, NSError *error) {
        if (users) {
            if ([query isEqualToString:self->_searchBar.text]) {
                self->_users = (NSMutableArray<PFUser *> *)users;
                [self->_tableView reloadDataWithAnimation];
            }
        }
    }];
}

- (void)clearSearchData {
    _tracks = nil;
    _users = nil;
    [_tableView reloadData];
}

# pragma mark - Helpers

- (SearchType)searchType {
    return _searchTypeControl.selectedSegmentIndex + 1;
}

- (void)missingRoomAlert {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Failed to add item"
                                message:@"Please join or create a room before adding tracks or inviting users."
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction
                             actionWithTitle:@"Ok"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction *action) { }];

    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
