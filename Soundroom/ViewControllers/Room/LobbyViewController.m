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

@interface LobbyViewController () <UITableViewDelegate, UITableViewDataSource, RoomCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray <NSString *> *invitationIds;
@property (strong, nonatomic) NSDictionary *invitationsWithRooms;

@end

@implementation LobbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView];
    [self configureObservers];
    [self fetchInvitations];
}

- (void)configureTableView {
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 76.f;
    _tableView.layer.borderWidth = 1.8f;
    _tableView.layer.borderColor = [UIColor tertiarySystemBackgroundColor].CGColor;
    [_tableView registerClass:[RoomCell class] forCellReuseIdentifier:[RoomCell reuseIdentifier]];
}

- (void)configureObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToRoom) name:RoomManagerJoinedRoomNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchInvitations) name:ParseLiveQueryManagerUpdatedPendingInvitationsNotification object:nil];
}

- (void)fetchInvitations {
    [self fetchPendingRoomsWithCompletion:^(void) {
        [self->_tableView reloadDataWithAnimation];
    }];
}

- (void)goToRoom {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self dismissViewControllerAnimated:YES completion:nil]; // dismiss configureVC
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil]; // dismiss self
    });
}

# pragma mark - Invitations

- (void)fetchPendingRoomsWithCompletion:(void (^)(void))completion {
    
    __block NSMutableDictionary *invitationsWithRooms = [NSMutableDictionary new];
    
    [ParseQueryManager getInvitationsPendingForCurrentUserWithCompletion:^(NSArray *invitations, NSError *error) {
        
        __block NSUInteger counter = invitations.count;
        
        if (invitations.count == 0) {
            return;
        }
        
        for (Invitation *invitation in invitations) {
            
            [ParseQueryManager getRoomWithId:invitation.roomId completion:^(PFObject *object, NSError *error) {
                
                if (object != nil) {
                    Room *room = (Room *)object;
                    invitationsWithRooms[invitation.objectId] = room;
                }
                
                if (--counter == 0) {
                    self->_invitationIds = [invitations valueForKey:objectIdKey];
                    self->_invitationsWithRooms = invitationsWithRooms;
                    completion();
                }
                
            }];
            
        }
        
    }];
    
}

# pragma mark - Room Cell Delegate

- (void)didTapAcceptInvitationWithId:(NSString *)invitationId {
    [ParseObjectManager acceptInvitationWithId:invitationId];
}

- (void)didTapRejectInvitationWithId:(NSString *)invitationId {
    [ParseObjectManager deleteInvitationWithId:invitationId];
}

# pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    !_invitationIds.count ? [_tableView showEmptyMessageWithText:@"No pending invitations."] : [_tableView removeEmptyMessage];
    return _invitationIds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RoomCell *cell = [tableView dequeueReusableCellWithIdentifier:[RoomCell reuseIdentifier]];
    
    NSString *invitationId = _invitationIds[indexPath.row];
    Room *room = _invitationsWithRooms[invitationId];
    
    cell.objectId = invitationId;
    cell.title = room.title;
    cell.cellType = InvitationCell;
    cell.delegate = self;
    
    return cell;
    
}

@end
