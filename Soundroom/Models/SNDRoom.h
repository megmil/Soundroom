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

@interface SNDRoom : RLMObject

@property (nonatomic, strong) NSString *roomID;
@property (nonatomic, strong) NSString *partition;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *coverImageURLString;
@property (nonatomic, strong) NSMutableArray <SNDUser *> *members;
@property (nonatomic, strong) NSMutableArray <QueueSong *> *queue;

@end

NS_ASSUME_NONNULL_END
