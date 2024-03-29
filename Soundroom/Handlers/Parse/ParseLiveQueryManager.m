//
//  ParseLiveQueryManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/22/22.
//

#import "ParseLiveQueryManager.h"
#import "ParseQueryManager.h"
#import "ParseConstants.h"
#import "RoomManager.h"
#import "Room.h"
#import "Request.h"
#import "Upvote.h"
#import "Downvote.h"
#import "Invitation.h"

NSString *const ParseLiveQueryManagerUpdatedPendingInvitationsNotification = @"ParseLiveQueryManagerUpdatedPendingInvitationsNotification";

@implementation ParseLiveQueryManager {
    
    PFLiveQueryClient *_client;
    
    PFLiveQuerySubscription *_invitationSubscription;
    PFLiveQuerySubscription *_requestSubscription;
    PFLiveQuerySubscription *_upvoteSubscription;
    PFLiveQuerySubscription *_downvoteSubscription;
    PFLiveQuerySubscription *_roomSubscription;
    
    PFQuery *_invitationLiveQuery;
    PFQuery *_requestLiveQuery;
    PFQuery *_upvoteLiveQuery;
    PFQuery *_downvoteLiveQuery;
    PFQuery *_roomLiveQuery;
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
        
        NSString *server = [credentials objectForKey:credentialsKeyParseLiveServer];
        NSString *appId = [credentials objectForKey:credentialsKeyParseApplicationId];
        NSString *clientKey = [credentials objectForKey:credentialsKeyParseClientKey];
        
        _client = [[PFLiveQueryClient alloc] initWithServer:server applicationId:appId clientKey:clientKey];
        
    }
    
    return self;
    
}

# pragma mark - Public

- (void)configureRoomLiveSubscriptions {
    [self configureRequestSubscription];
    [self configureUpvoteSubscription];
    [self configureDownvoteSubscription];
    [self configureRoomSubscription];
}

- (void)clearUserLiveSubscriptions {
    [_client unsubscribeFromQuery:_invitationLiveQuery];
}

- (void)clearRoomLiveSubscriptions {
    [_client unsubscribeFromQuery:_requestLiveQuery];
    [_client unsubscribeFromQuery:_upvoteLiveQuery];
    [_client unsubscribeFromQuery:_downvoteLiveQuery];
    [_client unsubscribeFromQuery:_roomLiveQuery];
}

# pragma mark - Room

- (void)configureRoomSubscription {
    
    if (_roomLiveQuery) {
        [_client unsubscribeFromQuery:_roomLiveQuery];
    }
    
    // check for valid roomId
    NSString *roomId = [[RoomManager shared] currentRoomId];
    if (roomId == nil || roomId.length == 0) {
        return;
    }
    
    _roomLiveQuery = [ParseQueryManager queryForCurrentRoom];
    _roomSubscription = [_client subscribeToQuery:_roomLiveQuery];
    
    // room is updated: new current song
    _roomSubscription = [_roomSubscription addUpdateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Room *room = (Room *)object;
        [[RoomManager shared] setCurrentTrackISRC:room.currentSongISRC];
    }];

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
            // invitation was rejected or revoked
            [[NSNotificationCenter defaultCenter] postNotificationName:ParseLiveQueryManagerUpdatedPendingInvitationsNotification object:nil];
        } else {
            // current user left or was removed from room
            [[RoomManager shared] clearRoomData];
        }
        
    }];
    
}

# pragma mark - Requests

- (void)configureRequestSubscription {
    
    if (_requestLiveQuery) {
        [_client unsubscribeFromQuery:_requestLiveQuery];
    }
    
    // check for valid roomId
    NSString *roomId = [[RoomManager shared] currentRoomId];
    if (roomId == nil || roomId.length == 0) {
        return;
    }
    
    _requestLiveQuery = [ParseQueryManager queryForRequestsInCurrentRoom];
    _requestSubscription = [_client subscribeToQuery:_requestLiveQuery];
    
    // new request is created
    _requestSubscription = [_requestSubscription addCreateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Request *request = (Request *)object;
        [[RoomManager shared] insertRequest:request];
    }];
    
    // request is removed
    _requestSubscription = [_requestSubscription addDeleteHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Request *request = (Request *)object;
        [[RoomManager shared] removeRequestWithId:request.objectId];
    }];
    
}

# pragma mark - Votes

- (void)configureUpvoteSubscription {
    
    if (_upvoteLiveQuery) {
        [_client unsubscribeFromQuery:_upvoteLiveQuery];
    }
    
    // check for valid roomId
    NSString *roomId = [[RoomManager shared] currentRoomId];
    if (roomId == nil || roomId.length == 0) {
        return;
    }
    
    _upvoteLiveQuery = [ParseQueryManager queryForUpvotesInCurrentRoom];
    _upvoteSubscription = [_client subscribeToQuery:_upvoteLiveQuery];
    
    // upvote is created
    _upvoteSubscription = [_upvoteSubscription addCreateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Upvote *upvote = (Upvote *)object;
        [[RoomManager shared] addUpvote:upvote];
    }];
    
    // upvote is deleted
    _upvoteSubscription = [_upvoteSubscription addDeleteHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Upvote *upvote = (Upvote *)object;
        [[RoomManager shared] deleteUpvote:upvote];
    }];
    
}

- (void)configureDownvoteSubscription {
    
    if (_downvoteLiveQuery) {
        [_client unsubscribeFromQuery:_downvoteLiveQuery];
    }
    
    // check for valid roomId
    NSString *roomId = [[RoomManager shared] currentRoomId];
    if (roomId == nil || roomId.length == 0) {
        return;
    }
    
    _downvoteLiveQuery = [ParseQueryManager queryForDownvotesInCurrentRoom];
    _downvoteSubscription = [_client subscribeToQuery:_downvoteLiveQuery];
    
    // downvote is created
    _downvoteSubscription = [_downvoteSubscription addCreateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Downvote *downvote = (Downvote *)object;
        [[RoomManager shared] addDownvote:downvote];
    }];
    
    // downvote is deleted
    _downvoteSubscription = [_downvoteSubscription addDeleteHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Downvote *downvote = (Downvote *)object;
        [[RoomManager shared] deleteDownvote:downvote];
    }];
    
}

@end
