//
//  ConfigureView.h
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ConfigureViewDelegate

- (void)didCreateRoom;

@end

@interface ConfigureView : UIView

@property (strong, nonatomic) NSString *title;
@property (nonatomic, weak) id<ConfigureViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
