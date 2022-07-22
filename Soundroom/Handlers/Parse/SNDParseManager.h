//
//  QueryManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/20/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface SNDParseManager : NSObject

+ (void)deleteAllObjects:(NSArray *)objects;

@end

NS_ASSUME_NONNULL_END
