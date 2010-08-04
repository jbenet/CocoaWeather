
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
//#import <MapKit/MapKit.h>

typedef struct {
  NSDate *last;
  int updates;
  int errors;
} LocatorMetrics;

@protocol LocatorDelegate
- (void) locatorDidUpdateToLocation:(CLLocation *)location;
@end


@interface Locator : NSObject <CLLocationManagerDelegate, UIAlertViewDelegate> {

  CLLocationManager *manager;
  CLLocation *location;
  CLHeading *heading;

  LocatorMetrics headingMetrics;
  LocatorMetrics locationMetrics;

  BOOL trackLocation;
  BOOL trackHeading;

  BOOL canAlertUser;
  NSString *appName;

  NSMutableArray *delegates;

  BOOL waitingToStopHeading;
  BOOL waitingToStopLocation;
}

@property (nonatomic, retain) CLLocationManager *manager;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) CLHeading *heading;

@property (nonatomic, assign) BOOL trackLocation;
@property (nonatomic, assign) BOOL trackHeading;

@property (nonatomic, assign) BOOL canAlertUser;
@property (nonatomic, copy) NSString *appName;

@property (nonatomic, retain) NSMutableArray *delegates;

- (void) addDelegate:(id<LocatorDelegate>)delegate;

- (void) initMetrics:(LocatorMetrics)metric;
- (void) staleCheckMetrics:(LocatorMetrics)metric;
- (BOOL) metricsAreAccurate:(LocatorMetrics)metric;

- (void) startUpdatingHeading;
- (void)  stopUpdatingHeading;

- (void) startUpdatingLocation;
- (void)  stopUpdatingLocation;

- (void) startUpdatingLocationIn:(NSTimeInterval)seconds;
- (void)  startUpdatingHeadingIn:(NSTimeInterval)seconds;

- (void)  stopUpdatingHeadingWhenAccurate;
- (void) stopUpdatingLocationWhenAccurate;

- (CLLocation *) waitForAccurateLocation;
- (CLHeading *)  waitForAccurateHeading;


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

//- (NSString *) address;
//- (NSString *) addressForLocation:(CLLocation *)location;
//- (NSString *) cityForLocation:(CLLocation *)location;
//- (NSString *)

- (void) showAlertWithMessage:(NSString *)string;

+ (Locator *) singleton;
//+ (NSString *) addressForPlacemark:(MKPlacemark *)placemark;

@end