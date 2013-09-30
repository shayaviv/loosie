//
//  ArtworkExtractor.m
//  Loosie
//
//  Created by Shay Aviv on 9/29/13.
//  Copyright (c) 2013 Shay Aviv. All rights reserved.
//

#import "ArtworkExtractor.h"
#import <iTunesLibrary/ITLibArtwork.h>

@implementation ArtworkExtractor

+ (BOOL)saveJPEGofArtwork:(ITLibArtwork *)artwork atURL:(NSURL *)url maxPixelsWide:(size_t)maxWidth {
    if (!artwork)
        return NO;
    
    NSImage *image = artwork.image;
    size_t pixelsWide = 0, pixelsHigh = 0;
    for (NSBitmapImageRep *imageRep in [NSBitmapImageRep imageRepsWithData:[image TIFFRepresentation]]) {
        if (imageRep.pixelsWide > pixelsWide) pixelsWide = imageRep.pixelsWide;
        if (imageRep.pixelsHigh > pixelsHigh) pixelsHigh = imageRep.pixelsHigh;
    }
    
    BOOL manipulationRequired = artwork.imageDataFormat != ITLibArtworkFormatJPEG;
    if (pixelsWide > maxWidth) {
        pixelsHigh = roundf(((float)maxWidth / pixelsWide) * pixelsHigh);
        pixelsWide = maxWidth;
        manipulationRequired = YES;
    }
    
    if (manipulationRequired)
        return [[NSFileManager defaultManager] fileExistsAtPath:url.path] ||
                [self saveJPEGForImage:image atURL:url withWidth:pixelsWide andHeight:pixelsHigh];
    else
        return [artwork.imageData writeToURL:url options:NSDataWritingWithoutOverwriting error:nil];
}

+ (BOOL)saveJPEGForImage:(NSImage*)image atURL:(NSURL *)url withWidth:(size_t)width andHeight:(size_t)height {
    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
    
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, width * 4, rgbColorspace, bitmapInfo);
    NSGraphicsContext * graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
    [NSGraphicsContext setCurrentContext:graphicsContext];
    
    [image drawInRect:NSMakeRect(0, 0, width, height) fromRect:NSMakeRect(0, 0, image.size.width, image.size.height) operation:NSCompositeCopy fraction:1.0];
    
    CGImageRef outImage = CGBitmapContextCreateImage(context);
    CFURLRef outURL = (__bridge CFURLRef)url;
    CGImageDestinationRef outDestination = CGImageDestinationCreateWithURL(outURL, kUTTypeJPEG, 1, NULL);
    CGImageDestinationAddImage(outDestination, outImage, NULL);
    if(!CGImageDestinationFinalize(outDestination))
        return NO;
    CFRelease(outDestination);
    CGImageRelease(outImage);
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorspace);
    return YES;
}

@end
