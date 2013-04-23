/**
 * Created with JetBrains AppCode.
 * Author: dmitriy
 * Date: 19.04.13 11:27
 */

#import <Foundation/Foundation.h>
#import "MIMapView.h"

@class MITransaction;

@interface MIMapView (MITransaction) <NSLocking>

/**
* Transaction can add annotations ONLY by this methods.
* Usage of public addAnnotation: addAnnotations: removeAnnotation: removeAnnotations: will leads to assertion.
*/
- (void)addTransactionAnnotation:(id <MKAnnotation>)annotation;

- (void)addTransactionAnnotations:(NSArray *)annotations;

- (void)removeTransactionAnnotation:(id <MKAnnotation>)annotation;

- (void)removeTransactionAnnotations:(NSArray *)annotations;

/**
* Transaction lock should be used only if transaction is continuous.
* For example: transaction modify somehow map annotations and after animation completion
* perform additional changes. This require immutable map state.
* For this example you have to:
* [mapView lockForTransaction:self];
*
* // perform animation
*
* // on animation completion
* [mapView unlockForTransaction:self];
*/

- (void)lock;
- (void)unlock;
- (BOOL)isLocked;

@end