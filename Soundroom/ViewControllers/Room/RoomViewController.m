//
//  RoomViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "RoomViewController.h"
#import "SpotifyAPIManager.h"
#import "SpotifySessionManager.h"
#import "ParseUserManager.h"
#import "RoomManager.h"
#import "QueueManager.h"
#import "VoteManager.h"
#import "QueueSong.h"
#import "Song.h"
#import "SongCell.h"
@import ParseLiveQuery;

@interface RoomViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentSongTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentSongArtistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *currentSongAlbumImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) PFLiveQueryClient *client;
@property (strong, nonatomic) PFLiveQuerySubscription *subscription;

@end

@implementation RoomViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self configureTableView];
    [self configureObservers];
    [self authorizeSpotifySession];
    [self configureLiveClient];
    
}

# pragma mark - ViewDidLoad Helpers

- (void)configureTableView {
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[SongCell class] forCellReuseIdentifier:@"QueueSongCell"];
}

- (void)configureObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRoomData) name:RoomManagerJoinedRoomNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearRoomData) name:RoomManagerLeftRoomNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateQueueData) name:QueueManagerUpdatedQueueNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateQueueData) name:SpotifySessionManagerAuthorizedNotificaton object:nil];
}

- (void)authorizeSpotifySession {
    if (![[SpotifySessionManager shared] isSessionAuthorized]) {
        [[SpotifySessionManager shared] authorizeSession];
    }
}

- (void)configureLiveClient {
    if (!didLoadCredentials) {
        [self loadParseCredentials];
    }
    _client = [[PFLiveQueryClient alloc] initWithServer:_server applicationId:_appId clientKey:_clientKey];
}

# pragma mark - Notification Selectors

- (void)loadRoomData {
    _roomNameLabel.text = [[RoomManager shared] currentRoomName];
    [[QueueManager shared] fetchQueue];
    [self configureSongSubscriptions];
}

- (void)clearRoomData {
    // TODO: fill in defaults
    _roomNameLabel.text = @"";
    [[QueueManager shared] resetQueue];
}

- (void)updateQueueData {
    [self updateCurrentSongData];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self->_tableView reloadData];
    });
}

- (void)updateCurrentSongData {
    
    NSString *currentSongId = [[RoomManager shared] currentSongId];
    NSString *currentSpotifyId = [QueueManager getSpotifyIdForSongWithId:currentSongId];
    
    // get spotify metadata
    if (currentSpotifyId) {
        [[SpotifyAPIManager shared] getSongWithSpotifyId:currentSpotifyId completion:^(Song *song, NSError *error) {
            if (song) {
                // update views
                self->_currentSongTitleLabel.text = song.title;
                self->_currentSongArtistLabel.text = song.artist;
                self->_currentSongAlbumImageView.image = song.albumImage;
                
                // if current user is host, play song
                if ([[RoomManager shared] isCurrentUserHost]) {
                    [[SpotifySessionManager shared] playSongWithSpotifyURI:song.spotifyURI];
                }
            }
        }];
    }
    
}

# pragma mark - IBActions

- (IBAction)didTapPlay:(id)sender {
    [[QueueManager shared] playTopSong];
}

- (IBAction)didTapLeaveRoom:(id)sender {
    
    if ([[RoomManager shared] isCurrentUserHost]) {
        [[RoomManager shared] deleteCurrentRoom];
        return;
    }
    
    [[RoomManager shared] leaveCurrentRoom];
    
}

# pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[QueueManager shared] queue].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QueueSongCell"];
    QueueSong *queueSong = [[QueueManager shared] queue][indexPath.row];
    
    cell.objectId = queueSong.objectId;
    cell.spotifyId = queueSong.spotifyId;
    cell.cellType = QueueSongCell;
    cell.voteState = [VoteManager voteStateForSong:queueSong];
    cell.score = [VoteManager scoreForSong:queueSong];
    
    // get spotify metadata
    [[SpotifyAPIManager shared] getSongWithSpotifyId:queueSong.spotifyId completion:^(Song *song, NSError *error) {
        if (song) {
            cell.title = song.title;
            cell.subtitle = song.artist;
            cell.image = song.albumImage;
        }
    }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.f;
}

# pragma mark - Live Query

- (void)configureSongSubscriptions {
    
    // reset subscriptions
    _subscription = nil;
    
    // check for valid roomId
    NSString *roomId = [[RoomManager shared] currentRoomId];
    if (!roomId) {
        return;
    }
    
    PFQuery *songQuery = [self queryQueueSongsWithRoomId:roomId];
    _subscription = [_client subscribeToQuery:songQuery];
    
    // create handler
    _subscription = [_subscription addCreateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        QueueSong *song = (QueueSong *)object;
        [[QueueManager shared] insertQueueSong:song];
    }];
    
    // delete handler
    _subscription = [_subscription addDeleteHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        QueueSong *song = (QueueSong *)object;
        [[QueueManager shared] removeQueueSong:song];
    }];
    
}

# pragma mark - Helpers

- (void)loadParseCredentials {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSMutableDictionary *credentials = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    _server = [credentials objectForKey:@"parse-live-server"];
    _appId = [credentials objectForKey:@"parse-app-id"];
    _clientKey = [credentials objectForKey:@"parse-client-key"];
    didLoadCredentials = YES;
}

- (PFQuery *)queryQueueSongsWithRoomId:(NSString * _Nonnull)roomId {
    PFQuery *query = [PFQuery queryWithClassName:@"Room"];
    [query whereKey:@"objectId" equalTo:roomId];
    return query;
}

@end
