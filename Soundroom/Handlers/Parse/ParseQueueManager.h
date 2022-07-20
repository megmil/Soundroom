//
//  ParseQueueManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/19/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParseQueueManager : NSObject

+ (NSNumber *)scoreForSongWithId:(NSString *)songId;

@end

NS_ASSUME_NONNULL_END
