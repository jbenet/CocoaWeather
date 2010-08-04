//
// CocoaWeather -- CWAPI
//
// @author jbenet@cs.stanford.edu
//

@class CLLocation;
@class CWWeather;

@interface CWAPI : NSObject {

  BOOL useSQLiteCaching;
  NSTimeInterval cacheTime;

}

@property (nonatomic, readonly) NSString *url;
@property (nonatomic, readonly) NSString *name;

@property (nonatomic, assign) BOOL useSQLiteCaching;
@property (nonatomic, assign) NSTimeInterval cacheTime;

+ (BOOL) useSQLiteCaching;
+ (void) setUseSQLiteCaching:(BOOL)caching;
+ (NSTimeInterval) cacheTime;
+ (void) setCacheTime:(NSTimeInterval)time;

+ (CWWeather *) weatherForPlace:(NSString *)name;
+ (CWWeather *) weatherForLocation:(CLLocation *)location;
+ (CWWeather *) weatherForCurrentLocation;
+ (CWWeather *) weatherForURL:(NSString *)url;

- (CWWeather *) weatherForPlace:(NSString *)name;
- (CWWeather *) weatherForLocation:(CLLocation *)location;
- (CWWeather *) weatherForCurrentLocation;
- (CWWeather *) weatherForURL:(NSString *)url;

+ (CWAPI *) singleton;
+ (void) setSingleton:(CWAPI *)cwapi;
+ (void) setAsSingleton;

@end


