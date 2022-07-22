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
#import "InvitationManager.h"
#import "VoteManager.h"
#import "QueueSong.h"
#import "Song.h"
#import "Vote.h"
#import "SongCell.h"
#import "QueryManager.h"
@import ParseLiveQuery;

@interface RoomViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentSongTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentSongArtistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *currentSongAlbumImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) PFLiveQueryClient *client;
@property (strong, nonatomic) PFLiveQuerySubscription *invitationSubscription;
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
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self->_roomNameLabel.text = [[RoomManager shared] currentRoomName];
    });
    [[QueueManager shared] fetchQueue];
    [self configureInvitationSubscription];
    [self configureVoteSubscription];
}

- (void)clearRoomData {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self->_roomNameLabel.text = @"";
    });
    [[QueueManager shared] resetLocalQueue];
    [[VoteManager shared] resetLocalVotes];
}

- (void)updateQueueData {
    [self updateCurrentSongData];
    [[VoteManager shared] resetLocalVotes];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self->_tableView reloadData];
    });
}

- (void)updateCurrentSongData {
    
    NSString *currentSongId = [[RoomManager shared] currentSongId];
    [QueueManager getSpotifyIdForSongWithId:currentSongId completion:^(NSString *spotifyId, NSError *error) {
        [[SpotifyAPIManager shared] getSongWithSpotifyId:spotifyId completion:^(Song *song, NSError *error) { // TODO: get song with QueueSong?
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
    }];
}

# pragma mark - IBActions

- (IBAction)didTapPlay:(id)sender {
    [[QueueManager shared] playTopSong];
}

- (IBAction)didTapLeaveRoom:(id)sender {
    [QueryManager deleteInvitationsAcceptedByCurrentUser];
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
    cell.score = [[QueueManager shared] scores][indexPath.row];
    
    // get vote status
    cell.voteState = NotVoted;
    [[VoteManager shared] getVoteStateForSongWithId:queueSong.objectId completion:^(VoteState voteState) {
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.f;
}

# pragma mark - Subscriptions

- (void)configureInvitationSubscription {
    
    // reset subscriptions
    _invitationSubscription = nil;
    
    // check for valid roomId
    NSString *roomId = [[RoomManager shared] currentRoomId];
    if (!roomId) {
        return;
    }
    
    PFQuery *query = [QueryManager queryForSongsInCurrentRoom];
    _invitationSubscription = [_client subscribeToQuery:query];
    
    // new song request is created
    _invitationSubscription = [_invitationSubscription addCreateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        QueueSong *song = (QueueSong *)object;
        [[QueueManager shared] insertQueueSong:song];
    }];
    
    // song request is removed
    _invitationSubscription = [_invitationSubscription addDeleteHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        QueueSong *song = (QueueSong *)object;
        [[QueueManager shared] removeQueueSong:song];
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
    
    PFQuery *query = [QueryManager queryForVotesInCurrentRoom];
    _voteSubscription = [_client subscribeToQuery:query];
    
    // vote is created
    _voteSubscription = [_voteSubscription addCreateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Vote *vote = (Vote *)object;
        [[QueueManager shared] updateQueueSongWithId:vote.songId];
    }];
    
    // vote is updated
    _voteSubscription = [_voteSubscription addUpdateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Vote *vote = (Vote *)object;
        [[QueueManager shared] updateQueueSongWithId:vote.songId];
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
