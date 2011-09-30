
#import <CoreLocation/CoreLocation.h>
#import "Locator.h"

@interface LocatorTest : GHTestCase {

}
@end

@implementation LocatorTest

- (BOOL)shouldRunOnMainThread {
  return NO;
}

- (void)setUpClass {
}

- (void)tearDownClass {
}

- (void)setUp {
}

- (void)tearDown {
}

- (void)testSingleton {
  GHAssertTrue([Locator singleton] != nil, @"Singleton should not be nil.");


}

- (void) testSimLocation {

  [[Locator singleton] startUpdatingLocation];
//  CLLocation *loc = [[Locator singleton] waitForAccurateLocation];
//  NSLog(@"Location: %@", loc);
}


@end