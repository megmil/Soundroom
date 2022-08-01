//
//  RoomCell.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <UIKit/UIKit.h>
#import "EnumeratedTypes.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RoomCellDelegate
- (void)didTapAcceptInvitationWithId:(NSString *)invitationId;
- (void)didTapRejectInvitationWithId:(NSString *)invitationId;
@end

@interface RoomCell : UITableViewCell

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIImage *image; // TODO: room cover image
@property (strong, nonatomic) NSString *objectId;
@property (nonatomic) RoomCellType cellType;

@property (nonatomic, weak) id<RoomCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
