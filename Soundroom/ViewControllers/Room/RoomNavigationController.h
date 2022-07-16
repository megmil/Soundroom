//
//  RoomNavigationController.h
//  Soundroom
//
//  Created by Megan Miller on 7/14/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoomNavigationController : UINavigationController {
    BOOL credentialsLoaded;
}

@property (strong, nonatomic) NSString *server;
@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSString *clientKey;

@end

NS_ASSUME_NONNULL_END
