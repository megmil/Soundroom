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
    
    // configure table view
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[SongCell class] forCellReuseIdentifier:@"QueueSongCell"];
    
    // configure observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRoomData) name:RoomManagerJoinedRoomNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearRoomData) name:RoomManagerLeftRoomNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateQueueData) name:QueueManagerUpdatedQueueNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateQueueData) name:SpotifySessionManagerAuthorizedNotificaton object:nil];
    
    [self configureLiveQueryClient];
    [self authenticateSpotifySession];
    
}

# pragma mark - Notication Selectors

- (void)loadRoomData {
    _roomNameLabel.text = [[RoomManager shared] currentRoomName];
    // TODO: update roomId related subcriptions
    [[QueueManager shared] fetchQueue];
}

- (void)clearRoomData {
    // TODO: fill in defaults
    _roomNameLabel.text = @"";
    [[QueueManager shared] resetQueue];
}

- (void)updateQueueData {
    [_tableView reloadData];
}

# pragma mark - IBActions

- (IBAction)didTapLeaveRoom:(id)sender {
    
    if ([[RoomManager shared] isCurrentUserHost]) {
        [[RoomManager shared] deleteCurrentRoom];
        return;
    }
    
    [[RoomManager shared] leaveCurrentRoom];
    
}

- (IBAction)didTapPlay:(id)sender {
    
    NSString *currentSongId = [[RoomManager shared] currentSongId];
    QueueSong *currentSong = [PFQuery getObjectOfClass:@"QueueSong" objectId:currentSongId];
    
    if (currentSong) {
        NSString *currentSongSpotifyId = currentSong.spotifyId;
        [[SpotifyAPIManager shared] getSongWithSpotifyId:currentSongSpotifyId completion:^(Song *song, NSError *error) {
            if (song) {
                [[SpotifySessionManager shared] playSongWithSpotifyURI:song.spotifyURI];
            }
        }];
    }
}


# pragma mark - Table View

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

# pragma mark - Spotify

- (void)authenticateSpotifySession {
    if (![[SpotifySessionManager shared] isSessionAuthorized]) {
        [[SpotifySessionManager shared] authorizeSession];
    }
}

# pragma mark - Live Query

- (void)configureLiveQueryClient {
    if (!credentialsLoaded) {
        [self loadParseCredentials];
    }
    self.client = [[PFLiveQueryClient alloc] initWithServer:self.server applicationId:self.appId clientKey:self.clientKey];
}

- (void)configureLiveSubscriptions {
    
    // reset subscriptions
    self.subscription = nil;
    
    PFQuery *query = [PFQuery queryWithClassName:@"QueueSong"];
    self.subscription = [self.client subscribeToQuery:query];
    
    // new song added to queue
    self.subscription = [self.subscription addCreateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        [[CurrentRoomManager shared] refreshQueue];
    }];
    
    // queue song is updated
    self.subscription = [self.subscription addUpdateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        [[CurrentRoomManager shared] refreshQueue];
    }];
    
    // TODO: queue song is deleted
}

# pragma mark - Setters

- (void)setQueue:(NSMutableArray<QueueSong *> *)queue {
    _queue = queue;
    [self.tableView reloadData];
}

- (void)setCurrentSong:(QueueSong *)currentSong {
    _currentSong = currentSong;
    [[SpotifyAPIManager shared] getSongWithSpotifyId:currentSong.spotifyId completion:^(Song *song, NSError *error) {
        if (song) {
            self.currentSongTitleLabel.text = song.title;
            self.currentSongArtistLabel.text = song.artist;
            self.currentSongAlbumImageView.image = song.albumImage;
        }
    }];
}

# pragma mark - Helpers

- (void)loadParseCredentials {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSMutableDictionary *credentials = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    self.server = [credentials objectForKey:@"parse-live-server"];
    self.appId = [credentials objectForKey:@"parse-app-id"];
    self.clientKey = [credentials objectForKey:@"parse-client-key"];
    credentialsLoaded = YES;
}

- (PFQuery *)queueSongsQuery {
    PFQuery *query = [PFQuery queryWithClassName:@"QueueSong"];
    [query whereKey:@"roomId" equalTo:[[CurrentRoomManager shared] currentRoomId]]; // TODO: should update room id
    [query orderByAscending:@"score"];
    return query;
}

@end
