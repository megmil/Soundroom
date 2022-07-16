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

@interface RoomViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) NSMutableArray <QueueSong *> *queue;

@end

@implementation RoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[SongCell class] forCellReuseIdentifier:@"QueueSongCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRoom) name:ParseRoomManagerJoinedRoomNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRoom) name:ParseRoomManagerUpdatedQueueNotification object:nil];
}

- (void)loadRoom {
    self.titleLabel.text = [[ParseRoomManager shared] currentRoomTitle];
    [QueueSong getCurrentQueueSongs]; // get songs added to queue while live query was off
    [self.tableView reloadData];
}

- (void)refreshRoom {
    self.queue = [[ParseRoomManager shared] queue];
    [self.tableView reloadData];
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
        return [currentUserId isEqual:hostId];
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


@end
