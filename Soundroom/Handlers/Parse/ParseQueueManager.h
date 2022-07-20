//
//  ParseQueueManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/19/22.
//

#import <Foundation/Foundation.h>
#import "QueueSong.h"

#define QueueManagerUpdatedQueueNotification @"QueueManagerUpdatedQueueNotification"

NS_ASSUME_NONNULL_BEGIN

@interface ParseQueueManager : NSObject

@property (strong, nonatomic) NSMutableArray <QueueSong *> *queue;

+ (instancetype)shared;

- (void)updateQueueSong:(QueueSong *)song;
- (void)removeQueueSong:(QueueSong *)song;
- (void)insertQueueSong:(QueueSong *)song;

@end

NS_ASSUME_NONNULL_END
