//
//  RoomViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "RoomViewController.h"
#import "SpotifyAPIManager.h"
#import "SpotifySessionManager.h"
#import "ParseObjectManager.h"
#import "RoomManager.h"
#import "SongCell.h"
#import "UITableView+AnimationControl.h"

@interface RoomViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentSongTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentSongArtistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *currentSongAlbumImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation RoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView];
    [self configureObservers];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateQueueViews];
}

- (void)configureTableView {
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 66.f;
    [_tableView registerClass:[SongCell class] forCellReuseIdentifier:@"QueueCell"];
}

- (void)configureObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRoomViews) name:RoomManagerJoinedRoomNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearRoomViews) name:RoomManagerLeftRoomNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateQueueViews) name:RoomManagerUpdatedQueueNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentSongViews) name:RoomManagerUpdatedCurrentSongNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTrackViews) name:SpotifySessionManagerAuthorizedNotificaton object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedSpotifyAuthenticationAlert) name:SpotifyAPIManagerFailedAccessTokenNotification object:nil];
}

# pragma mark - Notification Selectors

- (void)loadRoomViews {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self->_roomNameLabel.text = [[RoomManager shared] currentRoomName];
        [self updateQueueViews];
    });
}

- (void)clearRoomViews {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self->_roomNameLabel.text = @"";
    });
}

- (void)updateQueueViews {
    [self updateCurrentSongViews];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self->_tableView reloadDataWithAnimation];
    });
}

- (void)updateCurrentSongViews {
    Track *track = [[RoomManager shared] currentTrack];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self->_currentSongTitleLabel.text = track.title;
        self->_currentSongArtistLabel.text = track.artist;
        self->_currentSongAlbumImageView.image = track.albumImage;
    });
}

- (void)updateTrackViews {
    [[RoomManager shared] reloadTrackData];
}

# pragma mark - IBActions

- (IBAction)didTapPlay:(id)sender {
    [[RoomManager shared] playTopSong];
}

- (IBAction)didTapLeaveRoom:(id)sender {
    [self leaveRoomAlert];
}

# pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[RoomManager shared] queue].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QueueCell"];
    Song *song = [[RoomManager shared] queue][indexPath.row];
    
    cell.objectId = song.requestId;
    cell.score = song.score;
    cell.voteState = song.voteState;
    cell.cellType = QueueCell;
    
    // track data
    cell.title = song.track.title;
    cell.subtitle = song.track.artist;
    cell.image = song.track.albumImage;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // hosts can swipe to delete any cell
    if ([[RoomManager shared] isCurrentUserHost]) {
        return YES;
    }
    
    // TODO: members can swipe to delete songs they requested
    
    return NO;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Song *song = [[RoomManager shared] queue][indexPath.row];
        [ParseObjectManager deleteRequestWithId:song.requestId];
    }
    
}

# pragma mark - Alerts

- (void)failedSpotifyAuthenticationAlert {
    
    NSString *title = @"Failed to authenticate";
    NSString *message = @"Could not connect to Spotify in time to load queue data. Retry now or check status in your Profile.";
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *retryButton = [UIAlertAction
                                  actionWithTitle:@"Try Again"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action) {
                                    [[SpotifySessionManager shared] authorizeSession];
                                }];

   [alert addAction:retryButton];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self presentViewController:alert animated:YES completion:nil];
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
                                }];

   [alert addAction:cancelButton];
   [alert addAction:leaveButton];

    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self presentViewController:alert animated:YES completion:nil];
    });
    
}

@end
