//
//  RoomViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "RoomViewController.h"
#import "LobbyViewController.h"
#import "MusicAPIManager.h"
#import "MusicPlayerManager.h"
#import "ParseObjectManager.h"
#import "ParseUserManager.h"
#import "RoomManager.h"
#import "EnumeratedTypes.h"
#import "SongCell.h"
#import "RoomView.h"
#import "Track.h"
#import "Song.h"
#import "UITableView+AnimationControl.h"
#import "UITableView+ReuseIdentifier.h"
#import "UITableView+EmptyMessage.h"

static NSString *const emptyTableMessage = @"No songs are currently in the queue.";

@interface RoomViewController () <UITableViewDelegate, UITableViewDataSource, RoomManagerDelegate, QueueCellDelegate, RoomViewDelegate>

@property (strong, nonatomic) IBOutlet RoomView *roomView;
@property (strong, nonatomic) NSArray <Song *> *queue;
@property (nonatomic) BOOL didCancelAlerts;

@end

@implementation RoomViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self fetchCurrentRoom];
    [self configureTableView];
    [self configureObservers];
    
    _didCancelAlerts = NO;
    _roomView.delegate = self;
    [RoomManager shared].delegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [_roomView refreshAnimations];
}

- (void)fetchCurrentRoom {
    // attempt to fetch room
    [[RoomManager shared] fetchCurrentRoomWithCompletion:^(BOOL isInRoom) {
        if (!isInRoom) {
            // if there is no room, present lobbyVC
            [self goToLobby];
        }
    }];
}

- (void)configureTableView {
    _roomView.tableView.delegate = self;
    _roomView.tableView.dataSource = self;
    [_roomView.tableView registerClass:[SongCell class] forCellReuseIdentifier:[SongCell reuseIdentifier]];
}

- (void)configureObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRoomViews) name:RoomManagerJoinedRoomNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTrackViews) name:MusicPlayerManagerAuthorizedNotificaton object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedMusicPlayerTokenNotification) name:MusicAPIManagerFailedAccessTokenNotification object:nil];
}

# pragma mark - Selectors

- (void)loadRoomViews {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        self->_queue = [[RoomManager shared] queue];

        [self updateCurrentTrackViews];
        
        self->_roomView.hidden = NO;
        self->_roomView.roomName = [[RoomManager shared] currentRoomName];
        if (![[RoomManager shared] isCurrentUserHost]) {
            self->_roomView.playState = Disabled;
        }
        
        [self->_roomView.tableView reloadDataWithAnimation];
        
    });
}

- (void)reloadTrackViews {
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        // dismiss failed authentication alert if necessary
        if ([[self presentedViewController] isKindOfClass:[UIAlertController class]]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    });
    
    // reload track data
    [[RoomManager shared] reloadTrackDataWithCompletion:^(void) {
        self->_queue = [[RoomManager shared] queue];
        [self updateCurrentTrackViews];
        [self->_roomView.tableView reloadData];
    }];
    
}

- (void)updateCurrentTrackViews {
    
    Track *track = [[RoomManager shared] currentTrack];
    _roomView.currentSongTitle = track.title;
    _roomView.currentSongArtist = track.artist;
    _roomView.currentSongAlbumImageURL = track.albumImageURL;
    
    if (![[RoomManager shared] isCurrentUserHost]) {
        _roomView.playState = Disabled;
        return;
    }
    
    _roomView.playState = track ? Playing : Paused;

}

- (void)goToLobby {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LobbyViewController *lobbyViewController = [storyboard instantiateViewControllerWithIdentifier:LobbyViewControllerIdentifier];
        [lobbyViewController setModalPresentationStyle:UIModalPresentationCurrentContext];
        [self presentViewController:lobbyViewController animated:YES completion:nil];
    });
}

# pragma mark - RoomView

- (void)didTapPlay {
    [[MusicPlayerManager shared] resumePlayback];
}

- (void)didTapPause {
    [[MusicPlayerManager shared] pausePlayback];
}

- (void)didTapSkip {
    [[RoomManager shared] playTopSong];
}

- (void)didTapLeave {
    [self leaveRoomAlert];
}

# pragma mark - QueueCell

- (void)didUpdateVoteStateForRequestWithId:(NSString *)requestId voteState:(VoteState)voteState {
    [[RoomManager shared] updateCurrentUserVoteForRequestWithId:requestId voteState:voteState];
}

# pragma mark - RoomManager

- (void)didUpdateCurrentTrack {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self updateCurrentTrackViews];
    });
}

- (void)didLeaveRoom {
    self->_roomView.hidden = YES;
    self->_queue = @[];
    [[MusicPlayerManager shared] pausePlayback]; // TODO: stop playback?
    [self goToLobby];
}

- (void)didLoadQueue {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self->_queue = [[RoomManager shared] queue];
        [self->_roomView.tableView reloadDataWithAnimation];
    });
}

- (void)didInsertSongAtIndex:(NSUInteger)index {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self->_queue = [[RoomManager shared] queue];
        [self->_roomView.tableView insertCellAtIndex:index];
    });
}

- (void)didMoveSongAtIndex:(NSUInteger)oldIndex toIndex:(NSUInteger)newIndex {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self->_queue = [[RoomManager shared] queue];
        [self->_roomView.tableView moveCellAtIndex:oldIndex toIndex:newIndex];
    });
}

- (void)didDeleteSongAtIndex:(NSUInteger)index {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self->_queue = [[RoomManager shared] queue];
        [self->_roomView.tableView deleteCellAtIndex:index];
    });
}

- (void)setPlayState:(PlayState)playState {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self->_roomView.playState = playState;
    });
}

# pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (!_queue.count) {
        [_roomView.tableView showEmptyMessageWithText:emptyTableMessage];
    } else {
        [_roomView.tableView removeEmptyMessage];
    }
    
    return _queue.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:[SongCell reuseIdentifier]];
    Song *song = _queue[indexPath.row];
    
    cell.objectId = song.requestId;
    cell.score = song.score;
    cell.voteState = song.voteState;
    cell.cellType = QueueCell;
    cell.queueDelegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // track data
    cell.title = song.track.title;
    cell.subtitle = song.track.artist;
    cell.imageURL = song.track.albumImageURL;
    [cell setNeedsLayout];
    
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // hosts can swipe to delete any cell
    if ([[RoomManager shared] isCurrentUserHost]) {
        return YES;
    }
    
    // members can swipe to delete songs they requested
    Song *song = _queue[indexPath.row];
    if (song.userId && [song.userId isEqualToString:[ParseUserManager currentUserId]]) {
        return YES;
    }
    
    return NO;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Song *song = _queue[indexPath.row];
        [ParseObjectManager deleteRequestWithId:song.requestId];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

# pragma mark - Alerts

- (void)failedMusicPlayerTokenNotification {
    
    if (_didCancelAlerts) {
        return;
    }
    
    NSString *title = @"Failed to authenticate";
    NSString *message = @"Could not connect to Spotify in time to load queue data. Retry now or check status in your Profile.";
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ignoreAction = [UIAlertAction
                                  actionWithTitle:@"Don't show again"
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction *action) {
                                    self->_didCancelAlerts = YES;
                                }];
    
    UIAlertAction *retryAction = [UIAlertAction
                                  actionWithTitle:@"Try Again"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action) {
                                    [[MusicPlayerManager shared] authorizeSession];
                                }];

    [alert addAction:retryAction];
    [alert addAction:ignoreAction];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        // check that self is not already presenting an alert / view controller
        if (![self presentedViewController]) {
            [self presentViewController:alert animated:YES completion:nil];
        }
    });
}

- (void)leaveRoomAlert {
    
    NSString *title = @"Leave Room";
    NSString *message = @"Are you sure you want to leave this room?";
    NSString *buttonMessage = @"Leave";
    if ([[RoomManager shared] isCurrentUserHost]) {
        title = @"End Session?";
        message = @"Are you sure you want to end this session?";
        buttonMessage = @"End";
    }
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action) { return; }];
    
    UIAlertAction *leaveButton = [UIAlertAction
                                  actionWithTitle:buttonMessage
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction *action) {
                                    [ParseObjectManager deleteInvitationsAcceptedByCurrentUser];
                                    [[RoomManager shared] clearRoomData];
                                }];

   [alert addAction:cancelButton];
   [alert addAction:leaveButton];

    dispatch_async(dispatch_get_main_queue(), ^(void) {
        // check that self is not already presenting an alert / view controller
        if (![self presentedViewController]) {
            [self presentViewController:alert animated:YES completion:nil];
        }
    });
    
}

@end
