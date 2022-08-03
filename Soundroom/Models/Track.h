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

@property (nonatomic, strong) NSString *isrc;
@property (nonatomic, strong) NSString *deezerId;
@property (nonatomic, strong) NSString *streamingId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSURL *albumImageURL;

- (instancetype)initWithISRC:(NSString *)isrc streamingId:(NSString *)streamingId title:(NSString *)title artist:(NSString *)artist albumImageURL:(NSURL *)albumImageURL;
- (instancetype)initWithTitle:(NSString *)title artist:(NSString *)artist albumImageURL:(NSURL *)albumImageURL;

@end

NS_ASSUME_NONNULL_END
