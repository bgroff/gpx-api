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


#pragma mark Link

@interface Link : NSObject {
    NSURL    *href;
    NSString *text;
    NSString *type;
}

@property (retain) NSURL* href;
@property (retain) NSString* text;
@property (retain) NSString* type;

- (id) initWithHref: (NSURL*) href :(NSString*)inText :(NSString*)inType;
@end

#pragma mark Email

@interface Email : NSObject {
    NSString *user;
    NSString *domain;
}

@property (retain) NSString* user;
@property (retain) NSString* domain;

- (id) initWithUserAndDomain: (NSString*)inUser :(NSString*)inDomain;
@end

#pragma mark Person

@interface Person : NSObject {
    NSString *name;
    Email    *email;
    Link     *link;
}
@property (retain) NSString* name;
@property (retain) Email* email;
@property (retain) Link* link;
@end

#pragma mark Copyright

@interface Copyright : NSObject {
    NSString *author;
    NSString *year;
    NSURL    *license;
}
@property (retain) NSString* author;
@property (retain) NSString* year;
@property (retain) NSURL* license;

- (id) initWithValues: (NSString*)inAuthor :(NSString*)inYear :(NSURL*)inLicense;
@end

#pragma mark Bounds

@interface Bounds : NSObject {
    float minlat;
    float minlon;
    float maxlat;
    float maxlon;
}
@end

#pragma mark Metadata

@interface Metadata : NSObject {
    NSString		*name;
    NSString		*desc;
    Person			*author;
    Copyright		*copyright;
    NSMutableArray	*link;
    NSDate			*time;
    NSString		*keywords;
	Bounds			*bounds;
    // extension
}
@property (retain) NSString* name;
@property (retain) NSString* desc;
@property (retain) Person* author;
@property (retain) Copyright* copyright;
@property (retain) NSDate* time;
@property (retain) NSString* keywords;
@property (retain) Bounds* bounds;

- (void)addLink: (Link*)link;
@end

@interface Waypoint : NSObject {
    float          lat;
    float          lon;
    NSDecimal      *elev;
    NSDate         *time;
    float          magvar;
    NSDecimal      *geoidheight;
    NSString       *name;
    NSString       *cmt;
    NSString       *desc;
    NSString       *src;
    NSMutableArray *link;
    NSString       *sym;
    NSString       *type;
    NSString       *fix; // Must be one of: {'none'|'2d'|'3d'|'dgps'|'pps'}
    unsigned int   sat;
    NSDecimal      *hdop;
    NSDecimal      *vdop;
    NSDecimal      *pdop;
    NSDecimal      *ageofdgpsdata;
    unsigned int   dgpsid;
    // extensions;
}
@end

@interface Route {
    NSString       *name;
    NSString       *cmt;
    NSString       *desc;
    NSString       *src;
    NSMutableArray *link;
    unsigned int   number;
    NSString       *type;
    // extensions
    NSMutableArray *rtept;
}
@end

@interface Trek {
    NSString       *name;
    NSString       *cmt;
    NSString       *desc;
    NSString       *src;
    NSMutableArray *link;
    unsigned int   number;
    NSString       *type;
    // extensions
    NSMutableArray *trkseg;
}
- (void)addWaypoint:(Waypoint *)waypoint;
@end


