//
//  RoomViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "RoomViewController.h"
#import "QueueSong.h"
#import "SongCell.h"

@interface RoomViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<QueueSong *> *queue;

@end

@implementation RoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)getQueue {
    RLMRealmConfiguration *configuration = [RLMRealmConfiguration alloc];
}

#pragma mark - Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.queue.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QueueSong *queueSong = self.queue[indexPath.row];
    
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QueueSongCell"];
    cell.titleLabel.text = queueSong.song.title;
    cell.artistLabel.text = queueSong.song.artist;
    cell.albumImageView.image = [UIImage imageWithData:queueSong.song.albumImageData];
    
    return cell;
}

@end
