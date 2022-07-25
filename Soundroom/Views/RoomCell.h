//
//  RoomCell.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RoomCellType) {
    InvitationCell,
    HistoryCell
};

@interface RoomCell : UITableViewCell

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIImage *image; // TODO: room cover image
@property (strong, nonatomic) NSString *objectId;
@property (nonatomic) RoomCellType cellType;

@end

NS_ASSUME_NONNULL_END
