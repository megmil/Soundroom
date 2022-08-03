//
//  SongCell.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <UIKit/UIKit.h>
#import "EnumeratedTypes.h"

NS_ASSUME_NONNULL_BEGIN

@protocol QueueCellDelegate
- (void)didUpdateVoteStateForRequestWithId:(NSString *)requestId voteState:(VoteState)voteState;
@end

@protocol AddCellDelegate
- (void)didAddObjectWithId:(NSString *)objectId deezerId:(NSString *)deezerId;
@end

@interface SongCell : UITableViewCell

@property (nonatomic) SongCellType cellType;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSString *objectId;

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *deezerId;

@property (nonatomic) VoteState voteState;
@property (strong, nonatomic) NSNumber *score;

@property (nonatomic, weak) id<QueueCellDelegate> queueDelegate;
@property (nonatomic, weak) id<AddCellDelegate> addDelegate;

@end

NS_ASSUME_NONNULL_END
