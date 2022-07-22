//
//  SongCell.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <UIKit/UIKit.h>
#import "RoomManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CellType) {
    AddSongCell,
    AddUserCell,
    QueueSongCell
};

@interface SongCell : UITableViewCell

@property (nonatomic) CellType cellType;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *objectId;

@property (nonatomic) VoteState voteState;
@property (strong, nonatomic) NSNumber *score;
@property (strong, nonatomic) NSString *spotifyId;

@end

NS_ASSUME_NONNULL_END
