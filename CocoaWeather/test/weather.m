
#import "CWWeather.h"

@interface WeatherTest : GHTestCase {
  CWWeather *weather;
}
@end

@implementation WeatherTest

- (BOOL)shouldRunOnMainThread {
  return NO;
}

- (void)setUpClass {
  weather = [[CWWeather alloc] init];
}

- (void)tearDownClass {
  [weather release];
}

- (void)setUp {
}

- (void)tearDown {
}

- (void)testTemperatures {
  weather.celsius = 0.0f;
  GHAssertEquals(weather.celsius, 0.0f, @"Temperature test");
  GHAssertEquals(weather.fahrenheit, 32.0f, @"Temperature test");

  weather.celsius = 100.0f;
  GHAssertEquals(weather.celsius, 100.0f, @"Temperature test");
  GHAssertEquals(weather.fahrenheit, 212.0f, @"Temperature test");
}


- (void) testWindDirections {

  GHAssertEquals(CWWindDirectionNorth,
        [CWWeather windDirectionFromCString:"N"], @"CWWindDirectionNorth");
  GHAssertEquals(CWWindDirectionSouth,
        [CWWeather windDirectionFromCString:"S"], @"CWWindDirectionSouth");
  GHAssertEquals(CWWindDirectionEast,
        [CWWeather windDirectionFromCString:"E"], @"CWWindDirectionEast");
  GHAssertEquals(CWWindDirectionWest,
        [CWWeather windDirectionFromCString:"W"], @"CWWindDirectionWest");
  GHAssertEquals(CWWindDirectionNorthEast,
        [CWWeather windDirectionFromCString:"NE"], @"CWWindDirectionNorthEast");
  GHAssertEquals(CWWindDirectionNorthWest,
        [CWWeather windDirectionFromCString:"NW"], @"CWWindDirectionNorthWest");
  GHAssertEquals(CWWindDirectionSouthEast,
        [CWWeather windDirectionFromCString:"SE"], @"CWWindDirectionSouthEast");
  GHAssertEquals(CWWindDirectionSouthWest,
        [CWWeather windDirectionFromCString:"SW"], @"CWWindDirectionSouthWest");
  GHAssertEquals(CWWindDirectionNorth,
        [CWWeather windDirectionFromCString:"NX"], @"CWWindDirectionSouthEast");
  GHAssertEquals(CWWindDirectionSouth,
        [CWWeather windDirectionFromCString:"SQ"], @"CWWindDirectionSouthWest");
  GHAssertEquals(CWWindDirectionError,
        [CWWeather windDirectionFromCString:"F"], @"CWWindDirectionError");
  GHAssertEquals(CWWindDirectionError,
        [CWWeather windDirectionFromCString:"GE"], @"CWWindDirectionError");

  GHAssertTrue([[CWWeather stringFromWindDirection:CWWindDirectionNorth]  isEqualToString:@"N"], @"N");
  GHAssertTrue([[CWWeather stringFromWindDirection:CWWindDirectionSouth] isEqualToString:@"S"], @"S");
  GHAssertTrue([[CWWeather stringFromWindDirection:CWWindDirectionWest] isEqualToString:@"W"], @"W");
  GHAssertTrue([[CWWeather stringFromWindDirection:CWWindDirectionEast] isEqualToString:@"E"], @"E");
  GHAssertTrue([[CWWeather stringFromWindDirection:CWWindDirectionNorthWest] isEqualToString:@"NW"], @"NW");
  GHAssertTrue([[CWWeather stringFromWindDirection:CWWindDirectionNorthEast] isEqualToString:@"NE"], @"NE");
  GHAssertTrue([[CWWeather stringFromWindDirection:CWWindDirectionSouthWest] isEqualToString:@"SW"], @"SW");
  GHAssertTrue([[CWWeather stringFromWindDirection:CWWindDirectionSouthEast] isEqualToString:@"SE"], @"SE");


}

- (void) testDateStaleness {

  GHAssertFalse([weather isStale], @"Shouldnt be stale yet");

  weather.date = [NSDate dateWithTimeIntervalSinceNow:-2000];
  GHAssertTrue([weather isStale], @"Should be stale now");

  weather.date = [NSDate date];
  GHAssertFalse([weather isStale], @"Shouldnt be stale anymore");
}

@end