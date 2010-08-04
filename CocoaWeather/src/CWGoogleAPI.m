
#import "CWGoogleAPI.h"
#import "CWWeather.h"
#import <CoreLocation/CoreLocation.h>

#define kMPHTOKPH 1.609344f

static NSString *kAPIURL = @"http://www.google.com/ig/api?weather=";

static CWGoogleAPI *google_singleton = nil;

@implementation CWGoogleAPI

- (CWWeather *) weatherForPlace:(NSString *)name
{
  NSString *fix;
  fix = [name stringByReplacingOccurrencesOfString:@" " withString:@"+"];
  return [self weatherForURL:[NSString stringWithFormat:@"%@%@", kAPIURL, fix]];
}

- (CWWeather *) weatherForLocation:(CLLocation *)location
{
  int lat = [self.class googleCoordinateForFloat:location.coordinate.latitude];
  int lon = [self.class googleCoordinateForFloat:location.coordinate.longitude];
  NSString *loc = [NSString stringWithFormat:@",,,%i,%i", lat, lon];
  return [self weatherForURL:[NSString stringWithFormat:@"%@%@", kAPIURL, loc]];
}

- (CWWeather *) weatherForURL:(NSString *)url
{
  CWWeather *weather = [[CWWeather alloc] init];
  weather.date = [NSDate date];

  parsed = weather;
  inCurrentConditions = NO;

  NSURL *url_ = [NSURL URLWithString:url];
  NSXMLParser *par = [[NSXMLParser alloc] initWithContentsOfURL:url_];
  par.delegate = self;
  [par parse];
  [par release];

  parsed = nil;
  return [weather autorelease];
}

+ (int) googleCoordinateForFloat:(float)coord
{
  coord *= 1e6;
  if (coord < 0)
    coord += pow(2, 32);
  return floor(coord);
}

//------------------------------------------------------------------------------
#pragma mark XML Parsing

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
  if ([elementName isEqualToString:@"current_conditions"]) {
    inCurrentConditions = YES;
    NSLog(@"found current conditions");
  }

  if (!inCurrentConditions)
    return;

  if ([elementName isEqualToString:@"condition"])
    parsed.condition = [attributeDict objectForKey:@"data"];

  else if ([elementName isEqualToString:@"temp_c"])
    parsed.celsius = [[attributeDict objectForKey:@"data"] floatValue];

  else if ([elementName isEqualToString:@"humidity"]) {
// NSString *oldHum = [attributeDict objectForKey:@"data"];
// NSMutableString *hum = [NSMutableString stringWithString:oldHum];
// hum = [hum deleteCharactersInRange:NSMakeRange(0,10)];
// parsed.humidity = [[attributeDict objectForKey:@"data"] floatValue] / 100f;
// NSLog(@"Humidity -- '%@' to '%@' got '%f'", oldHum, hum, parsed.humidity);
    const char *hum = [[attributeDict objectForKey:@"data"] UTF8String];
    float humidity;
    sscanf(hum, "Humidity: %f%%", &humidity);
    parsed.humidity = humidity;
    NSLog(@"Humidity: %f", humidity);
  }

  else if ([elementName isEqualToString:@"wind_condition"]) {
    const char *wind = [[attributeDict objectForKey:@"data"] UTF8String];
    float mph;
    char direction[10];
    sscanf(wind, "Wind: %[NWSE] at %f mph", direction, &mph);
    parsed.windDirection = [CWWeather windDirectionFromCString:direction];
    parsed.windSpeed = mph * kMPHTOKPH;
    NSLog(@"Wind Dir: %s %i Spd: %f", direction,
            parsed.windDirection, parsed.windSpeed);
  }

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{

  // Is the current item complete?
  if ([elementName isEqualToString:@"current_conditions"]) {
    inCurrentConditions = NO;
    NSLog(@"ended current conditions");
  }
}

//------------------------------------------------------------------------------

+ (CWGoogleAPI *) singleton
{
  if (google_singleton == nil)
    google_singleton = [[CWGoogleAPI alloc] init];
  return google_singleton;
}

@end
