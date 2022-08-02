//
//  AppleMusicSessionManager.h
//  Soundroom
//
//  Created by Megan Miller on 8/1/22.
//

#import <Foundation/Foundation.h>
#import "MusicPlayerManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppleMusicSessionManager : NSObject <MusicPlayer>

@property (strong, nonatomic, readonly) NSString *accessToken;

@end

NS_ASSUME_NONNULL_END
