//
//  SongCell.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchCell : UITableViewCell

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *spotifyId;
@property (nonatomic) BOOL isAddSongCell;
@property (nonatomic) BOOL isUserCell;
@property (nonatomic) BOOL isQueueSongCell;

@property (nonatomic) BOOL isUpvoted;
@property (nonatomic) BOOL isDownvoted;
@property (nonatomic) BOOL isUnvoted;

@end

NS_ASSUME_NONNULL_END
