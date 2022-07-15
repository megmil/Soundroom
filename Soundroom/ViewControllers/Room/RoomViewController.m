//
//  RoomViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "RoomViewController.h"
#import "LobbyViewController.h"
#import "ParseRoomManager.h"
#import "ParseUserManager.h"

@interface RoomViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation RoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViews) name:ParseRoomManagerJoinedRoomNotification object:nil];
}

- (void)refreshViews {
    self.titleLabel.text = [[ParseRoomManager shared] currentRoomTitle];
}

- (IBAction)leaveRoom:(id)sender {
    if ([self isCurrentUserHost]) {
        [[ParseRoomManager shared] removeAllUsersWithCompletion:nil];
        return;
    }
    [[ParseRoomManager shared] removeUserWithId:[ParseUserManager currentUserId] completion:nil];
}

- (BOOL)isCurrentUserHost {
    NSString *currentUserId = [ParseUserManager currentUserId];
    NSString *hostId = [[ParseRoomManager shared] currentHostId];
    if (currentUserId && hostId) {
        return [currentUserId isEqual:hostId];
    }
    return NO;
}

@end
