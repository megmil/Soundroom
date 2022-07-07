//
//  Song.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Song : NSObject

@property (nonatomic, strong) NSString *idString;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *albumTitle;
@property (nonatomic, strong) NSData *albumImageData;
@property (nonatomic, strong) NSString *durationString;

+ (NSMutableArray *)songsWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
