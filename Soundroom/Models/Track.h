//
//  Track.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Track : NSObject

@property (nonatomic, strong) NSString *upc;
@property (nonatomic, strong) NSString *streamingId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) UIImage *albumImage;

+ (NSArray *)tracksWithJSONResponse:(NSDictionary *)response;
+ (Track *)trackWithJSONResponse:(NSDictionary *)response;

@end

NS_ASSUME_NONNULL_END
