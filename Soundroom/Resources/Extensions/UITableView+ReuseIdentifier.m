//
//  UITableView+ReuseIdentifier.m
//  Soundroom
//
//  Created by Megan Miller on 7/26/22.
//

#import "UITableView+ReuseIdentifier.h"

@implementation UITableViewCell (ReuseIdentifier)

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self);
}

@end
