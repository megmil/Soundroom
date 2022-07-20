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
#import "ParseRoomManager.h"
#import "ParseQueueManager.h"
#import "QueueSong.h"
#import "Song.h"
#import "SongCell.h"
@import ParseLiveQuery;

@interface RoomViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *roomTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentSongTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentSongArtistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *currentSongAlbumImageView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) NSMutableArray <QueueSong *> *queue;
@property (strong, nonatomic) QueueSong *currentSong;

@property (strong, nonatomic) PFLiveQueryClient *client;
@property (strong, nonatomic) PFLiveQuerySubscription *subscription;

@end

@implementation RoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView];
    [self configureLiveQueryClient];
    [self authenticateSpotifySession];
    [self configureNotificationObservers];
}

# pragma mark - Queue

- (void)refreshQueue {
    self.queue = [[ParseQueueManager shared] queue];
}

- (void)startPlayingQueue {
    if (self.queue.count) {
        
        // get first song in queue
        self.currentSong = self.queue.firstObject;
        
        // TODO: delete QueueSong from database
        
    }
}

- (void)getQueue {
    NSMutableArray <QueueSong *> *fullQueue = [[ParseRoomManager shared] queue];
    if (fullQueue.count) {
        self.currentSong = fullQueue.firstObject;
        if (fullQueue.count > 1) {
            [fullQueue removeObjectAtIndex:0];
            self.queue = fullQueue;
        }
    }
}

# pragma mark - Room Status

- (void)loadRoom {
    self.roomTitleLabel.text = [[ParseRoomManager shared] currentRoomTitle];
    [self configureLiveSubscriptions];
    [[ParseRoomManager shared] refreshQueue];
}

- (void)refreshRoom {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self configureLiveSubscriptions];
        [self refreshQueue];
    });
}

- (IBAction)leaveRoom:(id)sender {
    if ([self isCurrentUserHost]) {
        [[ParseRoomManager shared] removeAllUsers];
        return;
    }
    [[ParseRoomManager shared] removeUserWithId:[ParseUserManager currentUserId]];
}


# pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.queue.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QueueSongCell"];
    QueueSong *queueSong = self.queue[indexPath.row];
    
    cell.objectId = queueSong.objectId;
    cell.score = [Vote scoreForSongWithId:queueSong.objectId];
    cell.cellType = QueueSongCell;
    cell.voteState = [Vote voteStateForSongWithId:queueSong.objectId];
    
    [[SpotifyAPIManager shared] getSongWithSpotifyId:queueSong.spotifyId completion:^(Song *song, NSError *error) {
        if (song) {
            cell.title = song.title;
            cell.subtitle = song.artist;
            cell.image = song.albumImage;
            cell.spotifyId = song.spotifyId;
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

- (IBAction)didTapPlay:(id)sender {
    self.currentSong = self.queue.firstObject;
    [[SpotifyAPIManager shared] getSongWithSpotifyId:self.currentSong.spotifyId completion:^(Song *song, NSError *error) {
        if (song) {
            [[SpotifySessionManager shared] playSongWithSpotifyURI:song.spotifyURI];
        }
    }];
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
        [[ParseRoomManager shared] refreshQueue];
    }];
    
    // queue song is updated
    self.subscription = [self.subscription addUpdateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        [[ParseRoomManager shared] refreshQueue];
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

- (void)configureTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[SongCell class] forCellReuseIdentifier:@"QueueSongCell"];
}

- (void)configureNotificationObservers {
    
    // Parse notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRoom) name:ParseRoomManagerJoinedRoomNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshQueue) name:ParseRoomManagerUpdatedQueueNotification object:nil];
    
    // Spotify notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRoom) name:SpotifySessionManagerAuthorizedNotificaton object:nil];
    
}

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
    [query whereKey:@"roomId" equalTo:[[ParseRoomManager shared] currentRoomId]]; // TODO: should update room id
    [query orderByAscending:@"score"];
    return query;
}

- (BOOL)isCurrentUserHost {
    NSString *currentUserId = [ParseUserManager currentUserId];
    NSString *hostId = [[ParseRoomManager shared] currentHostId];
    if (currentUserId && hostId) {
        return [currentUserId isEqualToString:hostId];
    }
    return NO;
}

@end
