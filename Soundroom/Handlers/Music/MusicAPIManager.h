//
//  MusicAPIManager.h
//  Soundroom
//
//  Created by Megan Miller on 8/1/22.
//

#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const MusicAPIManagerFailedAccessTokenNotification;

@class Track;

@protocol MusicCatalog

- (NSString *)baseURLString;
- (NSString *)accessToken;
- (NSString *)searchURLString;
- (NSString *)getTrackURLString;
- (NSString *)tokenParameterName;
- (NSString *)typeParameterName;
- (NSString *)queryParameterName;
- (NSString *)trackTypeName;

@end

@interface MusicAPIManager : AFHTTPSessionManager

@property (nonatomic, weak) id<MusicCatalog> musicCatalog;

+ (instancetype)shared;
- (void)getTracksWithQuery:(NSString *)query completion:(void(^)(NSArray *tracks, NSError *error))completion;
- (void)getTrackWithStreamingId:(NSString *)streamingId completion:(void(^)(Track *track, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
