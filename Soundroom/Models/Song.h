//
//  Song.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Song : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *albumString;
// album image (unsure what type - possible Album model?)
// song length

+ (NSMutableArray *)songsWithArray:(NSArray *)dictionaries;

@end

NS_ASSUME_NONNULL_END
