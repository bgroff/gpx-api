/*
Copyright (c) 2012, Bryce Groff
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met: 

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer. 
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <Foundation/Foundation.h>

#import "gpx-api.h"

#pragma mark Link

@implementation Link
@synthesize href;
@synthesize text;
@synthesize type;
- (id)init
{
    NSAssert(NO, @"You must use the initWithHref to initialize this object");
	return nil;
}

- (id) initWithHref: (NSURL*) inHref :(NSString*)inText :(NSString*)inType {
    self = [super init];
    if(self) {
        NSAssert(href != nil, @"inHref must be initialized before use");
        href = [inHref retain];
        text = [inText retain];
        type = [inType retain];
    }
    return(self);
}

- (void) dealloc
{
    [href release];
    [text release];
    [type release];
    [super dealloc];
}
@end

#pragma mark Email

@implementation Email
@synthesize user;
@synthesize domain;

- (id) init {
	NSAssert(NO, @"You must use the initWithUserAndDomain to initialize this object");
	return nil;
}

- (id) initWithUserAndDomain:(NSString *)inUser :(NSString *)inDomain {
	self = [super init];
    if(self) {
        NSAssert(inUser != nil, @"inUser must be initialized before use");
		NSAssert(inDomain != nil, @"inUser must be initialized before use");
        user = [inUser retain];
        domain = [inDomain retain];
    }
    return(self);
}

- (void) dealloc
{
    [user release];
    [domain release];
    [super dealloc];
}
@end

#pragma mark Person

@implementation Person
@synthesize name;
@synthesize email;
@synthesize link;
@end

#pragma mark Copyright

@implementation Copyright
@synthesize author;
@synthesize year;
@synthesize license;

- (id) init {
	NSAssert(NO, @"You must use the initWithValues to initialize this object");
	return nil;
}

-(id) initWithValues:(NSString *)inAuthor :(NSString *)inYear :(NSURL *)inLicense {
	self = [super init];
    if(self) {
        NSAssert(inAuthor != nil, @"inAuthor must be initialized before use");
		author = [inAuthor retain];
        year = [inYear retain];
		license = [inLicense retain];
    }
    return(self);
}

- (void) dealloc
{
    [author release];
    [year release];
    [license release];
    [super dealloc];
}
@end

#pragma mark Metadata

@implementation Metadata
@synthesize name;
@synthesize desc;
@synthesize author;
@synthesize copyright;
@synthesize link;
@synthesize time;
@synthesize keywords;
@synthesize bounds;

- (id) init {
	self = [super init];
    if(self) {
		link = [[NSMutableArray alloc] init];
    }
    return(self);
}

- (void) addLink:(Link *)newLink {
	[link addObject:newLink];
}
@end

#pragma mark Waypoint

@implementation Waypoint
@synthesize lat;
@synthesize lon;
@synthesize elev;
@synthesize time;
@synthesize geoidheight;
@synthesize name;
@synthesize cmt;
@synthesize desc;
@synthesize src;
@synthesize link;
@synthesize sym;
@synthesize type;
@synthesize sat;
@synthesize hdop;
@synthesize vdop;
@synthesize pdop;
@synthesize ageofdgpsdata;

- (void)setMagvar:(float)inMagvar {
    NSAssert(inMagvar < 0.0 || inMagvar > 360.0, @"The magvar value must be between 0 and 360 degrees");
    magvar = inMagvar;
}

- (void)setFix:(NSString *)inFix {
    BOOL isOption = ([inFix caseInsensitiveCompare:@"none"] || [inFix caseInsensitiveCompare:@"2d"] ||
                     [inFix caseInsensitiveCompare:@"3d"] || [inFix caseInsensitiveCompare:@"dgps"] ||
                     [inFix caseInsensitiveCompare:@"pps"]);
    NSAssert(isOption, @"The fix must be one of the following: {'none'|'2d'|'3d'|'dgps'|'pps'}");
    fix = [inFix retain];
}

- (void)setDgpsid:(unsigned int)inDgpsid {
    NSAssert(inDgpsid <= 1023, @"The dgpsid must be less than 1023");
    dgpsid = inDgpsid;
}

- (id) init {
	NSAssert(NO, @"You must use the initWithValues to initialize this object");
	return nil;
}

- (id) initWithValues:(float)inLat :(float)inLon :(NSDecimal)inElev {
    self = [super init];
    if(self) {
		lat = inLat;
        lon = inLon;
		elev = inElev;
    }
    return(self);
}

- (void) addLink:(Link *)newLink {
	[self.link addObject:newLink];
}
@end


