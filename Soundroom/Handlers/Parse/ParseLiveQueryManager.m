//
//  ParseLiveQueryManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/22/22.
//

#import "ParseLiveQueryManager.h"
#import "ParseQueryManager.h"
#import "RoomManager.h"
#import "Request.h"
#import "Upvote.h"
#import "Downvote.h"
#import "Invitation.h"

@implementation ParseLiveQueryManager {
    PFQuery *_invitationLiveQuery;
    PFQuery *_songLiveQuery;
    PFQuery *_upvoteLiveQuery;
    PFQuery *_downvoteLiveQuery;
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

# pragma mark - Public

- (void)configureRoomLiveSubscriptions {
    [self configureSongSubscription];
    [self configureUpvoteSubscription];
    [self configureDownvoteSubscription];
}

- (void)clearUserLiveSubscriptions {
    [_client unsubscribeFromQuery:_invitationLiveQuery];
}

- (void)clearRoomLiveSubscriptions {
    [_client unsubscribeFromQuery:_songLiveQuery];
    [_client unsubscribeFromQuery:_upvoteLiveQuery];
    [_client unsubscribeFromQuery:_downvoteLiveQuery];
}

# pragma mark - Invitations

- (void)configureUserLiveSubscriptions {
    
    if (_invitationLiveQuery) {
        [_client unsubscribeFromQuery:_invitationLiveQuery];
    }
    
    // get query for invitations accepted by current user
    _invitationLiveQuery = [ParseQueryManager queryForInvitationsForCurrentUser];
    _invitationSubscription = [_client subscribeToQuery:_invitationLiveQuery];
    
    // invitation is created
    _invitationSubscription = [_invitationSubscription addCreateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        
        Invitation *invitation = (Invitation *)object;
        
        if (invitation.isPending) {
            // another user invited current user to their room
            [[NSNotificationCenter defaultCenter] postNotificationName:ParseLiveQueryManagerUpdatedPendingInvitationsNotification object:nil];
        } else {
            // current user created room: auto-join
            [[RoomManager shared] joinRoomWithId:invitation.roomId];
        }
        
    }];
    
    // invitation is updated: current user accepted invite
    _invitationSubscription = [_invitationSubscription addUpdateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Invitation *invitation = (Invitation *)object;
        [[RoomManager shared] joinRoomWithId:invitation.roomId];
    }];
    
    // invitation is deleted
    _invitationSubscription = [_invitationSubscription addDeleteHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        
        Invitation *invitation = (Invitation *)object;
        
        if (invitation.isPending) {
            // invitation was revoked
            [[NSNotificationCenter defaultCenter] postNotificationName:ParseLiveQueryManagerUpdatedPendingInvitationsNotification object:nil];
        } else {
            // current user left or was removed from room
            [[RoomManager shared] clearRoomData];
        }
        
    }];
    
}

# pragma mark - Requests

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
        Request *request = (Request *)object;
        [[RoomManager shared] insertSongWithRequest:request];
    }];
    
    // song request is removed
    _songSubscription = [_songSubscription addDeleteHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Request *request = (Request *)object;
        [[RoomManager shared] removeSongWithRequestId:request.objectId];
    }];
    
}

# pragma mark - Votes

- (void)configureUpvoteSubscription {
    
    if (_upvoteLiveQuery) {
        [_client unsubscribeFromQuery:_upvoteLiveQuery];
    }
    
    // check for valid roomId
    NSString *roomId = [[RoomManager shared] currentRoomId];
    if (!roomId) {
        return;
    }
    
    _upvoteLiveQuery = [ParseQueryManager queryForUpvotesInCurrentRoom];
    _upvoteSubscription = [_client subscribeToQuery:_upvoteLiveQuery];
    
    // upvote is created
    _upvoteSubscription = [_upvoteSubscription addCreateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Upvote *upvote = (Upvote *)object;
        [[RoomManager shared] updateQueueWithCreatedUpvote:upvote];
    }];
    
    // upvote is deleted
    _upvoteSubscription = [_upvoteSubscription addDeleteHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Upvote *upvote = (Upvote *)object;
        [[RoomManager shared] updateQueueWithDeletedUpvote:upvote];
    }];
    
}

- (void)configureDownvoteSubscription {
    
    if (_downvoteLiveQuery) {
        [_client unsubscribeFromQuery:_downvoteLiveQuery];
    }
    
    // check for valid roomId
    NSString *roomId = [[RoomManager shared] currentRoomId];
    if (!roomId) {
        return;
    }
    
    _downvoteLiveQuery = [ParseQueryManager queryForDownvotesInCurrentRoom];
    _downvoteSubscription = [_client subscribeToQuery:_downvoteLiveQuery];
    
    // downvote is created
    _downvoteSubscription = [_downvoteSubscription addCreateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Downvote *downvote = (Downvote *)object;
        [[RoomManager shared] updateQueueWithCreatedDownvote:downvote];
    }];
    
    // downvote is deleted
    _downvoteSubscription = [_downvoteSubscription addDeleteHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Downvote *downvote = (Downvote *)object;
        [[RoomManager shared] updateQueueWithDeletedDownvote:downvote];
    }];
    
}

@end
