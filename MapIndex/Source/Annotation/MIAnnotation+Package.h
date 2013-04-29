/**
 * Created with JetBrains AppCode.
 * Author: dmitriy
 * Date: 28.04.13 18:31
 */

#import <Foundation/Foundation.h>
#import "MIAnnotation.h"

@interface MIAnnotation (Package)

@property (nonatomic, assign) MIQuadTreeRef content;

- (void)prepareForReuse;

@property (nonatomic, assign, readonly) BOOL dataAvailable;
@property (nonatomic, assign) BOOL readAvailable;

@end