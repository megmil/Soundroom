//
//  SpotifyAPIManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/6/22.
//

#import "BDBOAuth1SessionManager.h"

@interface SpotifyAPIManager : BDBOAuth1SessionManager

+ (instancetype)shared;

- (void)getSongsWithText:(NSString *)text forFilter:(NSString *)filter completion:(void(^)(NSArray *songs, NSError *error))completion;

@end
