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

#import <stdio.h>
#import <string.h>
#import <libxml/xmlreader.h>

#import "gpx-api.h"
#import "gpx-reader.h"

void parse_metadata(xmlNode*, GPX*);
void parse_routes(xmlNode*, GPX*);
void parse_tracks(xmlNode*, GPX*);
void parse_path_header(xmlNode*, PathHeader*, NSString*);
Waypoint* parse_waypoint(xmlNode*, NSString*);
NSString* parse_text_node(xmlNode*);
NSURL* parse_url(xmlNode*);
Link* parse_link(xmlNode*);
NSDate* parse_date(xmlNode*);
void print_error_message_for_element(NSString*);

void parse_gpx(xmlNode *node, GPX *gpx)
{
    xmlNode *cur_node = NULL;
    for (cur_node = node; cur_node; cur_node = cur_node->next) {
        if (strcmp((const char*)cur_node->name, "metadata") == 0) {
            parse_metadata(cur_node->children, gpx);
            continue;
        }
        if (strcmp((const char*)cur_node->name, "wpt") == 0) {
            Waypoint *waypoint = parse_waypoint(cur_node, @"");
            if (waypoint != nil) {
                [gpx addWaypoint:waypoint];
            }
        }
        if (strcmp((const char*)cur_node->name, "rte") == 0) {
            parse_routes(cur_node, gpx);
            continue;
        }
        if (strcmp((const char*)cur_node->name, "trk") == 0) {
            parse_tracks(cur_node, gpx);
            continue;
        }

        parse_gpx(cur_node->children, gpx);
    }
}

void parse_metadata(xmlNode *node, GPX *gpx)
{
    xmlNode *cur_node = NULL;
    Metadata *metadata = [[Metadata alloc] init];
    gpx.metadata = metadata;
    for (cur_node = node; cur_node; cur_node = cur_node->next) {
        if (strcasecmp((const char*)cur_node->name, "name") == 0) {
            NSString *name = parse_text_node(cur_node);
            if (name) {
                metadata.name = name;
                [name release];
            } else {
                print_error_message_for_element(@"metadata: name");
            }
        }
        if (strcasecmp((const char*)cur_node->name, "desc") == 0) {
            NSString *desc = parse_text_node(cur_node);
            if (desc) {
                metadata.desc = desc;
                [desc release];
            } else {
                print_error_message_for_element(@"metadata: desc");
            }
        }
        if (strcasecmp((const char*)cur_node->name, "author") == 0) {
            Person *author = [[Person alloc] init];
            for (xmlNode *child = cur_node->children; child; child = child->next) {
                if (strcasecmp((const char*)child->name, "name") == 0) {
                    NSString *name = parse_text_node(child);
                    if (name) {
                        author.name = name;
                        [name release];
                    } else {
                        print_error_message_for_element(@"metadata: author: name");
                    }
                }
                if (strcasecmp((const char*)child->name, "email") == 0) {
                    xmlChar *user = xmlGetProp(child, (xmlChar*)"id");
                    xmlChar *domain = xmlGetProp(child, (xmlChar*)"domain");
                    if (user != NULL && domain != NULL) {
                        Email *email = [[Email alloc] initWithUserAndDomain: [NSString stringWithUTF8String:(const char *)user] :[ NSString stringWithUTF8String:(const char *)domain]];
                        author.email = email;
                        [email release];
                    } else {
                        print_error_message_for_element(@"metadata: author: email");
                    }
                    if (user) {xmlFree(user);} if(domain) {xmlFree(domain);}
                }
                if (strcasecmp((const char*)child->name, "link") == 0) {
                    Link *link = parse_link(child);
                    author.link = link;
                    [link release];
                } else {
                    print_error_message_for_element(@"metadata: author: name");
                }
            }
            metadata.author = author;
            [author release];
        }
        if (strcasecmp((const char*)cur_node->name, "copyright") == 0) {
            xmlChar *author = xmlGetProp(cur_node, (xmlChar*)"author");
            if (author == NULL) {
                print_error_message_for_element(@"metadata: copyright: author");
                continue;
            }
            Copyright *copyright = [[Copyright alloc] initWithValues:[NSString stringWithUTF8String:(const char *)author] :nil :nil];
            metadata.copyright = copyright;
            xmlFree(author);
            for (xmlNode *child = cur_node->children; child; child = child->next) {
                if (strcasecmp((const char*)child->name, "year") == 0) {
                    NSString *year = parse_text_node(child);
                    if (year) {
                        copyright.year = year;
                        [year release];
                    } else {
                        print_error_message_for_element(@"metadata: copyright: year");
                    }
                }
                if (strcasecmp((const char*)child->name, "license") == 0) {
                    NSURL *url = parse_url(child);
                    if (url) {
                        copyright.license = url;
                        [url release];
                    } else {
                        print_error_message_for_element(@"metadata: copyright: license");
                    }
                }
            }
            [copyright release];
        }
        if (strcasecmp((const char*)cur_node->name, "link") == 0) {
            Link *link = parse_link(cur_node);
            if (link) {
                [metadata addLink:link];
                [link release];
            } else {
                print_error_message_for_element(@"metadata: link");
            }
        }
        if (strcasecmp((const char*)cur_node->name, "time") == 0) {
            NSDate *date = parse_date(cur_node);
            if (date) {
                metadata.time = date;
                [date release];
            } else {
                print_error_message_for_element(@"metadata: time");
            }
        }
        if (strcasecmp((const char*)cur_node->name, "keywords") == 0) {
            NSString *keywords = parse_text_node(cur_node);
            if (keywords) {
                metadata.keywords = keywords;
                [keywords release];
            } else {
                print_error_message_for_element(@"metadata: keywords");
            }
        }
        if (strcasecmp((const char*)cur_node->name, "bounds") == 0) {
            xmlChar *minlat = xmlGetProp(cur_node, (xmlChar*)"minlat");
            xmlChar *minlon = xmlGetProp(cur_node, (xmlChar*)"minlon");
            xmlChar *maxlat = xmlGetProp(cur_node, (xmlChar*)"maxlat");
            xmlChar *maxlon = xmlGetProp(cur_node, (xmlChar*)"maxlon");
            if (minlat && minlon && maxlat && maxlon) {
                metadata.bounds = [[Bounds alloc] init];
                metadata.bounds.minlat = [[NSString stringWithUTF8String:(const char *)minlat] doubleValue];
                metadata.bounds.minlon = [[NSString stringWithUTF8String:(const char *)minlon] doubleValue];
                metadata.bounds.maxlat = [[NSString stringWithUTF8String:(const char *)maxlat] doubleValue];
                metadata.bounds.maxlon = [[NSString stringWithUTF8String:(const char *)maxlon] doubleValue];
            } else {
                print_error_message_for_element(@"metadata: bounds");
            }
            if (minlat) xmlFree(minlat); if (minlon) xmlFree(minlon);
            if (maxlat) xmlFree(maxlat); if (maxlon) xmlFree(maxlon);
        }
    }
    [metadata release];
}

void parse_routes(xmlNode *node, GPX *gpx)
{
    Route *route = [[Route alloc] init];
    for (xmlNode *cur_node = node->children; cur_node; cur_node = cur_node->next) {
        if (strcmp((const char*)cur_node->name, "rtept") == 0) {
            Waypoint *waypoint = parse_waypoint(cur_node, @"rte: rtept: ");
            if (waypoint != nil) {
                [route addWaypoint:waypoint];
                [waypoint release];
            } else {
                print_error_message_for_element(@"rte: rtept");
            }
        } else {
            parse_path_header(cur_node, route, @"rte: ");
        }
    }
    [gpx addRoute:route];
    [route release];
}

void parse_tracks(xmlNode *node, GPX *gpx)
{
    Trek *trek = [[Trek alloc] init];
    for (xmlNode *cur_node = node->children; cur_node; cur_node = cur_node->next) {
        if (strcasecmp((const char*)cur_node->name, "trkseg") == 0) {
            TrekSegment *segment = [[TrekSegment alloc] init];
            for (xmlNode *child = cur_node->children; child; child = child->next) {
                if (strcmp((const char*)child->name, "trkpt") == 0) {
                    Waypoint *waypoint = parse_waypoint(child, @"trk: trkseg: ");
                    if (waypoint != nil) {
                        [segment addWaypoint:waypoint];
                        [waypoint release];
                    }
                }
            }
            [trek addTrekseg:segment];
            [segment release];
        } else {
            parse_path_header(cur_node, trek, @"trk: ");
        }
    }
    [gpx addTrek:trek];
    [trek release];
}

void parse_path_header(xmlNode *node, PathHeader *data, NSString *error)
{
    if (strcasecmp((const char*)node->name, "name") == 0) {
        NSString *name = parse_text_node(node);
        if (name) {
            data.name = name;
            [name release];
        } else {
            print_error_message_for_element([error stringByAppendingString:@"name"]);
        }
    }
    if (strcasecmp((const char*)node->name, "cmt") == 0) {
        NSString *cmt = parse_text_node(node);
        if (cmt) {
            data.cmt = cmt;
            [cmt release];
        } else {
            print_error_message_for_element([error stringByAppendingString:@"cmt"]);
        }
    }
    if (strcasecmp((const char*)node->name, "desc") == 0) {
        NSString *desc = parse_text_node(node);
        if (desc) {
            data.desc = desc;
            [desc release];
        } else {
            print_error_message_for_element([error stringByAppendingString:@"desc"]);
        }
    }
    if (strcasecmp((const char*)node->name, "src") == 0) {
        NSString *src = parse_text_node(node);
        if (src) {
            data.src = src;
            [src release];
        } else {
            print_error_message_for_element([error stringByAppendingString:@"src"]);
        }
    }
    if (strcasecmp((const char*)node->name, "link") == 0) {
        Link *link = parse_link(node);
        if (link) {
            [data addLink:link];
            [link release];
        } else {
            print_error_message_for_element([error stringByAppendingString:@"link"]);
        }

    }
    if (strcasecmp((const char*)node->name, "number") == 0) {
        NSString *number = parse_text_node(node);
        if (number) {
            data.number = [number doubleValue];
            [number release];
        } else {
            print_error_message_for_element([error stringByAppendingString:@"number"]);
        }
    }
    if (strcasecmp((const char*)node->name, "type") == 0) {
        NSString *type = parse_text_node(node);
        if (type) {
            data.type = type;
            [type release];
        } else {
            print_error_message_for_element([error stringByAppendingString:@"type"]);
        }
    }
    if (strcasecmp((const char*)node->name, "extension") == 0) {
        // do extension stuff later
    } else {
        print_error_message_for_element([error stringByAppendingString:@"extension"]);
    }
}

Waypoint* parse_waypoint(xmlNode *node, NSString *error)
{
    xmlChar *latstr = xmlGetProp(node, (xmlChar*)"lat");
    xmlChar *lonstr = xmlGetProp(node, (xmlChar*)"lon");
    if (latstr && lonstr) {
        float lat = [[NSString stringWithUTF8String:(const char *)latstr] doubleValue];
        float lon = [[NSString stringWithUTF8String:(const char *)lonstr] doubleValue];
        Waypoint *waypoint = [[Waypoint alloc] initWithValues:lat :lon];
        xmlFree(latstr); xmlFree(lonstr);
        for (xmlNode *child = node->children; child; child = child->next) {
            if (strcasecmp((const char*)child->name, "ele") == 0) {
                NSString *elev = parse_text_node(child);
                if (elev) {
                    float el = [elev doubleValue];
                    waypoint.elev = el;
                    [elev release];
                } else {
                    print_error_message_for_element([error stringByAppendingString:@"elevation"]);
                }
            }
            else if (strcasecmp((const char*)child->name, "time") == 0) {
                NSDate *time = parse_date(child);
                if (time) {
                    waypoint.time = time;
                    [time release];
                } else {
                    print_error_message_for_element([error stringByAppendingString:@"time"]);
                }
            }
            else if (strcasecmp((const char*)child->name, "magvar") == 0) {
                NSString *magvar = parse_text_node(child);
                if ([waypoint setMagvar:[magvar doubleValue]]) {
                } else {
                    print_error_message_for_element([error stringByAppendingString:@"magvar"]);
                }
            }
            else if (strcasecmp((const char*)child->name, "geoidheight") == 0) {
                NSString *geoidheight = parse_text_node(child);
                if (geoidheight) {
                    waypoint.geoidheight = [geoidheight doubleValue];
                } else {
                    print_error_message_for_element([error stringByAppendingString:@"geoidheight"]);
                }
            }
            else if (strcasecmp((const char*)child->name, "sym") == 0) {
                NSString *sym = parse_text_node(child);
                if (sym) {
                    waypoint.sym = sym;
                    [sym release];
                } else {
                    print_error_message_for_element([error stringByAppendingString:@"sym"]);
                }
            }
            else if (strcasecmp((const char*)child->name, "fix") == 0) {
                NSString *fix = parse_text_node(child);
                if ([waypoint setFix:fix]) {
                    [fix release];
                } else {
                    print_error_message_for_element([error stringByAppendingString:@"fix"]);
                }
            }
            else if (strcasecmp((const char*)child->name, "sat") == 0) {
                NSString *sat = parse_text_node(child);
                if (sat) {
                    waypoint.sat = [sat intValue];
                    [sat release];
                } else {
                    print_error_message_for_element([error stringByAppendingString:@"sat"]);
                }
            }
            else if (strcasecmp((const char*)child->name, "hdop") == 0) {
                NSString *hdop = parse_text_node(child);
                if (hdop) {
                    waypoint.sat = [hdop doubleValue];
                    [hdop release];
                } else {
                    print_error_message_for_element([error stringByAppendingString:@"hdop"]);
                }
            }
            else if (strcasecmp((const char*)child->name, "vdop") == 0) {
                NSString *vdop = parse_text_node(child);
                if (vdop) {
                    waypoint.sat = [vdop doubleValue];
                    [vdop release];
                } else {
                    print_error_message_for_element([error stringByAppendingString:@"vdop"]);
                }
            }
            else if (strcasecmp((const char*)child->name, "pdop") == 0) {
                NSString *pdop = parse_text_node(child);
                if (pdop) {
                    waypoint.sat = [pdop doubleValue];
                    [pdop release];
                } else {
                    print_error_message_for_element([error stringByAppendingString:@"pdop"]);
                }
            }
            else if (strcasecmp((const char*)child->name, "ageofdgpsdata") == 0) {
                NSString *ageofdgpsdata = parse_text_node(child);
                if (ageofdgpsdata) {
                    waypoint.ageofdgpsdata = [ageofdgpsdata doubleValue];
                    [ageofdgpsdata release];
                } else {
                    print_error_message_for_element([error stringByAppendingString:@"ageofdgpsdata"]);
                }
            }
            else if (strcasecmp((const char*)child->name, "dgpsid") == 0) {
                NSString *dgpsid = parse_text_node(child);
                if (dgpsid) {
                    waypoint.dgpsid = (unsigned int)[dgpsid intValue];
                    [dgpsid release];
                } else {
                    print_error_message_for_element([error stringByAppendingString:@"dgpsid"]);
                }
            }
            else {
                parse_path_header(child, waypoint, [error stringByAppendingString:@"waypoint: "]);
            }
        }
        return waypoint;
    }
    return nil;
}

NSString* parse_text_node(xmlNode *child)
{
    xmlNode *text = child->children;
    if (text && text->type == XML_TEXT_NODE) {
        xmlChar *content = xmlNodeGetContent(text);
        if (content != NULL) {
            return [[NSString alloc] initWithUTF8String:(const char *)content];
        }
        xmlFree(content);
    }
    return nil;
}

NSURL* parse_url(xmlNode *node)
{
    xmlChar *href = xmlGetProp(node, (xmlChar*)"href");
    if (href == NULL) {
        return nil;
    }
    NSString *url_string = [[NSString alloc] initWithUTF8String:(const char*)href];
    NSURL *url = [[NSURL alloc] initWithString:url_string];
    [url_string release];
    xmlFree(href);
    return url;
}

Link* parse_link(xmlNode *node)
{
    NSURL *url = parse_url(node);
    Link *link = [[Link alloc] initWithHref:url];
    for (xmlNode *child = node->children; child; child = child->next) {
        if (strcasecmp((const char*)child->name, "text") == 0 && child->type == XML_ELEMENT_NODE) {
            NSString *text = parse_text_node(child);
            if (text) {
                link.text = text;
                [text release];
            }
        }
        if (strcasecmp((const char*)child->name, "type") == 0) {
            NSString *type = parse_text_node(child);
            if (type) {
                link.type = type;
                [type release];
            }
        }
    }
    return link;
}

NSDate* parse_date(xmlNode *node)
{
    xmlNode *text = node->children;
    if (text && text->type == XML_TEXT_NODE) {
        xmlChar *content = xmlNodeGetContent(text);
        if (content != NULL) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setTimeStyle:NSDateFormatterFullStyle];
            [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
            NSDate *date = [dateFormat dateFromString:[NSString stringWithUTF8String:(const char *)content]];
            [dateFormat release];
            return date;
        }
        xmlFree(content);
    }
    return nil;
}

void print_error_message_for_element(NSString *error)
{
    NSLog(@"The element: %@, could not be parsed.\n", error);
}
