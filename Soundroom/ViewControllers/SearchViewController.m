//
//  SearchViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "SearchViewController.h"
#import "Song.h"
#import "QueueSong.h"
#import "UIImageView+AFNetworking.h"
#import "SpotifyAPIManager.h"
#import "SongCell.h"

@interface SearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray<Song *> *songs;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[SongCell class] forCellReuseIdentifier:@"SearchCell"];
    
    self.searchBar.delegate = self;
}

#pragma mark - Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Song *song = self.songs[indexPath.row];
    
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    [cell setTitle:song.title];
    [cell setArtist:song.artist];
    [cell setAlbumImage:song.albumImage];
    [cell setSpotifyId:song.spotifyId];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72.f;
}

#pragma mark - Search Bar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length == 0) {
        return;
    }
    
    // TODO: search every X keypresses
    [[SpotifyAPIManager shared] getSongsWithQuery:searchText completion:^(NSArray *songs, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            self.songs = (NSMutableArray<Song *> *)songs;
            [self.tableView reloadData];
        }
    }];
}

@end
