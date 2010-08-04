
#import "CWAPI.h"
#import <Foundation/Foundation.h>

@interface CWGoogleAPI : CWAPI {

  CWWeather *parsed;
  BOOL inCurrentConditions;
}

+ (int) googleCoordinateForFloat:(float)coord;
+ (CWGoogleAPI *) singleton;

@end
