//
//  EnumeratedTypes.h
//  Soundroom
//
//  Created by Megan Miller on 7/25/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SearchType) {
    TrackAndUserSearch = 0,
    TrackSearch = 1,
    UserSearch = 2
};

typedef NS_ENUM(NSUInteger, AccountType) {
    Deezer = 0,
    Soundroom = 1,
    Spotify = 2,
    AppleMusic = 3
};

typedef NS_ENUM(NSUInteger, PlayState) {
    Disabled = 0,
    Playing = 1,
    Paused = 2
};

typedef NS_ENUM(NSUInteger, SongCellType) {
    QueueCell,
    SearchCell
};

typedef NS_ENUM(NSUInteger, RoomCellType) {
    InvitationCell,
    HistoryCell
};

typedef NS_ENUM(NSUInteger, RoomListeningMode) {
    PartyMode = 0,
    RemoteMode = 1
};

typedef NS_ENUM(NSInteger, VoteState) {
    Upvoted = 1,
    NotVoted = 0,
    Downvoted = -1
};


NS_ASSUME_NONNULL_END
