//
//  SearchViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "SearchViewController.h"
#import "Song.h"
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
    self.searchBar.delegate = self;
}

#pragma mark Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Song *song = self.songs[indexPath.row];
    
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    cell.titleLabel.text = song.title;
    cell.artistLabel.text = song.artist;
    cell.albumImageView.image = [UIImage imageWithData:song.albumImageData];
    
    cell.addButton.tag = indexPath.row;
    [cell.addButton addTarget:nil action:@selector(didTapAddButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)didTapAddButton:(UIButton *)addButton {
    Song *song = self.songs[addButton.tag];
}

#pragma mark Search Bar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        return;
    }
    
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
