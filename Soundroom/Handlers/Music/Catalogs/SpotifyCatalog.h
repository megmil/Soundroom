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

@property (nonatomic, strong, readonly) NSString *baseURLString;
@property (nonatomic, strong, readonly) NSString *searchURLString;
@property (nonatomic, strong, readonly) NSString *getTrackURLString;
@property (nonatomic, strong, readonly) NSString *tokenParameterName;
@property (nonatomic, strong, readonly) NSString *typeParameterName;
@property (nonatomic, strong, readonly) NSString *queryParameterName;
@property (nonatomic, strong, readonly) NSString *trackTypeName;

@end

NS_ASSUME_NONNULL_END
