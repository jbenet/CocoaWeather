//
// CocoaWeather -- CWAPI
//
// @author jbenet@cs.stanford.edu
//

// This class is meant to be subclassed.
// It is not just a protocol, common parts are abstracted.


#import "CWAPI.h"
#import "CWWeather.h"
#import "Locator.h"
#import <CoreLocation/CoreLocation.h>


static NSString *kNAME = @"Sample Weather API";
static NSString *kURL = @"http://sampleweatherapi.com";

static CWAPI *singleton = nil;

@implementation CWAPI

@synthesize useSQLiteCaching, cacheTime;


//------------------------------------------------------------------------------

- (NSString *) url
{
  return kURL;
}

- (NSString *) name
{
  return kNAME;
}

//------------------------------------------------------------------------------

+ (BOOL) useSQLiteCaching
{
  return singleton.useSQLiteCaching;
}

+ (void) setUseSQLiteCaching:(BOOL)caching
{
  singleton.useSQLiteCaching = caching;
}

+ (NSTimeInterval) cacheTime
{
  return singleton.cacheTime;
}

+ (void) setCacheTime:(NSTimeInterval)time
{
  singleton.cacheTime = time;
}

//------------------------------------------------------------------------------

+ (CWWeather *) weatherForPlace:(NSString *)name
{
  return [[self singleton] weatherForPlace:name];
}

+ (CWWeather *) weatherForLocation:(CLLocation *)location
{
  return [[self singleton] weatherForLocation:location];
}

+ (CWWeather *) weatherForCurrentLocation
{
  return [[self singleton] weatherForCurrentLocation];
}

+ (CWWeather *) weatherForURL:(NSString *)url
{
  return [[self singleton] weatherForURL:url];
}

//------------------------------------------------------------------------------

- (CWWeather *) weatherForPlace:(NSString *)name
{
  return nil;
}

- (CWWeather *) weatherForLocation:(CLLocation *)location
{
  return nil;
}

- (CWWeather *) weatherForCurrentLocation
{
  NSLog(@"CocoaWeather -- weatherForCurrentLocation");
  return [self weatherForLocation:[[Locator singleton] waitForAccurateLocation]];
}

- (CWWeather *) weatherForURL:(NSString *)url
{
  return nil;
}


//------------------------------------------------------------------------------

- (void) locatorDidUpdateToLocation:(CLLocation *)location
{

}

//------------------------------------------------------------------------------

+ (CWAPI *) singleton
{
  return singleton;
}

+ (void) setSingleton:(CWAPI *)cwapi
{
  if (singleton != nil)
    [singleton release];
  singleton = [cwapi retain];
}

+ (void) setAsSingleton
{
  if (singleton != nil)
    [singleton release];

  CWAPI *cwapi = [[[self class] alloc] init];
  [CWAPI setSingleton: cwapi];
  [cwapi release];
}

@end
