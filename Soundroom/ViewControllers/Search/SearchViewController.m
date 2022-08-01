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
#import "ParseConstants.h"
#import "ImageConstants.h"
#import "EnumeratedTypes.h"
#import "Track.h"
#import "ParseObjectManager.h"
#import "SongCell.h"
#import "UITableView+AnimationControl.h"
#import "UITableView+ReuseIdentifier.h"

@interface SearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, AddCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchTypeControl;

@property (nonatomic, strong) NSMutableArray <Track *> *tracks;
@property (nonatomic, strong) NSMutableArray <PFUser *> *users;

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
    _searchTypeControl.enabled = (_searchType == SearchTypeTrackAndUser);
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
    cell.title = user.username; // TODO: add display name
    cell.subtitle = user.username;
    cell.image = [ParseUserManager avatarImageForUser:user];
    cell.objectId = user.objectId;
    return cell;
    
}

#pragma mark - Search Bar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendSearchRequest) object:nil];
    [self performSelector:@selector(sendSearchRequest) withObject:nil afterDelay:0.4f];
}

- (void)sendSearchRequest {
    
    NSString *searchText = [_searchBar.text copy];
    
    if (searchText.length == 0) {
        [self clearSearchData];
        return;
    }
    
    if (self.searchType == SearchTypeTrack) {
        _tracks = [self emptyTracks];
        [_tableView reloadData];
        [self searchTracksWithQuery:searchText];
        return;
    }
    
    _users = [self emptyUsers];
    [_tableView reloadData];
    [self searchUsersWithQuery:searchText];
    
}

- (void)searchTracksWithQuery:(NSString *)query {
    [[SpotifyAPIManager shared] getTracksWithQuery:query completion:^(NSArray *tracks, NSError *error) {
        if (tracks) {
            if ([query isEqualToString:self->_searchBar.text]) {
                [self replaceUnloadedArray:self->_tracks loadedArray:tracks];
            }
        }
    }];
}

- (void)searchUsersWithQuery:(NSString *)query {
    [ParseQueryManager getUsersWithUsername:query completion:^(NSArray *users, NSError *error) {
        if (users) {
            if ([query isEqualToString:self->_searchBar.text]) {
                [self replaceUnloadedArray:self->_users loadedArray:users];
            }
        }
    }];
}

- (void)clearSearchData {
    _tracks = nil;
    _users = nil;
    [_tableView reloadData];
}

# pragma mark - Fill Table

- (void)replaceUnloadedArray:(NSMutableArray *)unloadedArray loadedArray:(NSArray *)loadedArray {

    NSMutableArray <NSIndexPath *> *indexPathsToReconfigure = [NSMutableArray new];
    NSMutableArray <NSIndexPath *> *indexPathsToDelete = [NSMutableArray new];
    NSMutableArray <NSIndexPath *> *indexPathsToInsert = [NSMutableArray new];

    while (unloadedArray.count > loadedArray.count) {
        [unloadedArray removeLastObject];
        NSUInteger row = unloadedArray.count - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [indexPathsToDelete addObject:indexPath];
    }

    for (NSUInteger index = 0; index < loadedArray.count; index++) {

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];

        if (index < unloadedArray.count) {
            [unloadedArray replaceObjectAtIndex:index withObject:loadedArray[index]];
            [indexPathsToReconfigure addObject:indexPath];
            continue;
        }

        [unloadedArray addObject:loadedArray[index]];
        [indexPathsToInsert addObject:indexPath];

    }

    [_tableView beginUpdates];
    [_tableView reconfigureRowsAtIndexPaths:indexPathsToReconfigure];
    [_tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationNone];
    [_tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];

}

# pragma mark - Helpers

- (NSMutableArray <Track *> *)emptyTracks {
    NSMutableArray <Track *> *tracks = [NSMutableArray new];
    for (int i = 0; i < 20; i++) {
        Track *track = [[Track alloc] init];
        [tracks addObject:track];
    }
    return tracks;
}

- (NSMutableArray <PFUser *> *)emptyUsers {
    NSMutableArray <PFUser *> *users = [NSMutableArray new];
    for (int i = 0; i < 20; i++) {
        PFUser *user = [[PFUser alloc] init];
        [users addObject:user];
    }
    return users;
}

- (SearchType)searchType {
    return _searchTypeControl.selectedSegmentIndex + 1;
}

- (void)missingRoomAlert {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Item could not be added"
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
