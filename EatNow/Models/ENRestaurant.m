//
// Person.m
//
// Copyright (c) 2014 to present, Brian Gesiak @modocache
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ENRestaurant.h"
#import "ENServerManager.h"
#import "TFHpple.h"
#import "ENUtil.h"
#import "ENLocationManager.h"
#import "ENMapManager.h"
#import "TFHppleElement.h"
#import "extobjc.h"
#import "NSDate+MTDates.h"
@import AddressBook;

@implementation ENRestaurant
//ZITAO: change to initRestaurantWithDictionary, the param is not s NSData?
- (instancetype)initRestaurantWithDictionary:(NSDictionary *)json{
	self = [super init];
    if (!self) return nil;
    
	NSParameterAssert([json isKindOfClass:[NSDictionary class]]);
    //data
	self.json = json;
    self.ID = json[@"_id"];
	self.url = json[@"url"];
	self.rating = (NSNumber *)json[@"rating"];
    NSString *colorStr = json[@"ratingColor"];
    UIColor *ratingColor = [ENRestaurant colorFromHexString:colorStr];
    if (ratingColor) self.ratingColor = ratingColor;
	self.reviews = (NSNumber *)json[@"ratingSignals"];
	NSArray *list = json[@"categories"];
    self.cuisines = [list valueForKey:@"shortName"];
	if (self.cuisines.firstObject == [NSNull null]) self.cuisines = [list valueForKey:@"global"];
    //self.images = [NSMutableArray array];
	self.imageUrls = json[@"food_image_url"];
	self.phone = [json valueForKeyPath:@"contact.formattedPhone"];
	self.name = json[@"name"];
	self.price = json[@"price"];
	self.openInfo = [json valueForKeyPath:@"hours.status"];
	self.tips	= [json valueForKeyPath:@"stats.tipCount"];
	//location
	NSDictionary *address = json[@"location"];
	CLLocationDegrees lat = [(NSNumber *)address[@"lat"] doubleValue];
	CLLocationDegrees lon = [(NSNumber *)address[@"lng"] doubleValue];
	CLLocation *loc = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
	self.location = loc;
    self.distance = (NSNumber *)address[@"distance"];
    if (!_distance) {
        float d = [loc distanceFromLocation:[ENLocationManager cachedCurrentLocation]];
        self.distance = @(d);
    }
    self.walkDuration = NSTimeIntervalSince1970;
    self.venderUrl = json[@"vendorUrl"];
	//score
	NSDictionary *scores = json[@"score"];
	if (scores) {
		NSNumber *totalScore = scores[@"total_score"];
//		NSParameterAssert(![totalScore isEqual:[NSNull null]]);
        if ([totalScore isEqual:(id)[NSNull null]]) {
            totalScore = @0;
        }
		self.score = totalScore;
	}
    
    @try{
        self.mobileMenuURL = json[@"menu"][@"mobileUrl"];
    }
    @catch (NSException *err){
        DDLogVerbose(@"Failed to parse menu: %@", err);
    }
    
	if (![self validate]) {
		return nil;
	}
	return self;
}


//update images
//- (void)setImageUrls:(NSArray *)imageUrls{
//    NSParameterAssert(_images);
//    if (!_imageUrls) {
//        _imageUrls = imageUrls;
//        return;
//    }
//    NSMutableArray *newImages = [NSMutableArray arrayWithCapacity:imageUrls.count];
//    while (newImages.count < imageUrls.count) {
//        [newImages addObject:[NSNull null]];
//    }
//    for (NSUInteger i = 0; i < imageUrls.count; i++) {
//        NSString *url = imageUrls[i];
//        NSUInteger j = [_imageUrls indexOfObject:url];
//        if (j == NSNotFound) continue;
//        if (_images.count > j && _images[j]) {
//            newImages[i] = _images[j];
//        }
//    }
//    _imageUrls = imageUrls;
//    _images = newImages;
//}

- (NSString *)twitter{
    return [_json valueForKeyPath:@"twitter.twitter"];
}

- (NSString *)facebook{
    return [_json valueForKeyPath:@"twitter.facebook"];
}

- (NSString *)phoneNumber{
    return [_json valueForKeyPath:@"contact.phone"];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"Restaurant: %@, rating: %.1ld, tips: %ld, cuisine: %@, price： %@, distance: %.1fkm \n", _name, (long)self.tips.integerValue, (long)_reviews.integerValue, [self cuisineText], [self pricesText], [self.distance floatValue]/1000];
	
}

#pragma mark - Convienence method
- (NSString *)pricesText{
    NSMutableString *priceString = [NSMutableString string];
	NSString *currencySign = self.price[@"currency"];
	NSNumber *tier = self.price[@"tier"];
    for (NSUInteger i=0; i<tier.integerValue; i++) {
        [priceString appendString:currencySign];
    }
    return priceString.copy;
}

- (NSString *)cuisineText{
    NSMutableString *string = [NSMutableString stringWithString:@""];
    for (NSString *key in self.cuisines) {
        [string appendFormat:@"%@, ", key];
    }
    return [string substringToIndex:string.length-2];
}

- (NSString *)foursquareID{
    return [_json valueForKey:@"id"];
}

- (NSString *)scoreComponentsText{
	NSMutableString *scores = [NSMutableString new];
	[scores appendFormat:@"Rate:%ld ", (long)[(NSNumber *)[_json valueForKeyPath:@"score.rating_score"] integerValue]];
	[scores appendFormat:@"Food:%ld ", (long)[(NSNumber *)[_json valueForKeyPath:@"score.cuisine_score"] integerValue]];
	[scores appendFormat:@"Dist:%ld ", (long)[(NSNumber *)[_json valueForKeyPath:@"score.distance_score"] integerValue]];
	[scores appendFormat:@"Tips:%ld ", (long)[(NSNumber *)[_json valueForKeyPath:@"score.comment_score"] integerValue]];
	[scores appendFormat:@"Price:%ld ", (long)[(NSNumber *)[_json valueForKeyPath:@"score.price_score"] integerValue]];
	[scores appendFormat:@"Time:%ld", (long)[(NSNumber *)[_json valueForKeyPath:@"score.time_score"] integerValue]];
	
	return scores.copy;
}

- (MKPlacemark *)placemark{
    NSDictionary *address = self.json[@"location"];
    if (address && self.location) {
        NSDictionary *addressDict = @{
                                      (__bridge NSString *) kABPersonAddressStreetKey : address[@"address"]?:@"",
                                      (__bridge NSString *) kABPersonAddressCityKey : address[@"city"]?:@"",
                                      (__bridge NSString *) kABPersonAddressStateKey : address[@"state"]?:@"",
                                      (__bridge NSString *) kABPersonAddressZIPKey : address[@"postalCode"]?:@"",
                                      (__bridge NSString *) kABPersonAddressCountryKey : address[@"country"]?:@"",
                                      (__bridge NSString *) kABPersonAddressCountryCodeKey : address[@"cc"]?:@""
                                      };
        CLLocation *loc = self.location;
        return [[MKPlacemark alloc] initWithCoordinate:loc.coordinate addressDictionary:addressDict];
    }
    return nil;
}

- (NSString *)streetText{
    NSDictionary *address = self.json[@"location"];
    return address[@"address"]?:@"";
}

/**
 *  Distance string in "1.2 km/mi" format
 *
 *  @return distance string
 */
- (NSString *)distanceStr{
    
    float distance = self.distance.floatValue/1000;
    NSNumber *metric = [[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem];
    if (!metric.boolValue) {
        distance *= 0.621371;
    }
    NSString *unit = metric.boolValue ? @"km" : (distance > 1 ? @"miles" : @"mile");
    return [NSString stringWithFormat:@"%.1f %@", distance, unit];
}

#pragma mark - Tools
- (void)parseFoursquareWebsiteForImagesWithUrl:(NSString *)urlString completion:(void (^)(NSArray *imageUrls, NSError *error))block{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/photos", urlString]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    @weakify(self);
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        NSData *data = responseObject;
        TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:data];
        NSArray * elements  = [doc searchWithXPathQuery:@"//div[@class='wrap photosBlock']/div[@class='photo']/span/img"];
        NSMutableArray *images = [NSMutableArray array];
        for (TFHppleElement *element in elements) {
            NSString *imgUrl = [element objectForKey:@"src"];
            if (imgUrl) {
                if ([imgUrl containsString:@"4sqi"]) {
                    NSMutableArray *urlComponents = [imgUrl componentsSeparatedByString:@"/"].mutableCopy;
                    NSString *sizeStr = urlComponents[urlComponents.count-2];
                    NSUInteger l = sizeStr.length;
                    if ([sizeStr characterAtIndex:(l-1)/2] == 'x') {
                        urlComponents[urlComponents.count-2] = @"original";
                        imgUrl = [urlComponents componentsJoinedByString:@"/"];
                        //
                        [images addObject:imgUrl];
                    }
                }
                else {
                    DDLogError(@"Parse failed: %@", imgUrl);
                }
            }
        }
        DDLogInfo(@"Parsed %@ images from vendor", @(images.count));
        
        self.imageUrls = images;
        
        block(images, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"Failed to download website %@", urlString);
        block(nil, error);
    }];;
    [op start];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    if (!hexString) {
        return nil;
    }
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    //[scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (BOOL)validate{
    BOOL good = YES;
	if (!_json) {
		DDLogError(@"Missing json data %@", self);
		return NO;
	}
    if (!_ID) {
        DDLogError(@"Restaurant missing ID %@", self);
        good = NO;
    }
    if (!_name) {
        DDLogError(@"Restaurant missing name %@", self);
        good = NO;
    }
    if (!_imageUrls || _imageUrls.count == 0) {
        DDLogError(@"Restaurant missing image %@", self);
        good = NO;
    }
    if (!_cuisines || _cuisines.firstObject == (id)[NSNull null]) {
        DDLogError(@"Restaurant missing cuisine %@", self);
        good = NO;
    }
    if (!_rating) {
        DDLogError(@"Restaurant missing rating %@", self);
        good = NO;
    }
    if (!_price) {
        DDLogError(@"Restaurant missing price %@", self);
		//good = NO;
    }
    if (!_location) {
        DDLogWarn(@"Restaurant missing location %@", self);
    }
    
    return good;
}
@end
