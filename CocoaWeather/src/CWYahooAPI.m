
#import "CWYahooAPI.h"
#import "CWWeather.h"
#import <YAJLIPhone/YAJL.h>
#import <CoreLocation/CoreLocation.h>

static NSString *kAPI = @"http://weather.yahooapis.com/forecastjson?u=c&";

static NSString *kWOEID_LATLON_API = @"http://query.yahooapis.com/v1/public/yql?format=json&q=select%%20*%%20from%%20flickr.places%%20where%%20lat%%3D%f%%20and%%20lon%%3D%f";

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
  dict = [[dict valueForKey:@"query"] valueForKey:@"results"];
  dict = [[dict valueForKey:@"places"] valueForKey:@"place"];
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
