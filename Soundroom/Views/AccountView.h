//
//  AccountView.h
//  Soundroom
//
//  Created by Megan Miller on 7/14/22.
//

#import <UIKit/UIKit.h>
#import "EnumeratedTypes.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AccountViewDelegate

- (void)didTapMusicPlayerLogin;
- (void)didTapMusicPlayerLogout;
- (void)didTapUserLogout;

@end

@interface AccountView : UIView

@property (nonatomic) AccountType accountType;
@property (nonatomic, weak) id<AccountViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
