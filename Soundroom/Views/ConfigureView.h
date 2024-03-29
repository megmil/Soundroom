//
//  ConfigureView.h
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import <UIKit/UIKit.h>
#import "EnumeratedTypes.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ConfigureViewDelegate
- (void)didTapCreate;
@end

@interface ConfigureView : UIView

@property (nonatomic) BOOL enabled;
@property (strong, nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) RoomListeningMode listeningMode;
@property (nonatomic, weak) id<ConfigureViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
