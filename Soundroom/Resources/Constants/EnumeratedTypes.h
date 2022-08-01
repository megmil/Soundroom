//
//  EnumeratedTypes.h
//  Soundroom
//
//  Created by Megan Miller on 7/25/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PlayState) {
    Paused = 0,
    Playing = 1,
    Disabled = 2
};

typedef NS_ENUM(NSUInteger, SongCellType) {
    QueueCell,
    SearchCell
};

typedef NS_ENUM(NSUInteger, RoomCellType) {
    InvitationCell,
    HistoryCell
};

typedef NS_ENUM(NSUInteger, RoomListeningModeType) {
    PartyMode = 0,
    RemoteMode = 1
};

typedef NS_ENUM(NSInteger, VoteState) {
    Upvoted = 1,
    NotVoted = 0,
    Downvoted = -1
};


NS_ASSUME_NONNULL_END
