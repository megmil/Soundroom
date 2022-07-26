//
//  SearchViewController.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SearchType) {
    SearchTypeTrackAndUser = 0,
    SearchTypeTrack = 1,
    SearchTypeUser = 2
};

@interface SearchViewController : UIViewController

@property (nonatomic) SearchType searchType;

@end

NS_ASSUME_NONNULL_END
