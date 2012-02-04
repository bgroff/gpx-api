#import <stdio.h>
#import <string.h>
#import <libxml/xmlreader.h>

#import "gpx-api.h"

void parse_gpx(xmlNode*, GPX*);
void parse_metadata(xmlNode*, GPX*);
void parse_routes(xmlNode*, GPX*);
void parse_tracks(xmlNode*, GPX*);
Waypoint* parse_waypoint(xmlNode*);

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        
    GPX *gpx = [[GPX alloc] init];
    xmlDoc *doc = NULL;
    xmlNode *root_element = NULL;
    
    if (argc < 2) {
        [gpx release];
        return -1;
    }
    
    doc = xmlReadFile(argv[1], NULL, 0);
    
    if (doc == NULL) {
        printf("error: could not parse file %s\n", argv[1]);
    }
    
    root_element = xmlDocGetRootElement(doc);    
    parse_gpx(root_element, gpx);
    xmlFreeDoc(doc);
    
    [gpx release];
    return 0;
    }
}


void parse_gpx(xmlNode *node, GPX *gpx)
{
    xmlNode *cur_node = NULL;
    for (cur_node = node; cur_node; cur_node = cur_node->next) {
        if (strcmp((const char*)cur_node->name, "metadata") == 0) {
            parse_metadata(cur_node->children, gpx);
            continue;
        }
        if (strcmp((const char*)cur_node->name, "wpt") == 0) {
            Waypoint *waypoint = parse_waypoint(cur_node);
            printf("Name: %s, Lat: %f, Lon: %f, Elevation: %f\n", [waypoint.name UTF8String], waypoint.lat, waypoint.lon, waypoint.elev);
            if (waypoint != nil) {
                [gpx addWaypoint:waypoint];
            }
        }
        if (strcmp((const char*)cur_node->name, "rte") == 0) {
            continue;
        }
        if (strcmp((const char*)cur_node->name, "trk") == 0) {
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
            xmlNode *text = cur_node->children;
            if (text && text->type == XML_TEXT_NODE) {
                xmlChar *content = xmlNodeGetContent(text);
                if (content != NULL) {
                    metadata.name = [NSString stringWithUTF8String:(const char *)content];
                }
                xmlFree(content);
            }
            
        }
        if (strcasecmp((const char*)cur_node->name, "desc") == 0) {
            xmlNode *text = cur_node->children;
            if (text && text->type == XML_TEXT_NODE) {
                xmlChar *content = xmlNodeGetContent(text);
                if (content != NULL) {
                    metadata.desc = [NSString stringWithUTF8String:(const char *)content];
                }
                xmlFree(content);
            }
            
        }
        if (strcasecmp((const char*)cur_node->name, "author") == 0) {
            Person *author = [[Person alloc] init];
            for (xmlNode *child = cur_node->children; child; child = child->next) {
                if (strcasecmp((const char*)child->name, "name") == 0) {
                    xmlNode *text = child->children;
                    if (text && text->type == XML_TEXT_NODE) {
                        xmlChar *content = xmlNodeGetContent(text);
                        if (content != NULL) {
                            author.name = [NSString stringWithUTF8String:(const char *)content];
                        }
                        xmlFree(content);
                    }
                }
                if (strcasecmp((const char*)child->name, "email") == 0) {
                    xmlChar *user = xmlGetProp(child, (xmlChar*)"id");
                    xmlChar *domain = xmlGetProp(child, (xmlChar*)"domain");
                    if (user != NULL && domain != NULL) {
                        Email *email = [[Email alloc] initWithUserAndDomain: [NSString stringWithUTF8String:(const char *)user] :[ NSString stringWithUTF8String:(const char *)domain]];
                        author.email = email;
                        [email release];
                    }
                    xmlFree(user); xmlFree(domain);
                }
                if (strcasecmp((const char*)child->name, "link") == 0) {
                    xmlChar *href = xmlGetProp(child, (xmlChar*)"href");
                    Link *link = [[Link alloc] initWithHref:[NSURL URLWithString:[NSString stringWithUTF8String:(const char*)href]]];
                    author.link = link;
                    [link release];
                    xmlFree(href);
                    if (href != NULL) {
                        for (xmlNode *inner = child->children; inner; inner = inner->next) {
                            if (strcasecmp((const char*)inner->name, "text") == 0 && inner->type == XML_ELEMENT_NODE) {
                                xmlNode *text_node = inner->children;
                                if (text_node && text_node->type == XML_TEXT_NODE) {
                                    xmlChar *text = xmlNodeGetContent(text_node);
                                    if (text != NULL) {
                                        link.text = [NSString stringWithUTF8String:(const char *)text];
                                        xmlFree(text);
                                    }
                                }
                            }
                            if (strcasecmp((const char*)inner->name, "type") == 0) {
                                xmlNode *text_node = inner->children;
                                if (text_node && text_node->type == XML_TEXT_NODE) {
                                    xmlChar *type = xmlNodeGetContent(text_node);
                                    if (type != NULL) {
                                        link.text = [NSString stringWithUTF8String:(const char *)type];
                                        xmlFree(type);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            metadata.author = author;
            [author release];
        }
        if (strcasecmp((const char*)cur_node->name, "copyright") == 0) {
            xmlChar *author = xmlGetProp(cur_node, (xmlChar*)"author");
            Copyright *copyright = [[Copyright alloc] initWithValues:[NSString stringWithUTF8String:(const char *)author] :nil :nil];
            metadata.copyright = copyright;
            xmlFree(author);
            for (xmlNode *child = cur_node->children; child; child = child->next) {
                if (strcasecmp((const char*)child->name, "year") == 0) {
                    xmlNode *text = child->children;
                    if (text && text->type == XML_TEXT_NODE) {
                        xmlChar *content = xmlNodeGetContent(text);
                        if (content != NULL) {
                            copyright.year = [NSString stringWithUTF8String:(const char *)content];
                        }
                        xmlFree(content);
                    }
                }
                if (strcasecmp((const char*)child->name, "license") == 0) {
                    xmlNode *text = child->children;
                    if (text && text->type == XML_TEXT_NODE) {
                        xmlChar *content = xmlNodeGetContent(text);
                        if (content != NULL) {
                            copyright.license = [NSURL URLWithString:[NSString stringWithUTF8String:(const char *)content]];
                        }
                        xmlFree(content);
                    }
                }
            }
            [copyright release];
        }
        if (strcasecmp((const char*)cur_node->name, "link") == 0) {
            xmlChar *href = xmlGetProp(cur_node, (xmlChar*)"href");
            Link *link = [[Link alloc] initWithHref:[NSURL URLWithString:[NSString stringWithUTF8String:(const char *)href]]];
            [metadata addLink:link];
            xmlFree(href);
            for (xmlNode *child = cur_node->children; child; child = child->next) {
                if (strcasecmp((const char*)child->name, "text") == 0) {
                    xmlNode *text = child->children;
                    if (text && text->type == XML_TEXT_NODE) {
                        xmlChar *content = xmlNodeGetContent(text);
                        if (content != NULL) {
                            link.text = [NSString stringWithUTF8String:(const char *)content];
                        }
                        xmlFree(content);
                    }
                }
            }
            [link release];
        }
        if (strcasecmp((const char*)cur_node->name, "time") == 0) {
            xmlNode *text = cur_node->children;
            if (text && text->type == XML_TEXT_NODE) {
                xmlChar *content = xmlNodeGetContent(text);
                if (content != NULL) {
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setTimeStyle:NSDateFormatterFullStyle];
                    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                    metadata.time = [dateFormat dateFromString:[NSString stringWithUTF8String:(const char *)content]];
                    [dateFormat release];
                }
                xmlFree(content);
            }
        }
        if (strcasecmp((const char*)cur_node->name, "keywords") == 0) {
            xmlNode *text = cur_node->children;
            if (text && text->type == XML_TEXT_NODE) {
                xmlChar *content = xmlNodeGetContent(text);
                if (content != NULL) {
                    metadata.keywords = [NSString stringWithUTF8String:(const char *)content];
                }
                xmlFree(content);
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
            }
            if (minlat) xmlFree(minlat); if (minlon) xmlFree(minlon);
            if (maxlat) xmlFree(maxlat); if (maxlon) xmlFree(maxlon);
        }
    }
    [metadata release];
}

void parse_routes(xmlNode *node, GPX *gpx)
{

}

void parse_tracks(xmlNode *node, GPX *gpx)
{
    
}

Waypoint* parse_waypoint(xmlNode *node)
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
                xmlNode *text = child->children;
                if (text && text->type == XML_TEXT_NODE) {
                    xmlChar *content = xmlNodeGetContent(text);
                    if (content != NULL) {
                        waypoint.elev = [[NSString stringWithUTF8String:(const char *)content] doubleValue];
                    }
                    xmlFree(content);
                }
            }
            if (strcasecmp((const char*)child->name, "name") == 0) {
                xmlNode *text = child->children;
                if (text && text->type == XML_TEXT_NODE) {
                    xmlChar *content = xmlNodeGetContent(text);
                    if (content != NULL) {
                        waypoint.name = [NSString stringWithUTF8String:(const char *)content];
                    }
                    xmlFree(content);
                }
            }
        }
        return waypoint;
    }
    return nil;
}
