//
// CocoaWeather -- CWWeather
//
// @author jbenet@cs.stanford.edu
//

@class CLLocation;

typedef enum CWWindDirection {

  CWWindDirectionError,
  CWWindDirectionNorth,
  CWWindDirectionSouth,
  CWWindDirectionWest,
  CWWindDirectionEast,
  CWWindDirectionNorthWest,
  CWWindDirectionNorthEast,
  CWWindDirectionSouthWest,
  CWWindDirectionSouthEast

} CWWindDirection;

@interface CWWeather : NSObject {

  CLLocation *location;
  NSDate *date;

  NSString *condition;
  int conditionCode;

  float celsius;
  float celsiusHigh; // for forecasts
  float celsiusLow; // for forecasts

  // Normalized values.
  float rain;
  float clouds;
  float humidity;
  float visibility;

  float pressure;
  float elevation;

  float windSpeed;
  CWWindDirection windDirection;

}

@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) NSDate *date;

@property (nonatomic, copy) NSString *condition;
@property (nonatomic, assign) int conditionCode;

@property (nonatomic, assign) float celsius;
@property (nonatomic, assign) float celsiusHigh;
@property (nonatomic, assign) float celsiusLow;
@property (nonatomic, readonly) float fahrenheit;

@property (nonatomic, assign) float rain;
@property (nonatomic, assign) float clouds;
@property (nonatomic, assign) float humidity;
@property (nonatomic, assign) float visibility;
@property (nonatomic, assign) float pressure;
@property (nonatomic, assign) float elevation;

@property (nonatomic, assign) float windSpeed;
@property (nonatomic, assign) CWWindDirection windDirection;

- (BOOL) isStale;
- (NSString *)summary;

+ (CWWindDirection) windDirectionFromString:(NSString *)string;
+ (CWWindDirection) windDirectionFromCString:(const char *)string;


+ (const char *) cStringFromWindDirection:(CWWindDirection)dir;
+ (NSString *) stringFromWindDirection:(CWWindDirection)dir;

@end


