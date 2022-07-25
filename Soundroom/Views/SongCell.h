//
//  SongCell.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <UIKit/UIKit.h>
#import "RoomManager.h" // TODO: need for VoteState, move?

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SongCellType) {
    TrackCell,
    UserCell,
    QueueCell
};

@interface SongCell : UITableViewCell

@property (nonatomic) SongCellType cellType;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *objectId;

@property (nonatomic) VoteState voteState;
@property (strong, nonatomic) NSNumber *score;

@end

NS_ASSUME_NONNULL_END
