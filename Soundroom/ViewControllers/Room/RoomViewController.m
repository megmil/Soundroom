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
#import "ParseQueryManager.h"
#import "ParseObjectManager.h"
#import "RoomManager.h"
#import "QueueSong.h"
#import "Song.h"
#import "Vote.h"
#import "SongCell.h"
#import "SongTableView.h"
@import ParseLiveQuery;

@interface RoomViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentSongTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentSongArtistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *currentSongAlbumImageView;
@property (weak, nonatomic) IBOutlet SongTableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) PFLiveQueryClient *client;
@property (strong, nonatomic) PFLiveQuerySubscription *songSubscription;
@property (strong, nonatomic) PFLiveQuerySubscription *voteSubscription;

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
    _tableView.rowHeight = 66.f;
    [_tableView registerClass:[SongCell class] forCellReuseIdentifier:@"QueueSongCell"];
}

- (void)configureObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRoomViews) name:RoomManagerJoinedRoomNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearRoomViews) name:RoomManagerLeftRoomNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateQueueViews) name:RoomManagerUpdatedQueueNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentSongViews) name:RoomManagerUpdatedCurrentSongNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateQueueViews) name:SpotifySessionManagerAuthorizedNotificaton object:nil];
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

- (void)loadRoomViews {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self->_roomNameLabel.text = [[RoomManager shared] currentRoomName];
    });
    [self configureSongSubcription];
    [self configureVoteSubscription];
}

- (void)clearRoomViews {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self->_roomNameLabel.text = @"";
    });
}

- (void)updateQueueViews {
    [self updateCurrentSongViews];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self->_tableView reloadData];
    });
}

- (void)updateCurrentSongViews {
    
    NSString *currentSongId = [[RoomManager shared] currentSongId];
    
    [[SpotifyAPIManager shared] getSpotifySongForQueueSongWithId:currentSongId completion:^(Song *song, NSError *error) {
        
        if (song) {
            
            // update views
            self->_currentSongTitleLabel.text = song.title;
            self->_currentSongArtistLabel.text = song.artist;
            self->_currentSongAlbumImageView.image = song.albumImage;
            
        }
        
    }];
}

# pragma mark - IBActions

- (IBAction)didTapPlay:(id)sender {
    [[RoomManager shared] playTopSong];
}

- (IBAction)didTapLeaveRoom:(id)sender {
    [ParseObjectManager deleteInvitationsAcceptedByCurrentUser];
}

# pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[RoomManager shared] queue].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QueueSongCell"];
    QueueSong *queueSong = [[RoomManager shared] queue][indexPath.row];
    
    cell.objectId = queueSong.objectId;
    cell.spotifyId = queueSong.spotifyId;
    cell.cellType = QueueSongCell;
    cell.score = [[RoomManager shared] scores][indexPath.row];
    
    // get vote status
    cell.voteState = NotVoted;
    [[RoomManager shared] getVoteStateForSongWithId:queueSong.objectId completion:^(VoteState voteState) {
        cell.voteState = voteState;
    }];
    
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
        QueueSong *song = [[RoomManager shared] queue][indexPath.row];
        [ParseObjectManager deleteQueueSong:song];
    }
    
}

# pragma mark - Subscriptions

- (void)configureSongSubcription {
    
    // reset subscriptions
    _songSubscription = nil;
    
    // check for valid roomId
    NSString *roomId = [[RoomManager shared] currentRoomId];
    if (!roomId) {
        return;
    }
    
    PFQuery *query = [ParseQueryManager queryForSongsInCurrentRoom];
    _songSubscription = [_client subscribeToQuery:query];
    
    // new song request is created
    _songSubscription = [_songSubscription addCreateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        QueueSong *song = (QueueSong *)object;
        [[RoomManager shared] insertQueueSong:song];
    }];
    
    // song request is removed
    _songSubscription = [_songSubscription addDeleteHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        QueueSong *song = (QueueSong *)object;
        [[RoomManager shared] removeQueueSong:song];
    }];
    
}

- (void)configureVoteSubscription {
    
    // reset subscriptions
    _voteSubscription = nil;
    
    // check for valid roomId
    NSString *roomId = [[RoomManager shared] currentRoomId];
    if (!roomId) {
        return;
    }
    
    PFQuery *query = [ParseQueryManager queryForVotesInCurrentRoom];
    _voteSubscription = [_client subscribeToQuery:query];
    
    // vote is created
    _voteSubscription = [_voteSubscription addCreateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Vote *vote = (Vote *)object;
        [[RoomManager shared] updateQueueSongWithId:vote.songId];
    }];
    
    // vote is updated
    _voteSubscription = [_voteSubscription addUpdateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Vote *vote = (Vote *)object;
        [[RoomManager shared] updateQueueSongWithId:vote.songId];
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

@end
