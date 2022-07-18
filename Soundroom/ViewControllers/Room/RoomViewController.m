//
//  RoomViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "RoomViewController.h"
#import "LobbyViewController.h"
#import "SpotifyAPIManager.h"
#import "ParseRoomManager.h"
#import "ParseUserManager.h"
#import "QueueSong.h"
#import "Song.h"
#import "SongCell.h"
@import ParseLiveQuery;

@interface RoomViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) NSMutableArray <QueueSong *> *queue;

@property (strong, nonatomic) PFLiveQueryClient *client;
@property (strong, nonatomic) PFLiveQuerySubscription *subscription;

@end

@implementation RoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[SongCell class] forCellReuseIdentifier:@"QueueSongCell"];
    
    [self configureClient];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRoom) name:ParseRoomManagerJoinedRoomNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRoom) name:ParseRoomManagerUpdatedQueueNotification object:nil];
}

- (void)loadRoom {
    self.titleLabel.text = [[ParseRoomManager shared] currentRoomTitle];
    [self configureLiveSubscriptions];
    [QueueSong getCurrentQueueSongs]; // get songs added to queue while live query was off
    [self.tableView reloadData];
}

- (void)refreshRoom {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self configureLiveSubscriptions];
        self.queue = [[ParseRoomManager shared] queue];
        [self.tableView reloadData];
    });
}

- (IBAction)leaveRoom:(id)sender {
    if ([self isCurrentUserHost]) {
        [[ParseRoomManager shared] removeAllUsersWithCompletion:nil];
        return;
    }
    [[ParseRoomManager shared] removeUserWithId:[ParseUserManager currentUserId] completion:nil];
}

- (BOOL)isCurrentUserHost {
    NSString *currentUserId = [ParseUserManager currentUserId];
    NSString *hostId = [[ParseRoomManager shared] currentHostId];
    if (currentUserId && hostId) {
        return [currentUserId isEqualToString:hostId];
    }
    return NO;
}

# pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.queue.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QueueSongCell"];
    QueueSong *queueSong = self.queue[indexPath.row];
    
    cell.objectId = queueSong.objectId;
    cell.score = queueSong.score;
    
    cell.isQueueSongCell = YES;
    cell.isAddSongCell = NO;
    cell.isUserCell = NO;
    
    cell.isUpvoted = [queueSong isUpvotedByCurrentUser];
    cell.isDownvoted = [queueSong isDownvotedByCurrentUser];
    cell.isNotVoted = [queueSong isNotVotedByCurrentUser];
    
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

# pragma mark - Live Query

- (void)configureClient {
    
    if (!credentialsLoaded) {
        [self loadCredentials];
    }
    
    self.client = [[PFLiveQueryClient alloc] initWithServer:self.server applicationId:self.appId clientKey:self.clientKey];
    
}

- (void)configureLiveSubscriptions {
    
    // reset subscriptions
    self.subscription = nil;
    
    PFQuery *query = [PFQuery queryWithClassName:@"QueueSong"];
    self.subscription = [self.client subscribeToQuery:query];
    
    // new song added to queue
    [self.subscription addCreateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        QueueSong *song = (QueueSong *)object;
        [[ParseRoomManager shared] updateQueueWithSong:song];
    }];
    
    // queue song is updated
    [self.subscription addUpdateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        QueueSong *song = (QueueSong *)object;
        [[ParseRoomManager shared] updateScoreForQueueSong:song];
    }];
    
    // queue song is deleted
    /*
    [self.subscription addDeleteHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        QueueSong *song = (QueueSong *)object;
    }];
     */
}

- (void)loadCredentials {
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
    return query;
}

@end
