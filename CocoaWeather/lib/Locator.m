
#import "Locator.h"

#ifndef DebugLog
#define DebugLog(...) if (DEBUG) NSLog(__VA_ARGS__)
#endif

static NSString *kSTR_HEADING = @"Error beyond our control. Cannot retrieve heading...";
static NSString *kSTR_DENIED = @"We apologize, but %@ requires location information to function.";

static const float kACCURATE = 120; // in seconds. how long to CLLocationManager.
static const float kSTALE = 600; // in seconds.
static const float kREADS = 6; // number of readings that constitute accuracy

#ifndef DEBUG
#define DEBUG (true)
#endif

static BOOL initialized = NO;
static Locator *singleton = nil;

@implementation Locator

@synthesize location, heading, manager, delegates, appName;
@synthesize trackLocation, trackHeading, canAlertUser;

/* Create only one Locator ever */
+ (id) alloc {
  @synchronized(self) {
    if (singleton == nil)
      singleton = [super alloc];
  }

  return singleton;
}

- (id) init
{
  if (initialized)
    return singleton;

  if (self = [super init])
  {
    self.manager = [[[CLLocationManager alloc] init] autorelease];
    self.manager.delegate = self;
//    self.manager.distanceFilter = kCLDistanceFilterNone; // in meters.
//    self.manager.desiredAccuracy = kCLLocationAccuracyBest;

    [self initMetrics:locationMetrics];
    [self initMetrics:headingMetrics];

    self.delegates = [NSMutableArray arrayWithCapacity:3];
    trackLocation = NO;
    trackHeading = NO;
    canAlertUser = YES;
    self.appName = @"this application";

    initialized = YES;
  }
  return self;
}

- (void) dealloc
{
  self.location = nil;
  self.heading = nil;
  self.manager = nil;
  self.appName = nil;
  self.delegates = nil;
  [super dealloc];
}

- (id)retain
{
  return self;
}

- (NSUInteger) retainCount
{
  return UINT_MAX;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
  return self;
}

//------------------------------------------------------------------------------
#pragma mark Location Manager Delegate

- (void) addDelegate:(id<LocatorDelegate>)delegate
{
  [self.delegates addObject:delegate];
}

- (void)locationManager:(CLLocationManager *)mgr didFailWithError:(NSError *)err
{
  DebugLog(@"Error!");

  NSString *message;
  switch (err.code)
  {
    case kCLErrorDenied:
      message = [NSString stringWithFormat:kSTR_DENIED, self.appName];
      break;
    case kCLErrorHeadingFailure:
      message = kSTR_HEADING;
      break;
    case kCLErrorLocationUnknown:
      locationMetrics.errors++;
      break;
  }
  DebugLog(@"%@", message);

  if (message == nil)
    return;

  [self showAlertWithMessage:message];
}

- (void) locationManager:(CLLocationManager *)mgr
        didUpdateHeading:(CLHeading *)newHeading
{
  self.heading = newHeading;
  headingMetrics.updates++;

  if (headingMetrics.last != nil)
    [headingMetrics.last release];
  headingMetrics.last = [NSDate date];

  if (!trackHeading && [self metricsAreAccurate:headingMetrics])
    [self stopUpdatingHeading];
}

- (void) locationManager:(CLLocationManager *)_manager
     didUpdateToLocation:(CLLocation *)newLocation
            fromLocation:(CLLocation *)oldLocation
{
  DebugLog(@"Update Loc!");

  if (oldLocation == nil) {
    DebugLog(@"Stale Cache!");
    //return; // Ignore the cache...? we are specific sensitive.
  }

  self.location = newLocation;
  locationMetrics.updates++;

  DebugLog(@"New Location: %f, %f", newLocation.coordinate.latitude,
                                    newLocation.coordinate.longitude);

  if (locationMetrics.last != nil)
    [locationMetrics.last release];
  locationMetrics.last = [[NSDate date] retain];

  if (!trackLocation && [self metricsAreAccurate:locationMetrics])
    [self stopUpdatingLocation];

  for (id<LocatorDelegate> delegate in self.delegates)
    [delegate locatorDidUpdateToLocation:self.location];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)mgr
{
  return YES;
}


// ---------------------------------------------------------------------------------
#pragma mark Metrics

- (void) initMetrics:(LocatorMetrics)metric
{
  metric.updates = 0;
  metric.errors = 0;
  metric.last = nil;
}

- (void) staleCheckMetrics:(LocatorMetrics)metric
{
  DebugLog(@"Checking for Stale Metrics...");
  if (metric.last != nil && [metric.last timeIntervalSinceNow] * -1 > kSTALE) {
    DebugLog(@"Stale Metrics... reseting...");

    [metric.last release];
    [self initMetrics:metric];
  }
}

- (BOOL) metricsAreAccurate:(LocatorMetrics)metric
{
  BOOL accurate = (metric.updates > kREADS);
  if (accurate && DEBUG)
    NSLog(@"Metrics are accurate!");
  return accurate;
}

// ---------------------------------------------------------------------------------
#pragma mark Manager-Like

- (void) startUpdatingLocation
{
  [self staleCheckMetrics:locationMetrics];
//  DebugLog(@"lse %@", (self.manager.locationServicesEnabled ? @"YES" : @"NO"));
//  DebugLog(@" %@ == %@", self.manager.delegate, self);
  [self.manager startUpdatingLocation];
//  DebugLog(@" %@ == %@", self.manager.delegate, self);
//  DebugLog(@"%@ delegate of %@", self.manager.delegate, self.manager);
  if (waitingToStopLocation)
    return;

  waitingToStopLocation = YES;
  [NSThread detachNewThreadSelector:@selector(stopUpdatingLocationWhenAccurate)
                           toTarget:self withObject:nil];
}

- (void) startUpdatingHeading
{
  [self staleCheckMetrics:locationMetrics];
  [self.manager startUpdatingHeading];
  if (waitingToStopHeading)
    return;

  waitingToStopHeading = YES;
  [NSThread detachNewThreadSelector:@selector(stopUpdatingHeadingWhenAccurate)
                           toTarget:self withObject:nil];
}

- (void) stopUpdatingLocation
{
  DebugLog(@"Stopping Location Update...");
  [self.manager stopUpdatingLocation];
}

- (void) stopUpdatingHeading
{
  DebugLog(@"Stopping Heading Update...");
  [self.manager stopUpdatingHeading];
}

- (void) startUpdatingLocationIn:(NSTimeInterval)seconds
{
  if ([NSThread isMainThread])
    DebugLog(@"background location updater... updating from main thread!!!");

  [NSThread sleepForTimeInterval: seconds];
  [self startUpdatingLocation];
}


- (void) startUpdatingHeadingIn:(NSTimeInterval)seconds
{
  if ([NSThread isMainThread])
    DebugLog(@"background heading updater... updating from main thread!!!");

  [NSThread sleepForTimeInterval: seconds];
  [self startUpdatingHeading];
}

- (void) stopUpdatingLocationWhenAccurate
{
  if ([NSThread isMainThread])
    DebugLog(@"background location updater... stopping from main thread!!!");

  DebugLog(@"Sleeping...");
  [NSThread sleepForTimeInterval: kACCURATE];
  DebugLog(@"Stopping...");
  waitingToStopLocation = NO;
  [self stopUpdatingLocation];
}


- (void) stopUpdatingHeadingWhenAccurate
{
  if ([NSThread isMainThread])
    DebugLog(@"background heading updater... stopping from main thread!!!");

  DebugLog(@"Sleeping...");
  [NSThread sleepForTimeInterval: kACCURATE];
  DebugLog(@"Stopping...");
  waitingToStopHeading = NO;
  [self stopUpdatingHeading];
}
// ---------------------------------------------------------------------------------
#pragma mark Waiting For Accuracy

- (CLLocation *) waitForAccurateLocation
{
  DebugLog(@"waiting for Accurate Location");

  [self startUpdatingLocation];
  while (![self metricsAreAccurate:locationMetrics]) {
    CLLocation *loc = self.manager.location;
    CLLocationCoordinate2D c = self.manager.location.coordinate;
    NSLog(@"loc: %@ lat: %f lon: %f", loc, c.latitude, c.longitude);
    [NSThread sleepForTimeInterval: 5.0f];
  }

  if (!trackLocation)
    [self stopUpdatingLocation];

  return self.location;
}


- (CLHeading *) waitForAccurateHeading
{
  DebugLog(@"waiting for Accurate Heading");

  [self startUpdatingHeading];
  while (![self metricsAreAccurate:headingMetrics])
    [NSThread sleepForTimeInterval: 1];

  if (!trackHeading)
    [self stopUpdatingHeading];

  return self.heading;
}

/*
#pragma mark Reverse Geocoding

- (NSString *) address
{
  return [self addressForLocation:self.location];
}

- (NSString *) addressForLocation:(CLLocation *)location
{

}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
  NSLog([error localizedDescription]);
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{

}
*/

#pragma mark Other

- (void) showAlertWithMessage:(NSString *)message
{
  if (message == nil || !canAlertUser)
    return;

  UIAlertView *alert;
  alert = [[UIAlertView alloc] initWithTitle:@"Location Error" message:message
              delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];

   // in case this isnt the main thread.
  [alert performSelectorOnMainThread:@selector(show) withObject:nil
                       waitUntilDone:YES];
  [alert release];
}

+ (Locator *) singleton
{
  if (singleton == nil)
    singleton = [[Locator alloc] init];
  return singleton;
}

// + (NSString *) addressForPlacemark:(MKPlacemark *)placemark
// {
//   return [NSString stringWithFormat:@"%@ %@ \n%@ %@ %@",
//     placemark.subThoroughfare, placemark.thoroughfare,
//     placemark.locality, placemark.administrativeArea, placemark.postalCode];
// }

@end