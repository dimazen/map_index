/**
 * Created with JetBrains AppCode.
 * Author: dmitriy
 * Date: 19.04.13 11:27
 */

#import <Foundation/Foundation.h>
#import "MIMapView.h"

@class MITransaction;

@interface MIMapView (MITransaction)

/**
* Transaction can add annotations ONLY by this methods.
* Usage of public addAnnotation: addAnnotations: removeAnnotation: removeAnnotations: will leads to assertion.
*/
- (void)transaction:(MITransaction *)transaction addAnnotation:(id <MKAnnotation>)annotation;

- (void)transaction:(MITransaction *)transaction addAnnotations:(NSArray *)annotations;

- (void)transaction:(MITransaction *)transaction removeAnnotation:(id <MKAnnotation>)annotation;

- (void)transaction:(MITransaction *)transaction removeAnnotations:(NSArray *)annotations;

/**
* Transaction lock should be used only if transaction is continuous.
* For example: transaction modify somehow map annotations and after animation completion
* perform additional changes. This require immutable map state.
* For this example you have to:
* [mapView lock:self];
*
* // perform animation
*
* // on animation completion
* [mapView unlock:self];
*/

- (void)lock:(MITransaction *)lockTransaction;

- (void)unlock:(MITransaction *)lockTransaction;
- (BOOL)isLocked;

@end