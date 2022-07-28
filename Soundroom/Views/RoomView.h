//
//  RoomView.h
//  Soundroom
//
//  Created by Megan Miller on 7/28/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoomView : UIView

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSString *roomName;
@property (strong, nonatomic) NSString *currentSongTitle;
@property (strong, nonatomic) NSString *currentSongArtist;
@property (strong, nonatomic) UIImage *currentSongAlbumImage;
@property (nonatomic) BOOL isHostView;

@end

NS_ASSUME_NONNULL_END
