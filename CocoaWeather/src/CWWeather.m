
#import "CWWeather.h"

#define kSTALENESS_TIME 1800 // in seconds

@implementation CWWeather

@synthesize location, date, condition, conditionCode;
@synthesize celsius, celsiusHigh, celsiusLow;
@synthesize rain, clouds, humidity, visibility, pressure, elevation;
@synthesize windSpeed, windDirection;

- (BOOL) isStale
{
  return ([self.date timeIntervalSinceNow] * -1) > kSTALENESS_TIME;
}

- (NSString *)summary
{
  NSMutableString *out = [NSMutableString stringWithString:@"It's "];
  [out appendFormat:@"%f C, ", self.celsius];
  [out appendFormat:@"%f F,  ", self.fahrenheit];
  [out appendFormat:@"%@ (%i),  ", self.condition, self.conditionCode];
  [out appendFormat:@"wind: %f %i, ", self.windSpeed, self.windDirection];

  return out;
}

+ (CWWindDirection) windDirectionFromString:(NSString *)string
{
  return [self windDirectionFromCString:[string UTF8String]];
}

+ (CWWindDirection) windDirectionFromCString:(const char *)string
{
  BOOL eastish = string[1] == 'E';
  BOOL westish = string[1] == 'W';

  switch (string[0]) {
    case 'N':
      if (eastish)
        return CWWindDirectionNorthEast;
      else if (westish)
        return CWWindDirectionNorthWest;
      return CWWindDirectionNorth;

    case 'S':
      if (eastish)
        return CWWindDirectionSouthEast;
      else if (westish)
        return CWWindDirectionSouthWest;
      return CWWindDirectionSouth;

    case 'W':
      return CWWindDirectionWest;

    case 'E':
      return CWWindDirectionEast;
  }
  return CWWindDirectionError;
}

+ (const char *) cStringFromWindDirection:(CWWindDirection)dir
{
  switch (dir) {
    default: case CWWindDirectionError: return "Error";
    case CWWindDirectionNorth: return "N";
    case CWWindDirectionSouth: return "S";
    case CWWindDirectionWest: return "W";
    case CWWindDirectionEast: return "E";
    case CWWindDirectionNorthWest: return "NW";
    case CWWindDirectionNorthEast: return "NE";
    case CWWindDirectionSouthWest: return "SW";
    case CWWindDirectionSouthEast: return "SE";
  }
  return "Error";
}

+ (NSString *) stringFromWindDirection:(CWWindDirection)dir
{
  return [NSString stringWithUTF8String:[self cStringFromWindDirection:dir]];
}

- (float) fahrenheit
{
  return self.celsius * (9.0f / 5.0f) + 32;
}

- (void) dealloc
{
  self.date = nil;
  self.location = nil;
  self.condition = nil;
  [super dealloc];
}

@end
