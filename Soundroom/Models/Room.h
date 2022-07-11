//
//  Room.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <Foundation/Foundation.h>
#import "SNDUser.h"
#import "QueueSong.h"

NS_ASSUME_NONNULL_BEGIN

@interface Room : NSObject

@property (nonatomic, strong) SNDUser *host;
@property (nonatomic, strong) NSMutableArray <SNDUser *> *members;
@property (nonatomic, strong) NSMutableArray <QueueSong *> *queue;
@property (nonatomic, strong) NSMutableArray <QueueSong *> *playedSongs;

@property (nonatomic, strong) NSString *title;
// room image

@end

NS_ASSUME_NONNULL_END
