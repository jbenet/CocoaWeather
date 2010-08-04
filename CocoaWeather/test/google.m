
#import "CWWeather.h"
#import "CWAPI.h"
#import "CWGoogleAPI.h"
#import <CoreLocation/CoreLocation.h>

@interface GoogleTest : GHTestCase {
  CWGoogleAPI *api;
}
@end

@implementation GoogleTest

- (BOOL)shouldRunOnMainThread {
  return NO;
}

- (void)setUpClass {
  api = [[CWGoogleAPI alloc] init];
  [CWGoogleAPI setSingleton:api];
}

- (void)tearDownClass {
  [CWGoogleAPI setSingleton:nil];
  [api release];
}

- (void)setUp {
  [CWGoogleAPI setSingleton:api];
}

- (void)tearDown {
}

- (void)testSingleton {

  [CWGoogleAPI setSingleton:nil];

  GHAssertTrue([CWGoogleAPI singleton] == nil, @"Singleton should be nil.");
  GHAssertTrue([CWAPI singleton] == nil, @"Singleton should be nil.");

  [CWGoogleAPI setSingleton:api];
  GHAssertTrue([CWGoogleAPI singleton] == api, @"Singleton should be api.");
  GHAssertTrue([CWAPI singleton] == api, @"Singleton should be api.");

  [CWGoogleAPI setSingleton:nil];
  GHAssertTrue([CWGoogleAPI singleton] == nil, @"Singleton should be nil.");
  GHAssertTrue([CWAPI singleton] == nil, @"Singleton should be nil.");

  [CWGoogleAPI setAsSingleton];
  GHAssertTrue([CWGoogleAPI singleton] != nil, @"Singleton should not be nil.");
  GHAssertTrue([CWGoogleAPI singleton] != api, @"Singleton should not be api.");
  GHAssertTrue([CWAPI singleton] != nil, @"Singleton should not be nil.");
  GHAssertTrue([CWAPI singleton] != api, @"Singleton should not be api.");

  [CWGoogleAPI setSingleton:api];

}

- (void)testPlace {
  GHFail([[CWGoogleAPI weatherForPlace:@"94301"] summary]);
}

- (void)testLocation {
  CLLocation *loc;
  loc = [[CLLocation alloc] initWithLatitude:37.4532 longitude:-122.1549];
  GHFail([[CWGoogleAPI weatherForLocation:loc] summary]);
}

//- (void)testCurrentLocation {
//  GHFail([[CWGoogleAPI weatherForCurrentLocation] summary]);
//}

@end