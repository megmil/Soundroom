//
//  Room.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "EnumeratedTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface Room : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *hostId;
@property (nonatomic, strong) NSString *currentSongISRC;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) NSUInteger listeningMode;

- (instancetype)initWithTitle:(NSString *)title hostId:(NSString *)hostId listeningMode:(RoomListeningMode)listeningMode;

@end

NS_ASSUME_NONNULL_END
