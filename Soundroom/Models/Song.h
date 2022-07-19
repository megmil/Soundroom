//
//  Song.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface Song : NSObject

@property (nonatomic, strong) NSString *spotifyId;
@property (nonatomic, strong) NSString *spotifyURI;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *albumTitle;
@property (nonatomic, strong) UIImage *albumImage;
@property (nonatomic, strong) NSString *durationString;

+ (NSMutableArray *)songsWithJSONResponse:(NSDictionary *)response;
+ (Song *)songWithJSONResponse:(NSDictionary *)response;

@end

NS_ASSUME_NONNULL_END
