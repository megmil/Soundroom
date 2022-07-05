//
//  Room.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Song.h"

NS_ASSUME_NONNULL_BEGIN

@interface Room : NSObject

@property (nonatomic, strong) User *host;
@property (nonatomic, strong) NSMutableArray <User *> *members;

@property (nonatomic, strong) Song *currentSong;
@property (nonatomic, strong) NSMutableArray <Song *> *queue;

@property (nonatomic, strong) NSString *title;
// room image

@end

NS_ASSUME_NONNULL_END
