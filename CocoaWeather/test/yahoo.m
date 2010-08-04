
#import "CWWeather.h"
#import "CWAPI.h"
#import "CWYahooAPI.h"
#import <CoreLocation/CoreLocation.h>

@interface YahooTest : GHTestCase {
  CWYahooAPI *api;
}
@end

@implementation YahooTest

- (BOOL)shouldRunOnMainThread {
  return NO;
}

- (void)setUpClass {
  api = [[CWYahooAPI alloc] init];
  [CWYahooAPI setSingleton:api];
}

- (void)tearDownClass {
  [CWYahooAPI setSingleton:nil];
  [api release];
}

- (void)setUp {
  [CWYahooAPI setSingleton:api];
}

- (void)tearDown {
}

- (void)testSingleton {

  [CWYahooAPI setSingleton:nil];

  GHAssertTrue([CWYahooAPI singleton] == nil, @"Singleton should be nil.");
  GHAssertTrue([CWAPI singleton] == nil, @"Singleton should be nil.");

  [CWYahooAPI setSingleton:api];
  GHAssertTrue([CWYahooAPI singleton] == api, @"Singleton should be api.");
  GHAssertTrue([CWAPI singleton] == api, @"Singleton should be api.");

  [CWYahooAPI setSingleton:nil];
  GHAssertTrue([CWYahooAPI singleton] == nil, @"Singleton should be nil.");
  GHAssertTrue([CWAPI singleton] == nil, @"Singleton should be nil.");

  [CWYahooAPI setAsSingleton];
  GHAssertTrue([CWYahooAPI singleton] != nil, @"Singleton should not be nil.");
  GHAssertTrue([CWYahooAPI singleton] != api, @"Singleton should not be api.");
  GHAssertTrue([CWAPI singleton] != nil, @"Singleton should not be nil.");
  GHAssertTrue([CWAPI singleton] != api, @"Singleton should not be api.");

  [CWYahooAPI setSingleton:api];

}

- (void)testPlace {
  GHFail([[CWYahooAPI weatherForPlace:@"94301"] summary]);
}

- (void)testLocation {
  CLLocation *loc;
  loc = [[CLLocation alloc] initWithLatitude:37.4532 longitude:-122.1549];
  GHFail([[CWYahooAPI weatherForLocation:loc] summary]);
}

//- (void)testCurrentLocation {
//  GHFail([[CWYahooAPI weatherForCurrentLocation] summary]);
//}

@end