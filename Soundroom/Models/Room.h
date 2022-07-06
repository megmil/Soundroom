//
//  Room.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "QueueSong.h"

NS_ASSUME_NONNULL_BEGIN

@interface Room : NSObject

@property (nonatomic, strong) User *host;
@property (nonatomic, strong) NSMutableArray <User *> *members;
@property (nonatomic, strong) NSMutableArray <QueueSong *> *queue;
@property (nonatomic, strong) NSMutableArray <QueueSong *> *playedSongs;

@property (nonatomic, strong) NSString *title;
// room image

@end

NS_ASSUME_NONNULL_END
