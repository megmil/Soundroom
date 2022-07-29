//
//  LobbyViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "LobbyViewController.h"
#import "RoomManager.h"
#import "ParseConstants.h"
#import "ParseQueryManager.h"
#import "ParseObjectManager.h"
#import "ParseLiveQueryManager.h"
#import "RoomCell.h"
#import "Room.h"
#import "Invitation.h"
#import "UITableView+AnimationControl.h"
#import "UITableView+ReuseIdentifier.h"
#import "UITableView+EmptyMessage.h"

NSString *const LobbyViewControllerIdentifier = @"LobbyViewController";
static NSString *const emptyMessage = @"No pending invitations.";

@interface LobbyViewController () <UITableViewDelegate, UITableViewDataSource, RoomCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray <NSString *> *invitationIds;
@property (strong, nonatomic) NSDictionary *invitationsWithRooms;

@end

@implementation LobbyViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self configureTableView];
    [self loadRooms];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToRoom) name:RoomManagerJoinedRoomNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRooms) name:ParseLiveQueryManagerUpdatedPendingInvitationsNotification object:nil];
    
}

- (void)goToRoom {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self dismissViewControllerAnimated:YES completion:nil]; // dismiss configureVC
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil]; // dismiss self
    });
}

# pragma mark - Invitations

- (void)loadRooms {
    [self fetchPendingRoomsWithCompletion:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self->_tableView reloadDataWithAnimation];
        }
    }];
}

- (void)fetchPendingRoomsWithCompletion:(PFBooleanResultBlock)completion {
    
    [ParseQueryManager getInvitationsPendingForCurrentUserWithCompletion:^(NSArray *invitations, NSError *error) {
        
        if (!invitations || !invitations.count) {
            completion(NO, error);
            return;
        }
        
        [ParseQueryManager getRoomsForInvitations:invitations completion:^(NSDictionary *invitationsWithRooms) {
            
            if (!invitationsWithRooms || !invitationsWithRooms.count) {
                completion(NO, error);
                return;
            }
            
            self->_invitationIds = [invitations valueForKey:objectIdKey];
            self->_invitationsWithRooms = invitationsWithRooms;
            completion(YES, nil);
            
        }];
        
    }];
    
}

# pragma mark - Room Cell Delegate

- (void)didTapAcceptInvitationWithId:(NSString *)invitationId {
    [ParseObjectManager acceptInvitationWithId:invitationId];
}

- (void)didTapRejectInvitationWithId:(NSString *)invitationId {
    [ParseObjectManager deleteInvitationWithId:invitationId];
}

# pragma mark - Table View Delegate / Data Source

- (void)configureTableView {
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 76.f;
    [_tableView registerClass:[RoomCell class] forCellReuseIdentifier:[RoomCell reuseIdentifier]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (!_invitationIds.count) {
        [_tableView showEmptyMessageWithText:emptyMessage];
    } else {
        [_tableView removeEmptyMessage];
    }
    
    return _invitationIds.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RoomCell *cell = [tableView dequeueReusableCellWithIdentifier:[RoomCell reuseIdentifier]];
    
    NSString *invitationId = _invitationIds[indexPath.row];
    Room *room = _invitationsWithRooms[invitationId];
    
    cell.objectId = invitationId;
    cell.title = room.title;
    // TODO: set image
    cell.cellType = InvitationCell;
    cell.delegate = self;
    return cell;
    
}

@end
