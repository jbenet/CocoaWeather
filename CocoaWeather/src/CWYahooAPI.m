
#import "CWYahooAPI.h"
#import "CWWeather.h"
#import <YAJL/YAJL.h>
#import <CoreLocation/CoreLocation.h>

static NSString *kAPI = @"http://weather.yahooapis.com/forecastjson?u=c&";

static NSString *kWOEID_LATLON_API =
  @"http://where.yahooapis.com/geocode?q=%f,%f&flags=J&gflags=R";


static CWYahooAPI *yahoo_singleton = nil;

@implementation CWYahooAPI

- (float) floatForKey:(NSString *)key inDict:(NSDictionary *)dict
{
  if ([[dict objectForKey:key] respondsToSelector:@selector(floatValue)])
    return [[dict objectForKey:key] floatValue];
  return FLT_MIN;
}

- (CWWeather *) weatherForPlace:(NSString *)name
{
  return [self weatherForURL:[NSString stringWithFormat:@"%@q=%@", kAPI, name]];
}

- (CWWeather *) weatherForLocation:(CLLocation *)location
{
  int wid = [CWYahooAPI WOEIDForCoordinate:location.coordinate];
  NSLog(@"WOEID: %i", wid);
  if (wid == 0)
    return nil;

  return [self weatherForURL:[NSString stringWithFormat:@"%@w=%i", kAPI, wid]];
}

- (CWWeather *) weatherForURL:(NSString *)url
{
  NSString *res = [NSString stringWithContentsOfURL:[NSURL URLWithString:url]
                            encoding:NSUTF8StringEncoding error:NULL  ];
  NSDictionary *dict = [res yajl_JSON];


  NSDictionary *location = [dict objectForKey:@"location"];
  NSDictionary *wind = [dict objectForKey:@"wind"];
  NSDictionary *atmosphere = [dict objectForKey:@"atmosphere"];
  NSDictionary *condition = [dict objectForKey:@"condition"];

  CWWeather *weather = [[CWWeather alloc] init];
  weather.date = [NSDate date];
  weather.condition = [condition objectForKey:@"text"];
  weather.conditionCode = [[condition objectForKey:@"code"] intValue];

  weather.celsius = [self floatForKey:@"temperature" inDict:condition];

  weather.humidity = [self floatForKey:@"humidity" inDict:atmosphere];
  weather.visibility = [self floatForKey:@"visibility" inDict:atmosphere];
  weather.pressure = [self floatForKey:@"pressure" inDict:atmosphere];

  weather.elevation = [self floatForKey:@"elevation" inDict:location];

  weather.windSpeed = [self floatForKey:@"speed" inDict:wind];
//  weather.windDirection = //broken...

  return [weather autorelease];
}

//------------------------------------------------------------------------------

+ (int) WOEIDForCoordinate:(CLLocationCoordinate2D)coordinate
{
  NSString *url = [NSString stringWithFormat:kWOEID_LATLON_API,
                    coordinate.latitude, coordinate.longitude];
  NSString *res = [NSString stringWithContentsOfURL:[NSURL URLWithString:url]
                            encoding:NSUTF8StringEncoding error:NULL];

  NSDictionary *dict = [res yajl_JSON];
  if (!dict || ![dict isKindOfClass:[NSDictionary class]])
    return 0;

  dict = [dict valueForKey:@"ResultSet"];
  if (!dict || ![dict isKindOfClass:[NSDictionary class]])
    return 0;

  NSArray *array = [dict valueForKey:@"Results"];
  if (!array || ![array isKindOfClass:[NSArray class]] || [array count] < 1)
    return 0;

  dict = [array objectAtIndex:0];
  if (!dict || ![dict isKindOfClass:[NSDictionary class]])
    return 0;

  id woeid = [dict valueForKey:@"woeid"];
  if ([woeid isKindOfClass:[NSNumber class]])
    return [woeid intValue];
  else if ([woeid isKindOfClass:[NSString class]])
    return [woeid intValue];
  return 0;
}

+ (int) WOEIDForLocation:(CLLocation *)location
{
  return [self WOEIDForCoordinate:location.coordinate];
}

//------------------------------------------------------------------------------

+ (CWYahooAPI *) singleton
{
  if (yahoo_singleton == nil)
    yahoo_singleton = [[CWYahooAPI alloc] init];
  return yahoo_singleton;
}


@end
