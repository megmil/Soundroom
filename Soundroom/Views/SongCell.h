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
@property (strong, nonatomic) NSString *artist;
@property (strong, nonatomic) UIImage *albumImage;
@property (strong, nonatomic) NSString *spotifyId;

@end

NS_ASSUME_NONNULL_END
