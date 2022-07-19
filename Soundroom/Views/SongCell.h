//
//  SongCell.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SongCell : UITableViewCell

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *objectId;

@property (nonatomic) BOOL isAddSongCell;
@property (nonatomic) BOOL isUserCell;
@property (nonatomic) BOOL isQueueSongCell;

@property (strong, nonatomic) NSNumber *score;
@property (nonatomic) BOOL isUpvoted;
@property (nonatomic) BOOL isDownvoted;
@property (nonatomic) BOOL isNotVoted;

@property (strong, nonatomic) NSString *spotifyId;
@property (strong, nonatomic) NSString *spotifyURI;

@end

NS_ASSUME_NONNULL_END
