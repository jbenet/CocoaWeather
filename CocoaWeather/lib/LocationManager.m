// Copyright (c) 2009 Imageshack Corp.
// All rights reserved.
//
// Modified by jbenet
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products
//    derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "LocationManager.h"

static LocationManager *globalLocationManager = nil;
static BOOL initialized = NO;

@implementation LocationManager

@synthesize location, latitude, longitude, locationDefined;


+ (LocationManager*)locationManager
{
  if (!globalLocationManager)
    globalLocationManager = [[LocationManager allocWithZone:nil] init];
  return globalLocationManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
  @synchronized(self) {
    if (globalLocationManager == nil)
      globalLocationManager = [super allocWithZone:zone];
  }

  return globalLocationManager;
}

- (id)copyWithZone:(NSZone *)zone
{
  return self;
}


- (id)retain
{
  return self;
}

- (unsigned)retainCount
{
  return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
  return self;
}

-(void)reset
{
  locationDefined = NO;
  latitude = 0.f;
  longitude = 0.f;
}

- (id)init
{
  if (initialized)
    return globalLocationManager;

  self = [super init];
  if (!self)
  {
    if (globalLocationManager)
      [globalLocationManager release];
    return nil;
  }

  locationManager = nil;
  location = nil;
  initialized = YES;
  locationDenied = NO;
  [self reset];
  return self;
}

-(void)dealloc
{
  if (locationManager)
    [locationManager release];
  [super dealloc];
}

- (void) stopUpdates
{
  if (locationManager)
    [locationManager stopUpdatingLocation];
  [self reset];
}

- (void) startUpdates
{
  if(![[NSUserDefaults standardUserDefaults] boolForKey:@"UseLocations"]) {
    [self stopUpdates];
    return;
  }

  if (locationManager) {
    [locationManager stopUpdatingLocation];

  } else {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 100;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
  }

  locationDefined = NO;
  [locationManager startUpdatingLocation];
}

- (NSString*) urlFormat
{
  return @"http://maps.google.com/maps?q=%+.6f,%+.6f";
}

- (NSString*) longURLWithLatitude:(float)lat  longitude:(float)lon
{
  return [NSString stringWithFormat:[self urlFormat], lat, lon];
}

- (NSString*) longURL
{
  if (locationDefined)
    return [self longURLWithLatitude:latitude longitude:longitude];
  return nil;
}

- (NSString*) mapURL
{
  if (!locationDefined)
    return nil;

  return tinyURL ? tinyURL : [self longURL];
}


- (void) locationManager:(CLLocationManager *)manager
     didUpdateToLocation:(CLLocation *)newLocation
            fromLocation:(CLLocation *)oldLocation
{
  locationDenied = NO;
  if(![[NSUserDefaults standardUserDefaults] boolForKey:@"UseLocations"]) {
    [self stopUpdates];
    return;
  }

  latitude = newLocation.coordinate.latitude;
  longitude = newLocation.coordinate.longitude;
  self.location = newLocation;
  locationDefined = YES;
}

- (BOOL) locationDenied
{
  return locationDenied;
}

- (BOOL) locationServicesEnabled
{
  CLLocationManager* lm = locationManager;
  if(!lm)
    lm = [[[CLLocationManager alloc] init] autorelease];
  return lm.locationServicesEnabled;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
  [self reset];

    if ([error domain] == kCLErrorDomain)
  {
        switch ([error code])
    {
            case kCLErrorDenied:
        locationDenied = YES;
        [self stopUpdates];
                break;
            case kCLErrorLocationUnknown:
                break;
            default:
                break;
        }
  }

  [[NSNotificationCenter defaultCenter] postNotificationName: @"UpdateLocationNotification" object: nil];
}


@end