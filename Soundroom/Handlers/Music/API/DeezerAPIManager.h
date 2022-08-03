//
//  DeezerAPIManager.h
//  Soundroom
//
//  Created by Megan Miller on 8/2/22.
//

#import <AFNetworking/AFNetworking.h>
#import "MusicCatalogManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeezerAPIManager : AFHTTPSessionManager <MusicAPIManager>

+ (instancetype)shared;
- (void)getISRCWithDeezerId:(NSString *)deezerId completion:(void (^)(NSString *))completion;

@end

NS_ASSUME_NONNULL_END
