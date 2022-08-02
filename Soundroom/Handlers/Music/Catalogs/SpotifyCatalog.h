//
//  SpotifyCatalog.h
//  Soundroom
//
//  Created by Megan Miller on 8/1/22.
//

#import <Foundation/Foundation.h>
#import "MusicAPIManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface SpotifyCatalog : NSObject <MusicCatalog>

- (NSString *)baseURLString;
- (NSString *)accessToken;
- (NSString *)searchURLString;
- (NSString *)getTrackURLString;
- (NSString *)tokenParameterName;
- (NSString *)typeParameterName;
- (NSString *)queryParameterName;
- (NSString *)trackTypeName;

@end

NS_ASSUME_NONNULL_END
