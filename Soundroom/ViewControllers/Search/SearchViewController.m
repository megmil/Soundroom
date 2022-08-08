//
//  SearchViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "SearchViewController.h"
#import "MusicCatalogManager.h"
#import "ParseQueryManager.h"
#import "ParseUserManager.h"
#import "ParseObjectManager.h"
#import "SongCell.h"
#import "Track.h"
#import "UITableView+ReuseIdentifier.h"

static const NSUInteger emptySearchCount = 20;

@interface SearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, AddCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchTypeControl;

@property (nonatomic, strong) NSArray <Track *> *tracks;
@property (nonatomic, strong) NSArray <PFUser *> *users;

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
    _searchTypeControl.selectedSegmentIndex = (_searchType == UserSearch) ? 1 : 0;
    _searchTypeControl.enabled = (_searchType == TrackAndUserSearch);
    [_searchTypeControl addTarget:self action:@selector(clearSearchData) forControlEvents:UIControlEventValueChanged];
}

# pragma mark - Actions

- (IBAction)didTapScreen:(id)sender {
    [self.view endEditing:YES];
}

- (void)didAddObjectWithId:(NSString *)objectId deezerId:(NSString *)deezerId {
    
    // warning if current user is not in a room
    if (![ParseUserManager isCurrentUserInRoom]) {
        [self missingRoomAlert];
        return;
    }
    
    // invite user to room
    if ([self searchType] == UserSearch) {
        [ParseObjectManager createInvitationToCurrentRoomForUserWithId:objectId];
        return;
    }
    
    // request track in queue
    [ParseObjectManager createRequestInCurrentRoomWithISRC:objectId deezerId:deezerId];
    
}

# pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.searchType == TrackSearch) {
        return _tracks.count;
    }
    
    return _users.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:[SongCell reuseIdentifier]];
    cell.cellType = SearchCell;
    cell.addDelegate = self;
    
    if (self.searchType == TrackSearch) {
        Track *track = _tracks[indexPath.row];
        cell.title = track.title;
        cell.subtitle = track.artist;
        cell.imageURL = track.albumImageURL;
        cell.objectId = track.isrc;
        cell.deezerId = track.deezerId;
        return cell;
    }
    
    PFUser *user = _users[indexPath.row];
    cell.title = user.username;
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
    
    if (searchText == nil || searchText.length == 0) {
        [self clearSearchData];
        return;
    }
    
    if (self.searchType == TrackSearch) {
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
    [[MusicCatalogManager shared] getTracksWithQuery:query completion:^(NSArray *tracks, NSError *error) {
        if (tracks) {
            if ([query isEqualToString:self->_searchBar.text]) {
                self->_tracks = (NSArray <Track *> *)tracks;
                [self->_tableView reloadData];
            }
        }
    }];
}

- (void)searchUsersWithQuery:(NSString *)query {
    [ParseQueryManager getUsersWithUsername:query completion:^(NSArray *users, NSError *error) {
        if (users) {
            if ([query isEqualToString:self->_searchBar.text]) {
                self->_users = (NSArray <PFUser *> *)users;
                [self->_tableView reloadData];
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

- (NSArray <Track *> *)emptyTracks {
    NSMutableArray <Track *> *tracks = [NSMutableArray new];
    for (NSUInteger i = 0; i < emptySearchCount; i++) {
        Track *track = [[Track alloc] init];
        [tracks addObject:track];
    }
    return tracks;
}

- (NSArray <PFUser *> *)emptyUsers {
    NSMutableArray <PFUser *> *users = [NSMutableArray new];
    for (NSUInteger i = 0; i < emptySearchCount; i++) {
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

# pragma mark - Reload Table

// TODO: test if faster than reloadData
- (void)replaceUnloadedArray:(NSMutableArray *)unloadedArray loadedArray:(NSArray *)loadedArray query:(NSString *)query {

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

    if ([query isEqualToString:_searchBar.text]) {
        [_tableView beginUpdates];
        [_tableView reconfigureRowsAtIndexPaths:indexPathsToReconfigure];
        [_tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationNone];
        [_tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationNone];
        [_tableView endUpdates];
    }

}

@end
