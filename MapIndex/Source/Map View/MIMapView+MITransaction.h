/**
 * Created with JetBrains AppCode.
 * Author: dmitriy
 * Date: 28.04.13 17:48
 */

#import "MIMapView.h"

@interface MIMapView (MITransaction)

- (void)lock:(MITransaction *)transaction;
- (void)unlock:(MITransaction *)transaction;
- (BOOL)isLocked;

#pragma mark - Transaction Actions

- (void)transaction:(MITransaction *)transaction addAnnotation:(id <MKAnnotation>)annotation;
- (void)transaction:(MITransaction *)transaction addAnnotations:(NSArray *)annotations;
- (void)transaction:(MITransaction *)transaction removeAnnotation:(id <MKAnnotation>)annotation;
- (void)transaction:(MITransaction *)transaction removeAnnotations:(NSArray *)annotations;

@end