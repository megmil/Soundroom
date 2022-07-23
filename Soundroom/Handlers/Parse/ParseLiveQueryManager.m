//
//  ParseLiveQueryManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/22/22.
//

#import "ParseLiveQueryManager.h"
#import "ParseQueryManager.h"
#import "RoomManager.h"
#import "QueueSong.h"
#import "Vote.h"
#import "Invitation.h"

@implementation ParseLiveQueryManager {
    PFQuery *_invitationLiveQuery;
    PFQuery *_songLiveQuery;
    PFQuery *_voteLiveQuery;
}

+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
        NSMutableDictionary *credentials = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        NSString *server = [credentials objectForKey:@"parse-live-server"];
        NSString *appId = [credentials objectForKey:@"parse-app-id"];
        NSString *clientKey = [credentials objectForKey:@"parse-client-key"];
        _client = [[PFLiveQueryClient alloc] initWithServer:server applicationId:appId clientKey:clientKey];
        
    }
    
    return self;
    
}

- (void)configureUserLiveSubscription {
    
    if (_invitationLiveQuery) {
        [_client unsubscribeFromQuery:_invitationLiveQuery];
    }
    
    // get query for invitations accepted by current user
    _invitationLiveQuery = [ParseQueryManager queryForInvitationsAcceptedByCurrentUser];
    _invitationSubscription = [_client subscribeToQuery:_invitationLiveQuery];
    
    // accepted invitation is created (current user created room)
    _invitationSubscription = [_invitationSubscription addCreateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Invitation *invitation = (Invitation *)object;
        [[RoomManager shared] joinRoomWithId:invitation.roomId];
    }];
    
    // pending invitation is accepted (current user accepted invite)
    _invitationSubscription = [_invitationSubscription addUpdateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Invitation *invitation = (Invitation *)object;
        [[RoomManager shared] joinRoomWithId:invitation.roomId];
    }];
    
    // accepted invitation is deleted
    _invitationSubscription = [_invitationSubscription addDeleteHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        [[RoomManager shared] clearRoomData];
    }];
    
}

- (void)configureRoomLiveSubscriptions {
    [self configureSongSubscription];
    [self configureVoteSubscription];
}

- (void)configureSongSubscription {
    
    if (_songLiveQuery) {
        [_client unsubscribeFromQuery:_songLiveQuery];
    }
    
    // check for valid roomId
    NSString *roomId = [[RoomManager shared] currentRoomId];
    if (!roomId) {
        return;
    }
    
    _songLiveQuery = [ParseQueryManager queryForSongsInCurrentRoom];
    _songSubscription = [_client subscribeToQuery:_songLiveQuery];
    
    // new song request is created
    _songSubscription = [_songSubscription addCreateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        QueueSong *song = (QueueSong *)object;
        [[RoomManager shared] insertQueueSong:song];
    }];
    
    // song request is removed
    _songSubscription = [_songSubscription addDeleteHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        QueueSong *song = (QueueSong *)object;
        [[RoomManager shared] removeQueueSong:song];
    }];
    
}

- (void)configureVoteSubscription {
    
    if (_voteLiveQuery) {
        [_client unsubscribeFromQuery:_voteLiveQuery];
    }
    
    // check for valid roomId
    NSString *roomId = [[RoomManager shared] currentRoomId];
    if (!roomId) {
        return;
    }
    
    _voteLiveQuery = [ParseQueryManager queryForVotesInCurrentRoom];
    _voteSubscription = [_client subscribeToQuery:_voteLiveQuery];
    
    // vote is created
    _voteSubscription = [_voteSubscription addCreateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Vote *vote = (Vote *)object;
        [[RoomManager shared] updateQueueSongWithId:vote.songId];
    }];
    
    // vote is updated
    _voteSubscription = [_voteSubscription addUpdateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Vote *vote = (Vote *)object;
        [[RoomManager shared] updateQueueSongWithId:vote.songId];
    }];
    
}

- (void)clearUserLiveSubscriptions {
    [_client unsubscribeFromQuery:_invitationLiveQuery];
}

- (void)clearRoomLiveSubscriptions {
    [_client unsubscribeFromQuery:_songLiveQuery];
    [_client unsubscribeFromQuery:_voteLiveQuery];
}

@end
