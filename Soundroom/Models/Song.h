//
//  Song.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Song : NSObject

// TODO: add prefix to class names
@property (nonatomic, strong) NSString *idString;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *albumTitle;
@property (nonatomic, strong) UIImage *albumImage;
@property (nonatomic, strong) NSString *durationString;

+ (NSMutableArray *)songsWithJSONResponse:(NSDictionary *)response;

- (void)addToQueueWithCompletion:(PFBooleanResultBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
