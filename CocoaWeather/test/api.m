
#import "CWWeather.h"
#import "CWAPI.h"
#import <CoreLocation/CoreLocation.h>

@interface ApiTest : GHTestCase {
  CWAPI *api;
}
@end

@implementation ApiTest

- (BOOL)shouldRunOnMainThread {
  return NO;
}

- (void)setUpClass {
  api = [[CWAPI alloc] init];
}

- (void)tearDownClass {
  [api release];
}

- (void)setUp {
}

- (void)tearDown {
}

- (void)testSingleton {
  GHAssertTrue([CWAPI singleton] == nil, @"Singleton should be nil.");

  [CWAPI setSingleton:api];
  GHAssertTrue([CWAPI singleton] == api, @"Singleton should be api.");

  [CWAPI setSingleton:nil];
  GHAssertTrue([CWAPI singleton] == nil, @"Singleton should be nil.");

  [CWAPI setAsSingleton];
  GHAssertTrue([CWAPI singleton] != nil, @"Singleton should not be nil.");
  GHAssertTrue([CWAPI singleton] != api, @"Singleton should not be api.");

}


@end