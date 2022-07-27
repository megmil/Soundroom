//
//  AccountView.h
//  Soundroom
//
//  Created by Megan Miller on 7/14/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AccountViewDelegate
- (void)didTapSpotifyLogin;
- (void)didTapSpotifyLogout;
- (void)didTapUserLogout;
@end

@interface AccountView : UIView

@property (nonatomic) BOOL isUserAccountView;
@property (nonatomic) BOOL isLoggedIn;

@property (nonatomic, weak) id<AccountViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
