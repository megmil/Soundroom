//
//  LobbyViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "LobbyViewController.h"
#import "RoomManager.h"
#import "ParseQueryManager.h"
#import "ParseLiveQueryManager.h"
#import "RoomCell.h"
#import "Room.h"
#import "Invitation.h"
#import "UITableView+AnimationControl.h"
#import <Parse/Parse.h>

@interface LobbyViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray <Room *> *rooms;
@property (strong, nonatomic) NSMutableArray <Invitation *> *invitations;

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
        
        if (!succeeded) {
            self->_rooms = [NSMutableArray <Room *> array];
            self->_invitations = [NSMutableArray <Invitation *> array];
            [self->_tableView reloadData];
        }
        
        [self->_tableView reloadDataWithAnimation];
        
    }];
    
}

- (void)fetchPendingRoomsWithCompletion:(PFBooleanResultBlock)completion {
    
    [ParseQueryManager getInvitationsPendingForCurrentUserWithCompletion:^(NSArray *invitations, NSError *error) {
        
        if (!invitations || !invitations.count) {
            completion(NO, error);
            return;
        }
        
        [ParseQueryManager getRoomsForInvitations:invitations completion:^(NSArray *rooms, NSError *error) {
            
            if (!rooms || !rooms.count || invitations.count != rooms.count) {
                completion(NO, error);
                return;
            }
            
            self->_invitations = (NSMutableArray <Invitation *> *)invitations;
            self->_rooms = (NSMutableArray <Room *> *)rooms;
            completion(YES, nil);

            
        }];
        
    }];
    
}

# pragma mark - Table View

- (void)configureTableView {
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 76.f;
    [_tableView registerClass:[RoomCell class] forCellReuseIdentifier:@"InvitationCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _rooms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RoomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InvitationCell"];
    Invitation *invitation = _invitations[indexPath.row];
    Room *room = _rooms[indexPath.row];
    cell.title = room.title;
    // TODO: set image
    cell.objectId = invitation.objectId;
    cell.cellType = InvitationCell;
    return cell;
}

@end
