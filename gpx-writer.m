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

#import <libxml/encoding.h>
#import <libxml/xmlwriter.h>

#import "gpx-api.h"
#import "gpx-writer.h"

#define ENCODING "UTF-8"

void write_metadata(GPX *gpx, xmlTextWriterPtr writer);
void write_waypoints(GPX *gpx, xmlTextWriterPtr writer);
void write_routes(GPX *gpx, xmlTextWriterPtr writer);
void write_tracks(GPX *gpx, xmlTextWriterPtr writer);
void write_path_header(PathHeader* header, xmlTextWriterPtr writer);
void write_waypoint(Waypoint* waypoint, xmlTextWriterPtr writer, NSString *tag);
void write_links(NSMutableArray *links, xmlTextWriterPtr writer);
void write_time(NSDate *time, xmlTextWriterPtr writer);

NSString* write_gpx_to_string(GPX *gpx)
{
    xmlBufferPtr buffer = write_gpx(gpx);
    if (!buffer) {
        return NO;
    }

    NSString *ret_str = [[NSString alloc] initWithUTF8String:(char*)buffer->content];
    if (ret_str) {
        return ret_str;
    }
    return nil;
}

BOOL write_gpx_to_file(GPX *gpx, NSString *file)
{
    xmlBufferPtr buffer = write_gpx(gpx);
    if (!buffer) {
        return NO;
    }

    FILE *fp ;
    fp = fopen([file UTF8String], "w");
    if (fp) {
        int ret = xmlBufferDump(fp, buffer);
        if (ret < 0) {
            return NO;
        }
    } else {
        return NO;
    }
    xmlBufferFree(buffer);
    fclose(fp);
    return YES;
}

xmlBufferPtr write_gpx(GPX *gpx)
{
    if (!gpx) {
        return nil;
    }
    xmlBufferPtr buffer = xmlBufferCreate();
    if (buffer == NULL) {
        NSLog(@"Error creating the xml buffer\n");
        return nil;
    }
    xmlTextWriterPtr writer = xmlNewTextWriterMemory(buffer, 0);
    if (writer == NULL) {
        NSLog(@"Error creating the xml writer\n");
        return nil;
    }
    int ret_code = xmlTextWriterStartDocument(writer, NULL, ENCODING, NULL);
    if (ret_code < 0) {
        NSLog(@"Error at xmlTextWriterStartDocument\n");
        return nil;
    }
    ret_code = xmlTextWriterStartElement(writer, BAD_CAST "gpx");
    if (ret_code < 0) {
        NSLog(@"Error at xmlTextWriterStartElement\n");
        return nil;
    }
    xmlTextWriterWriteAttribute(writer, BAD_CAST "version", BAD_CAST "1.1");
    xmlTextWriterWriteAttribute(writer, BAD_CAST "creator", BAD_CAST "GPX-API");
    xmlTextWriterWriteAttribute(writer, BAD_CAST "xmlns", BAD_CAST "http://www.topografix.com/GPX/1/1");
    xmlTextWriterWriteAttribute(writer, BAD_CAST "xmlns:xsi", BAD_CAST "http://www.w3.org/2001/XMLSchema-instance");
    xmlTextWriterWriteAttribute(writer, BAD_CAST "xsi:schemaLocation", BAD_CAST "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd");
    
    write_metadata(gpx, writer);
    write_waypoints(gpx, writer);
    write_routes(gpx, writer);
    write_tracks(gpx, writer);
    
    xmlTextWriterEndElement(writer);
    xmlTextWriterEndDocument(writer);
    return buffer;
}

void write_metadata(GPX *gpx, xmlTextWriterPtr writer)
{
    Metadata *metadata = gpx.metadata;
    if (metadata) {
        xmlTextWriterStartElement(writer, BAD_CAST "metadata");
        
        if (metadata.name) {
            xmlTextWriterWriteElement(writer, BAD_CAST "name", BAD_CAST [metadata.name UTF8String]);
        }
        if (metadata.desc) {
            xmlTextWriterWriteElement(writer, BAD_CAST "desc", BAD_CAST [metadata.desc UTF8String]);
        }
        if (metadata.author) {
            xmlTextWriterStartElement(writer, BAD_CAST "author");
            xmlTextWriterWriteElement(writer, BAD_CAST "name", BAD_CAST [metadata.author.name UTF8String]);
            if (metadata.author.email) {
                xmlTextWriterStartElement(writer, BAD_CAST "email");
                xmlTextWriterWriteAttribute(writer, BAD_CAST "id", BAD_CAST [metadata.author.email.user UTF8String]);
                xmlTextWriterWriteAttribute(writer, BAD_CAST "domain", BAD_CAST [metadata.author.email.domain UTF8String]);
                xmlTextWriterEndElement(writer);
            }
            if (metadata.author.link) {
                xmlTextWriterStartElement(writer, BAD_CAST "link");
                xmlTextWriterWriteAttribute(writer, BAD_CAST "href", BAD_CAST [[metadata.author.link.href absoluteString] UTF8String]);
                if (metadata.author.link.text) {
                    xmlTextWriterWriteElement(writer, BAD_CAST "text", BAD_CAST [metadata.author.link.text UTF8String]);
                }
                if (metadata.author.link.type) {
                    xmlTextWriterWriteElement(writer, BAD_CAST "type", BAD_CAST [metadata.author.link.type UTF8String]);
                }
                xmlTextWriterEndElement(writer);
            }
            xmlTextWriterEndElement(writer);
        }
        if (metadata.copyright) {
            xmlTextWriterStartElement(writer, BAD_CAST "copyright");
            xmlTextWriterWriteAttribute(writer, BAD_CAST "author", BAD_CAST [metadata.copyright.author UTF8String]);
            if (metadata.copyright.year) {
                xmlTextWriterWriteElement(writer, BAD_CAST "year", BAD_CAST [metadata.copyright.year UTF8String]);
            }
            if (metadata.copyright.license) {
                xmlTextWriterWriteElement(writer, BAD_CAST "license", BAD_CAST [[metadata.copyright.license absoluteString] UTF8String]);
            }
            xmlTextWriterEndElement(writer);

        }
        if (metadata.link) {
            write_links(metadata.link, writer);
        }
        if (metadata.time) {
            write_time(metadata.time, writer);
        }
        if (metadata.keywords) {
            xmlTextWriterWriteElement(writer, BAD_CAST "keywords", BAD_CAST [metadata.keywords UTF8String]);
        }
        if (metadata.bounds) {
            xmlTextWriterStartElement(writer, BAD_CAST "bounds");
            xmlTextWriterWriteAttribute(writer, BAD_CAST "minlat", BAD_CAST [NSString stringWithFormat:@"%f", metadata.bounds.minlat]);
            xmlTextWriterWriteAttribute(writer, BAD_CAST "minlon", BAD_CAST [NSString stringWithFormat:@"%f", metadata.bounds.minlon]);
            xmlTextWriterWriteAttribute(writer, BAD_CAST "maxlat", BAD_CAST [NSString stringWithFormat:@"%f", metadata.bounds.maxlat]);
            xmlTextWriterWriteAttribute(writer, BAD_CAST "maxlon", BAD_CAST [NSString stringWithFormat:@"%f", metadata.bounds.maxlon]);
            xmlTextWriterEndElement(writer);
        }
        xmlTextWriterEndElement(writer);
    }
}

void write_waypoints(GPX *gpx, xmlTextWriterPtr writer)
{
    NSMutableArray *waypoints = gpx.waypoints;
    for (Waypoint *waypoint in waypoints) {
        write_waypoint(waypoint, writer, @"wpt");
    }
}

void write_routes(GPX *gpx, xmlTextWriterPtr writer)
{
    for (Route *route in gpx.routes) {
        xmlTextWriterStartElement(writer, BAD_CAST "rte");
        write_path_header(route, writer);
        if (route.rtept) {
            for (Waypoint *waypoint in route.rtept) {
                write_waypoint(waypoint, writer, @"rtept");
            }
        }
        xmlTextWriterEndElement(writer);
    }
}

void write_tracks(GPX *gpx, xmlTextWriterPtr writer)
{
    for (Trek *trek in gpx.treks) {
        xmlTextWriterStartElement(writer, BAD_CAST "trk");
        write_path_header(trek, writer);
        if (trek.trekseg) {
            for (TrekSegment *seg in trek.trekseg) {
                xmlTextWriterStartElement(writer, BAD_CAST "trkseg");
                for (Waypoint *waypoint in seg.trekpoints) {
                    write_waypoint(waypoint, writer, @"trkpt");
                }
                xmlTextWriterEndElement(writer); 
            }
        }
        xmlTextWriterEndElement(writer);
    }
    
}

void write_path_header(PathHeader *header, xmlTextWriterPtr writer)
{
    if (header.name) {
        xmlTextWriterWriteElement(writer, BAD_CAST "name", BAD_CAST [header.name UTF8String]);
    }
    if (header.cmt) {
        xmlTextWriterWriteElement(writer, BAD_CAST "cmt", BAD_CAST [header.cmt UTF8String]);
    }
    if (header.desc) {
        xmlTextWriterWriteElement(writer, BAD_CAST "desc", BAD_CAST [header.desc UTF8String]);
    }
    if (header.src) {
        xmlTextWriterWriteElement(writer, BAD_CAST "src", BAD_CAST [header.src UTF8String]);
    }
    write_links(header.link, writer);
    if (header.number) {
        xmlTextWriterWriteElement(writer, BAD_CAST "number", BAD_CAST [[NSString stringWithFormat:@"%i", header.number] UTF8String]);
    }
    if (header.type) {
        xmlTextWriterWriteElement(writer, BAD_CAST "type", BAD_CAST [header.type UTF8String]);
    }
}

void write_waypoint(Waypoint *waypoint, xmlTextWriterPtr writer, NSString *tag)
{
    xmlTextWriterStartElement(writer, BAD_CAST [tag UTF8String]);
    xmlTextWriterWriteAttribute(writer, BAD_CAST "lat", BAD_CAST [[NSString stringWithFormat:@"%f", waypoint.lat] UTF8String]);
    xmlTextWriterWriteAttribute(writer, BAD_CAST "lon", BAD_CAST [[NSString stringWithFormat:@"%f", waypoint.lon] UTF8String]);
    write_path_header(waypoint, writer);
    if (waypoint.elev) {
        xmlTextWriterWriteElement(writer, BAD_CAST "ele", BAD_CAST [[NSString stringWithFormat:@"%f", waypoint.elev] UTF8String]);
    }
    if (waypoint.time) {
        write_time(waypoint.time, writer);
    }
    if ([waypoint getMagvar]) {
        xmlTextWriterWriteElement(writer, BAD_CAST "magvar", BAD_CAST [[NSString stringWithFormat:@"%f", [waypoint getMagvar]] UTF8String]);
    }
    if (waypoint.geoidheight) {
        xmlTextWriterWriteElement(writer, BAD_CAST "geoidheight", BAD_CAST [[NSString stringWithFormat:@"%f", waypoint.geoidheight] UTF8String]);
    }
    if (waypoint.sym) {
        xmlTextWriterWriteElement(writer, BAD_CAST "sym", BAD_CAST [waypoint.sym UTF8String]);
    }
    if ([waypoint getFix]) {
        xmlTextWriterWriteElement(writer, BAD_CAST "fix", BAD_CAST [[waypoint getFix] UTF8String]);
    }
    if (waypoint.sat) {
        xmlTextWriterWriteElement(writer, BAD_CAST "sat", BAD_CAST [[NSString stringWithFormat:@"%i", waypoint.sat] UTF8String]);
    }
    if (waypoint.hdop) {
        xmlTextWriterWriteElement(writer, BAD_CAST "hdop", BAD_CAST [[NSString stringWithFormat:@"%f", waypoint.hdop] UTF8String]);
    }
    if (waypoint.vdop) {
        xmlTextWriterWriteElement(writer, BAD_CAST "vdop", BAD_CAST [[NSString stringWithFormat:@"%f", waypoint.vdop] UTF8String]);
    }
    if (waypoint.pdop) {
        xmlTextWriterWriteElement(writer, BAD_CAST "pdop", BAD_CAST [[NSString stringWithFormat:@"%f", waypoint.pdop] UTF8String]);
    }
    if (waypoint.ageofdgpsdata) {
        xmlTextWriterWriteElement(writer, BAD_CAST "ageofdgpsdata", BAD_CAST [[NSString stringWithFormat:@"%f", waypoint.ageofdgpsdata] UTF8String]);
    }
    if ([waypoint getDgpsid]) {
        xmlTextWriterWriteElement(writer, BAD_CAST "dgpsid", BAD_CAST [[NSString stringWithFormat:@"%i", [waypoint getDgpsid]] UTF8String]);
    }
    xmlTextWriterEndElement(writer);
}

void write_links(NSMutableArray *links, xmlTextWriterPtr writer)
{
    for (Link *link in links) {
        xmlTextWriterStartElement(writer, BAD_CAST "link");
        xmlTextWriterWriteAttribute(writer, BAD_CAST "href", BAD_CAST [[link.href absoluteString] UTF8String]);
        if (link.text) {
            xmlTextWriterWriteElement(writer, BAD_CAST "text", BAD_CAST [link.text UTF8String]);
        }
        if (link.type) {
            xmlTextWriterWriteElement(writer, BAD_CAST "type", BAD_CAST [link.type UTF8String]);
        }
        xmlTextWriterEndElement(writer);
    }
}

void write_time(NSDate *time, xmlTextWriterPtr writer)
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeStyle:NSDateFormatterFullStyle];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    xmlTextWriterWriteElement(writer, BAD_CAST "time", BAD_CAST [[dateFormat stringFromDate:time] UTF8String]);
    [dateFormat release];
}

