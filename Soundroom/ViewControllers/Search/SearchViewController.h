//
//  SearchViewController.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SearchType) {
    TrackAndUserSearch = 0,
    TrackSearch = 1,
    UserSearch = 2
};

@interface SearchViewController : UIViewController

@property (nonatomic) SearchType searchType;

@end

NS_ASSUME_NONNULL_END
