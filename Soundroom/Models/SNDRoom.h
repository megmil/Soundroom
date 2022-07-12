//
//  Room.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <Foundation/Foundation.h>
#import "SNDUser.h"
#import "QueueSong.h"
#import "Realm/Realm.h"

NS_ASSUME_NONNULL_BEGIN

@interface SNDRoom : RLMObject

@property (nonatomic, strong) RLMObjectId *_id;
@property (nonatomic, strong) NSString *partition;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *coverImageURLString;
//@property (nonatomic, strong) RLMArray <QueueSong *> *queue;

+ (void)createRoomWithTitle:(NSString *)title;

- (RLMObjectId *)roomID;

@end

NS_ASSUME_NONNULL_END
