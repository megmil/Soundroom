//
//  MusicAPIManager.h
//  Soundroom
//
//  Created by Megan Miller on 8/1/22.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "EnumeratedTypes.h"

NS_ASSUME_NONNULL_BEGIN

@class Track;
@class Request;

@protocol MusicAPIManager <NSObject>

- (NSString *)searchURLString;
- (NSString *)lookupURLStringWithISRC:(NSString *)isrc;
- (NSDictionary *)searchParametersWithToken:(NSString *)token query:(NSString *)query;
- (NSDictionary *)lookupParametersWithToken:(NSString *)token isrc:(NSString *)isrc;
- (NSArray <Track *> *)tracksWithJSONResponse:(NSDictionary *)response;
- (Track *)trackWithJSONResponse:(NSDictionary *)response;

@end

@interface MusicCatalogManager : NSObject

@property (weak, nonatomic) AFHTTPSessionManager<MusicAPIManager> *musicCatalog;

+ (instancetype)shared;
- (void)getTracksWithQuery:(NSString *)query completion:(void(^)(NSArray *tracks, NSError *error))completion;
- (void)getTrackWithISRC:(NSString *)isrc completion:(void(^)(Track *track, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
