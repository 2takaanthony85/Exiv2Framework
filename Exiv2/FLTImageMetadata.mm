
// Created by Sinisa Drpa on 9/29/15.

#import <Foundation/Foundation.h>

#import "FLTImageMetadata.h"

#include <string>
#include <exiv2/exiv2.hpp>
#include <iostream>
#include <iomanip>

typedef NS_ENUM(NSUInteger, Exiv2Metadata) {
   Exiv2MetadataExif = 1,
   Exiv2MetadataXmp
};

@interface FLTImageMetadata () {
   Exiv2::Image::AutoPtr image;
   Exiv2::ExifData exifData;
   Exiv2::XmpData xmpData;
   Exiv2::IptcData iptcData;
}
@end

@implementation FLTImageMetadata

- (instancetype)initWithImageAtURL:(NSURL *)imageURL {
   self = [super init];
   if (self) {
      NSString *imagePath = [imageURL path];
      image = Exiv2::ImageFactory::open([imagePath UTF8String]);
      assert(image.get() != 0);
      image->readMetadata();
      
      exifData = image->exifData();
      xmpData = image->xmpData();
      iptcData = image->iptcData();
   }
   return self;
}

/**
 Returns array of available EXIF properties inside the image
*/
- (NSArray *)exifKeys {
   NSMutableArray *mutableArray = [NSMutableArray array];
   for (Exiv2::ExifData::const_iterator md = exifData.begin();
        md != exifData.end(); ++md) {
      [mutableArray addObject:[NSString stringWithUTF8String:md->key().c_str()]];
   }
   return [mutableArray copy];
}

/**
 Returns array of available XMP properties inside the image
 */
- (NSArray *)xmpKeys {
   NSMutableArray *mutableArray = [NSMutableArray array];
   for (Exiv2::XmpData::const_iterator md = xmpData.begin();
        md != xmpData.end(); ++md) {
      [mutableArray addObject:[NSString stringWithUTF8String:md->key().c_str()]];
   }
   return [mutableArray copy];
}

/**
 Returns array of available XMP properties inside the image
 */
- (NSArray *)iptcKeys {
   NSMutableArray *mutableArray = [NSMutableArray array];
   for (Exiv2::IptcData::const_iterator md = iptcData.begin();
        md != iptcData.end(); ++md) {
      [mutableArray addObject:[NSString stringWithUTF8String:md->key().c_str()]];
   }
   return [mutableArray copy];
}

#pragma mark -

- (void)printExif {
   if (exifData.empty()) {
      NSLog(@"No EXIF data found in the file");
      return;
   }
   
   Exiv2::ExifData::const_iterator end = exifData.end();
   for (Exiv2::ExifData::const_iterator i = exifData.begin(); i != end; ++i) {
      const char* tn = i->typeName();
      std::cout << std::setw(44) << std::setfill(' ') << std::left
      << i->key() << " "
      << "0x" << std::setw(4) << std::setfill('0') << std::right
      << std::hex << i->tag() << " "
      << std::setw(9) << std::setfill(' ') << std::left
      << (tn ? tn : "Unknown") << " "
      << std::dec << std::setw(3)
      << std::setfill(' ') << std::right
      << i->count() << "  "
      << std::dec << i->value()
      << "\n";
   }
}

- (void)printXmp {
   if (xmpData.empty()) {
      NSLog(@"No XMP data found in the file");
      return;
   }
   
   for (Exiv2::XmpData::const_iterator md = xmpData.begin();
        md != xmpData.end(); ++md) {
      std::cout << std::setfill(' ') << std::left
      << std::setw(44)
      << md->key() << " "
      << std::setw(9) << std::setfill(' ') << std::left
      << md->typeName() << " "
      << std::dec << std::setw(3)
      << std::setfill(' ') << std::right
      << md->count() << "  "
      << std::dec << md->value()
      << std::endl;
   }
}

- (void)printIpct {
   if (iptcData.empty()) {
      NSLog(@"No IPTC data found in the file");
      return;
   }
   
   Exiv2::IptcData::iterator end = iptcData.end();
   for (Exiv2::IptcData::iterator md = iptcData.begin(); md != end; ++md) {
      std::cout << std::setw(44) << std::setfill(' ') << std::left
      << md->key() << " "
      << "0x" << std::setw(4) << std::setfill('0') << std::right
      << std::hex << md->tag() << " "
      << std::setw(9) << std::setfill(' ') << std::left
      << md->typeName() << " "
      << std::dec << std::setw(3)
      << std::setfill(' ') << std::right
      << md->count() << "  "
      << std::dec << md->value()
      << std::endl;
   }
}

@end
