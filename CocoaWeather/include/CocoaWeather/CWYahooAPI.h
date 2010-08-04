
#import "CWAPI.h"
#import <CoreLocation/CoreLocation.h>

@interface CWYahooAPI : CWAPI {

}

- (float) floatForKey:(NSString *)key inDict:(NSDictionary *)dict;

+ (int) WOEIDForCoordinate:(CLLocationCoordinate2D)coordinate;
+ (int) WOEIDForLocation:(CLLocation *)location;
+ (CWYahooAPI *) singleton;

@end
