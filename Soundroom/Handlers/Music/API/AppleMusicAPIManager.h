//
//  AppleMusicAPIManager.h
//  Soundroom
//
//  Created by Megan Miller on 8/2/22.
//

#import <AFNetworking/AFNetworking.h>
#import "MusicCatalogManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppleMusicAPIManager : AFHTTPSessionManager <MusicCatalogManager>

+ (instancetype)shared;

@end

NS_ASSUME_NONNULL_END
