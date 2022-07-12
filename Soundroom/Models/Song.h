//
//  Song.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface Song : RLMEmbeddedObject

// TODO: add prefix to class names

@property (nonatomic, strong) NSString *idString;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *albumTitle;
@property (nonatomic, strong) NSData *albumImageData; // TODO: convert to UIImage?
@property (nonatomic, strong) NSString *durationString;

+ (NSMutableArray *)songsWithJSONResponse:(NSDictionary *)response;

- (void)addToQueue;

@end

NS_ASSUME_NONNULL_END
