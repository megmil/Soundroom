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
#import "SearchCell.h"

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
    [self.tableView registerClass:[SearchCell class] forCellReuseIdentifier:@"QueueSongCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViews) name:ParseRoomManagerJoinedRoomNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViews) name:ParseRoomManagerUpdatedQueueNotification object:nil];
}

- (void)refreshViews {
    [QueueSong getCurrentQueueSongs];
    [self refreshQueueSongs];
    self.titleLabel.text = [[ParseRoomManager shared] currentRoomTitle];
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

# pragma mark - Queue

- (void)refreshQueueSongs {
    self.queue = [[ParseRoomManager shared] queue];
    [self.tableView reloadData];
}

# pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.queue.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QueueSongCell"];
    QueueSong *queueSong = self.queue[indexPath.row];
    
    [[SpotifyAPIManager shared] getSongWithSpotifyId:queueSong.spotifyId completion:^(Song *song, NSError *error) {
        if (song) {
            cell.title = song.title;
            cell.subtitle = song.artist;
            cell.image = song.albumImage;
            cell.objectId = song.spotifyId;
            cell.isAddSongCell = NO;
            cell.isUserCell = NO;
            cell.isQueueSongCell = YES;
        } else {
            NSLog(@"og: %@", error);
        }
    }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.f;
}


@end
