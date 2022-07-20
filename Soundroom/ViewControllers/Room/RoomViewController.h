//
//  RoomViewController.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoomViewController : UIViewController {
    BOOL didLoadCredentials; // TODO: rename
}

@property (strong, nonatomic) NSString *server;
@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSString *clientKey;

@end

NS_ASSUME_NONNULL_END
