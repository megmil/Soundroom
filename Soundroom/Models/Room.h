//
//  Room.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface Room : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSMutableArray <NSString *> *memberIds;
@property (nonatomic, strong) NSMutableArray *queue;
//@property (nonatomic, strong) NSMutableArray *playedSongs;
@property (nonatomic, strong) NSString *title;
//@property (nonatomic, strong) PFFileObject *coverImageData;

@end

NS_ASSUME_NONNULL_END
