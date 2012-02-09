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

- (id) initWithHref: (NSURL*) inHref {
    self = [super init];
    if(self) {
        NSAssert(href == nil, @"inHref must be initialized before use");
        href = [inHref retain];
    }
    return(self);
}

- (void) dumpLink {
    NSLog(@"Link: href: %@\n", href);
    if (text) {
        NSLog(@"\ttext: %@\n", text);
    }
    if (type) {
        NSLog(@"\ttype: %@\n", type);
    }
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

- (void) dumpEmail {
    NSLog(@"%@@%@\n", user, domain);
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

- (void) dumpAuthor {
    if (name) {NSLog(@"name: %@\n", name);}
    if (email) {[email dumpEmail];}
    if (link) {[link dumpLink];}
}

- (void) dealloc {
    [name release];
    [email release];
    [link release];
    [super dealloc];
}
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

- (void) dumpCopyright {
    NSLog(@"author: %@\n", author);
    if (year) {NSLog(@"year: %@\n", year);}
    if (license) {NSLog(@"license: %@\n", license);}
}

- (void) dealloc
{
    [author release];
    [year release];
    [license release];
    [super dealloc];
}
@end

#pragma mark Bounds

@implementation Bounds
@synthesize minlat;
@synthesize minlon;
@synthesize maxlat;
@synthesize maxlon;
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

- (void) addLink:(Link *)newLink {
    if (link == nil) {
        link = [[NSMutableArray alloc] init];
    }
	[link addObject:newLink];
}

- (void) dumpMetadata {
    NSLog(@"Metadata:\n");
    if (name) {NSLog(@"name: %@\n", name);}
    if (desc) {NSLog(@"description: %@\n", desc);}
    if (author) {[author dumpAuthor];}
    if (copyright) {[copyright dumpCopyright];}
    if (link) {
        for (NSUInteger i = 0; i < link.count; i++) {
            Link *l = [link objectAtIndex:i];
            [l dumpLink];
        }
    }
    if (time) {NSLog(@"time: %@\n", time);}
    if (keywords) {NSLog(@"keywords: %@\n", keywords);}
    if (bounds) {NSLog(@"minlat: %f, minlon: %f, maxlat: %f, maxlon: %f\n", bounds.minlat, bounds.minlon, bounds.maxlat, bounds.maxlon);}
}

- (void) dealloc {
    [name release];
    [desc release];
    [author release];
    [copyright release];
    [link release];
    [time release];
    [keywords release];
    [bounds release];
    [super dealloc];
}
@end

#pragma mark PathHeader

@implementation PathHeader
@synthesize name;
@synthesize cmt;
@synthesize desc;
@synthesize src;
@synthesize link;
@synthesize number;
@synthesize type;
- (void)addLink:(Link *)newLink {
    if (link == nil) {
        link = [[NSMutableArray alloc] init];
    }
    [link addObject:newLink];
}
- (void) dumpPathHeader {
    if (name) {NSLog(@"name: %@\n", name);}
    if (cmt) {NSLog(@"comment: %@\n", cmt);}
    if (desc) {NSLog(@"description: %@\n", desc);}
    if (src) {NSLog(@"source: %@\n", src);}
    if (link) {for(Link *l in link) {[l dumpLink];}}
    if (number) {NSLog(@"number: %i\n", number);}
    if (type) {NSLog(@"type: %@\n", type);} 
}
- (void) dealloc {
    [name release];
    [cmt release];
    [desc release];
    [src release];
    [link release];
    [type release];
}
@end

#pragma mark Waypoint

@implementation Waypoint
@synthesize lat;
@synthesize lon;
@synthesize elev;
@synthesize time;
@synthesize geoidheight;
@synthesize sym;
@synthesize sat;
@synthesize hdop;
@synthesize vdop;
@synthesize pdop;
@synthesize ageofdgpsdata;

- (BOOL)setMagvar:(float)inMagvar {
    if (inMagvar >= 0.0 && inMagvar <= 360.0) {
        magvar = inMagvar;
        return YES;
    }
    return NO;
}

- (float) getMagvar {
    return magvar;
}

- (BOOL)setFix:(NSString *)inFix {
    BOOL isOption = ([inFix caseInsensitiveCompare:@"none"] || [inFix caseInsensitiveCompare:@"2d"] ||
                     [inFix caseInsensitiveCompare:@"3d"] || [inFix caseInsensitiveCompare:@"dgps"] ||
                     [inFix caseInsensitiveCompare:@"pps"]);
    if (isOption) {
        NSLog(@"Fix must be one of the following: none, 2d, 3d, dgps, pps");
        return NO;
    }
    fix = [inFix retain];
    return YES;
}

- (NSString*) getFix {
    return fix;
}

- (BOOL)setDgpsid:(unsigned int)inDgpsid {
    if (inDgpsid <= 1023) {
        NSLog(@"The dgpsid must be less than 1023");
        return NO;
    }
    dgpsid = inDgpsid;
    return YES;
}

- (unsigned int) getDgpsid {
    return dgpsid;
}

- (id) init {
	NSAssert(NO, @"You must use the initWithValues to initialize this object");
	return nil;
}

- (id) initWithValues:(float)inLat :(float)inLon {
    self = [super init];
    if(self) {
		lat = inLat;
        lon = inLon;
    }
    return(self);
}

- (void) dumpWaypoint {
    NSLog(@"Waypoint: lat: %f, lon: %f\n", lat, lon);
    if (elev) {NSLog(@"\tElevation: %f\n", elev);}
    if (time) {NSLog(@"\tTime: %@\n", time);}
    [super dumpPathHeader];
    if (magvar) {NSLog(@"\tMagvar: %f\n", magvar);}
    if (sym) {NSLog(@"\tSymbol: %@\n", sym);}
    if (fix) {NSLog(@"\tfix: %@\n", fix);}
    if (dgpsid) {NSLog(@"\tStationID: %i\n", dgpsid);}
}

- (void) dealloc {
    [time release];
    [sym release];
    [super dealloc];
}
@end

#pragma mark Route

@implementation Route
@synthesize rtept;

- (void)addWaypoint:(Waypoint *)waypoint {
    if (rtept == nil) {
        rtept = [[NSMutableArray alloc] init];
    }
    [rtept addObject:waypoint];
}

- (void) dumpRoute {
    NSLog(@"Route:\n");
    [super dumpPathHeader];
    if (rtept) {for(Waypoint *p in rtept){[p dumpWaypoint];}}
}

- (void) dealloc {
    [rtept release];
    [super dealloc];
}
@end

#pragma mark TrekSegment

@implementation TrekSegment
@synthesize trekpoints;

- (void)addWaypoint:(Waypoint *)waypoint {
    if (trekpoints == nil) {
        trekpoints = [[NSMutableArray alloc] init];
    }
    [trekpoints addObject:waypoint];
}

- (void) dumpTrekSegment {
    NSLog(@"Trek Segment\n");
    if (trekpoints) {for(Waypoint *p in trekpoints){[p dumpWaypoint];}}
}

- (void) dealloc {
    [trekpoints release];
    [super dealloc];
}
@end

#pragma mark Trek

@implementation Trek
@synthesize trekseg;

- (void)addTrekseg:(TrekSegment *)segment {
    if (trekseg == nil) {
        trekseg = [[NSMutableArray alloc] init];
    }
    [trekseg addObject:segment];
}

- (void) dumpTrek {
    NSLog(@"Trek:\n");
    [super dumpPathHeader];
    if (trekseg) {for(TrekSegment *s in trekseg){[s dumpTrekSegment];}}
}

- (void) dealloc {
    [trekseg release];
    [super dealloc];
}
@end

#pragma mark GPX

@implementation GPX
@synthesize metadata;
@synthesize waypoints;
@synthesize routes;
@synthesize treks;

- (id) init {
    self = [super init];
    if(self) {
        version = [[NSString alloc] initWithString:@"1.1"];
        creator = [[NSString alloc] initWithString:@"gpx-api version 1.0"];
    }
    return(self);
}

- (void) addWaypoint:(Waypoint *)waypoint {
    if (waypoints == nil) {
        waypoints = [[NSMutableArray alloc] init];
    }
    [waypoints addObject:waypoint];
}

- (void) addRoute:(Route *)route {
    if (routes == nil) {
        routes = [[NSMutableArray alloc] init];
    }
    [routes addObject:route];
}

- (void) addTrek:(Trek *)trek {
    if (treks == nil) {
        treks = [[NSMutableArray alloc] init];
    }
    [treks addObject:trek];
}

- (void) dumpGPX {
    if (metadata) {
        [metadata dumpMetadata];
    }
    if (waypoints) {
        for (Waypoint *waypoint in waypoints) {
            [waypoint dumpWaypoint];
        }
    }
    if (routes) {
        for (Route *route in routes) {
            [route dumpRoute];
        }
    }
    if (treks) {
        for (Trek *trek in treks) {
            [trek dumpTrek];
        }
    }
}

- (void) dealloc {
    [version release];
    [creator release];
    [metadata release];
    [waypoints release];
    [routes release];
    [treks release];
    [super dealloc];
}
@end
