//
//  MusicAPIManager.h
//  Soundroom
//
//  Created by Megan Miller on 8/1/22.
//

#import <AFNetworking/AFNetworking.h>
#import "EnumeratedTypes.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const MusicAPIManagerFailedAccessTokenNotification;

@class Track;
@class Request;

@protocol MusicCatalog

@property (nonatomic, strong, readonly) NSString *baseURLString;
@property (nonatomic, strong, readonly) NSString *searchURLString;
@property (nonatomic, strong, readonly) NSString *tokenParameterName;
@property (nonatomic, strong, readonly) NSString *typeParameterName;
@property (nonatomic, strong, readonly) NSString *queryParameterName;
@property (nonatomic, strong, readonly) NSString *trackTypeName;
- (NSString *)lookupTrackURLStringWithUPC:(NSString *)upc;

@end

@interface MusicAPIManager : AFHTTPSessionManager

@property (nonatomic, weak) id<MusicCatalog> musicCatalog;

+ (instancetype)shared;
- (void)getTracksWithQuery:(NSString *)query completion:(void(^)(NSArray *tracks, NSError *error))completion;
- (void)getTrackWithUPC:(NSString *)upc completion:(void(^)(Track *track, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
