// AviaryGap - v.1.0.0
// (c) 2013 Ryan Vanderpol, me@ryanvanderpol.com, MIT Licensed.
// AviaryPlugin.m may be freely distributed under the MIT license.
//
//  AviaryPlugin.m
//

#import "AviaryPlugin.h"
#import <Cordova/CDVPluginResult.h>
#import <Cordova/CDVViewController.h>
#import "AFPhotoEditorController.h"

@implementation AviaryPlugin

@synthesize aviary;
@synthesize pluginCallbackId;

- (void) editImage:(NSMutableArray*) arguments withDict:(NSMutableDictionary*)options
{    
    self.pluginCallbackId = [arguments objectAtIndex:0];
    NSString* photoFilePath = [arguments objectAtIndex:1];
    
    NSURL* url = [NSURL URLWithString:photoFilePath];
    NSString* imagePath = [url path];
    
    UIImage* photoImage = [UIImage imageWithContentsOfFile:imagePath];
    
    /*
    [customToolsArray addObject:kAFEnhance];
    
    if  ( [[tools objectAtIndex:i] isEqualToString: @"Effects"] )
        [customToolsArray addObject:kAFEffects];
    
    if  ( [[tools objectAtIndex:i] isEqualToString: @"Stickers"] )
        [customToolsArray addObject:kAFStickers];
    
    if  ( [[tools objectAtIndex:i] isEqualToString: @"Orientation"] )
        [customToolsArray addObject:kAFOrientation];
    
    if  ( [[tools objectAtIndex:i] isEqualToString: @"Crop"] )
        [customToolsArray addObject:kAFCrop];
    
    if  ( [[tools objectAtIndex:i] isEqualToString: @"Brightness"] )
        [customToolsArray addObject:kAFBrightness];
    
    if  ( [[tools objectAtIndex:i] isEqualToString: @"Contrast"] )
        [customToolsArray addObject:kAFContrast];
    
    if  ( [[tools objectAtIndex:i] isEqualToString: @"Saturation"] )
        [customToolsArray addObject:kAFSaturation];
    
    if  ( [[tools objectAtIndex:i] isEqualToString: @"Sharpness"] )
        [customToolsArray addObject:kAFSharpness];
    
*/
    
    NSArray *tools = [NSArray arrayWithObjects:kAFEnhance, kAFEffects, nil];
    
    NSArray * keys =[NSArray arrayWithObjects:kAFPhotoEditorControllerToolsKey, nil ];
    NSArray * objects = [NSArray arrayWithObjects:tools, nil];
    NSDictionary * dict =[ NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    
    self.aviary = [[[AFPhotoEditorController alloc] initWithImage:photoImage options:dict] autorelease];
    [self.aviary setDelegate:self];
    [self.viewController presentModalViewController:self.aviary animated:YES];
     
}

-(void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    
    BOOL ok = false;
    NSString * res = @"error";
    float quality = 80.0f;
    BOOL saveToPhotoAlbum = YES;
    
    NSData* data = nil;
    data = UIImageJPEGRepresentation(image , quality);
    
    // write to temp directory and reutrn URI
    // get the temp directory path
    NSString* docsPath = [NSTemporaryDirectory() stringByStandardizingPath];
    NSError* err = nil;
    NSFileManager* fileMgr = [[NSFileManager alloc] init];
    
    int width = image.size.width;
    int height = image.size.height;
    int orientation = image.imageOrientation;
    
    // generate unique file name
    NSString* filePath;
    int i=1;
    do
    {
        filePath = [NSString stringWithFormat:@"%@/photo_%03d.%@", docsPath, i++, @"jpg"];
    }
    while([fileMgr fileExistsAtPath: filePath]);
    
    // save file
    if (![data writeToFile: filePath options: NSAtomicWrite error: &err])
    {
        res = @"error saving file";
    }
    else
    {
        res = [[NSURL fileURLWithPath: filePath] absoluteString];
        ok = true;
    }
    [fileMgr release];
    
    if(ok)
    {
        if (saveToPhotoAlbum )
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        
        //[self sendOKMessage:res:width:height:orientation];
        [self sendOKMessage:res];
    }
    else
    {
        [self sendErrorMessage:res];
    }
    
    [self closeAviary];
}

-(void) photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self closeAviary];
}

-(void) sendOKMessage:(NSString*)imagePath
{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:imagePath];
    
    NSString* javaScript = [result toSuccessCallbackString:self.pluginCallbackId];
    [self writeJavascript:javaScript];
}

-(void) sendErrorMessage:(NSString*)message
{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    
    NSString* javaScript = [result toSuccessCallbackString:self.pluginCallbackId];
    [self writeJavascript:javaScript];
}


-(void) closeAviary
{
    
    [self.aviary dismissModalViewControllerAnimated:YES];
    self.aviary.delegate = nil;
    self.aviary = nil;
    //[aviary release];
}

@end
