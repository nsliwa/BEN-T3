//
//  ViewController.m
//  SMUOpenCV
//
//  Created by Eric Larson on 2/27/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

#import "ViewController.h"
#import "AVFoundation/AVFoundation.h"
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/cap_ios.h>
#import "CvVideoCameraMod.h"
using namespace cv;

@interface ViewController () <CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CvVideoCameraMod *videoCamera;
@property (nonatomic) BOOL torchIsOn;
@property (weak, nonatomic) IBOutlet UISwitch *cameraSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *torchSwitch;
@property (weak, nonatomic) IBOutlet UILabel *objectDetectedLabel;

@property (nonatomic) int objectCount;
@property (nonatomic) float* bufferR;
@property (nonatomic) float* bufferG;
@property (nonatomic) float* bufferB;

@end

@implementation ViewController

-(int)objectCount {
    if(!_objectCount) {
        _objectCount = 0;
    }
    
    return _objectCount;
}

-(float*)bufferR {
    if(!_bufferR) {
        _bufferR = new float[100]();
    }
    
    return _bufferR;
}

-(float*)bufferG {
    if(!_bufferG) {
        _bufferG = new float[100]();
    }
    
    return _bufferG;
}

-(float*)bufferB {
    if(!_bufferB) {
        _bufferB = new float[100]();
    }
    
    return _bufferB;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.videoCamera = [[CvVideoCameraMod alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    
    self.torchSwitch.enabled = false;
    
//    self.torchIsOn = !self.torchIsOn;
//    [self setTorchOn:self.torchIsOn];
    
    [self.videoCamera start];
    
    self.torchIsOn = NO;
    
}

#ifdef __cplusplus
-(void) processImage:(Mat &)image{
 
    //NSLog(@"procesing");
    
    // Do some OpenCV stuff with the image
    Mat image_copy;
    Mat grayFrame, output;
    
    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
    
    Scalar avgPixelIntensity = cv::mean( image_copy );
//    char text[50];
//    sprintf(text,"Avg. B: %.1f, G: %.1f,R: %.1f", avgPixelIntensity.val[0],avgPixelIntensity.val[1],avgPixelIntensity.val[2]);
//    cv::putText(image, text, cv::Point(10, 20), FONT_HERSHEY_PLAIN, 1, Scalar::all(255), 1,2);
//    NSLog(@"Avg B: %.1f, G: %.1f, R: %.1f", avgPixelIntensity.val[0], avgPixelIntensity.val[1], avgPixelIntensity.val[2]);
    
    if(avgPixelIntensity.val[0] < 75.0 && avgPixelIntensity.val[1] < 75.0) {
        NSLog(@"Object! %d", self.objectCount);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cameraSwitch.enabled = false;
            self.torchSwitch.enabled = false;
        });
        
        if(self.objectCount < 100) {
            self.bufferR[self.objectCount] = avgPixelIntensity.val[2];
            self.bufferG[self.objectCount] = avgPixelIntensity.val[1];
            self.bufferB[self.objectCount] = avgPixelIntensity.val[0];
            
            self.objectCount++;
        }
        
    }
    
    else {
        self.objectCount = 0;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cameraSwitch.enabled = true;
            self.torchSwitch.enabled = true;
        });
    }
    
    if(self.objectCount >= 100) {
        dispatch_async(dispatch_get_main_queue(), ^{
           self.objectDetectedLabel.text = @"Object!";
        });
        
        NSLog(@"Object present for longer than 100 frames!");
    }
    
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.objectDetectedLabel.text = @"";
        });
    }
    
//    cvtColor(image_copy, image_copy, CV_BGR2HSV); // convert to hsv
    
//    avgPixelIntensity = cv::mean( image_copy );
////        char text[50];
//        sprintf(text,"Avg. H: %.1f, S: %.1f,V: %.1f", avgPixelIntensity.val[0],avgPixelIntensity.val[1],avgPixelIntensity.val[2]);
//        cv::putText(image, text, cv::Point(10, 20), FONT_HERSHEY_PLAIN, 1, Scalar::all(255), 1,2);
//    NSLog(@"Avg H: %.1f, S: %.1f, V: %.1f", avgPixelIntensity.val[0], avgPixelIntensity.val[1], avgPixelIntensity.val[2]);
    
    
//    cvtColor(image_copy, image_copy, CV_HSV2BGR); // convert back from hsv
    cvtColor(image_copy, image, CV_BGR2BGRA); //add back for display
    
    //============================================
    // color inverter
//    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
//    
//    // invert image
//    bitwise_not(image_copy, image_copy);
//    // copy back for further processing
//    cvtColor(image_copy, image, CV_BGR2BGRA); //add back for display
    
    //============================================
    //access pixels
//    static uint counter = 0;
//    cvtColor(image, image_copy, CV_BGRA2BGR);
//    for(int i=0;i<counter;i++){
//        for(int j=0;j<counter;j++){
//            uchar *pt = image_copy.ptr(i, j);
//            pt[0] = 255;
//            pt[1] = 0;
//            pt[2] = 255;
//            
//            pt[3] = 255;
//            pt[4] = 0;
//            pt[5] = 0;
//        }
//    }
//    cvtColor(image_copy, image, CV_BGR2BGRA);
//    
//    counter++;
//    counter = counter>200 ? 0 : counter;
    
    //============================================
    // get average pixel intensity
//    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
//    Scalar avgPixelIntensity = cv::mean( image_copy );
//    char text[50];
//    sprintf(text,"Avg. B: %.1f, G: %.1f,R: %.1f", avgPixelIntensity.val[0],avgPixelIntensity.val[1],avgPixelIntensity.val[2]);
//    cv::putText(image, text, cv::Point(10, 20), FONT_HERSHEY_PLAIN, 1, Scalar::all(255), 1,2);
    
    //============================================
    // change the hue inside an image
    
    //convert to HSV
//    cvtColor(image, image_copy, CV_BGRA2BGR);
//    cvtColor(image_copy, image_copy, CV_BGR2HSV);
//    
//    //grab  just the Hue chanel
//    vector<Mat> layers;
//    cv::split(image_copy,layers);
//    
//    // shift the colors
//    cv::add(layers[0],80.0,layers[0]);
//    
//    // get back image from separated layers
//    cv::merge(layers,image_copy);
//    
//    cvtColor(image_copy, image_copy, CV_HSV2BGR);
//    cvtColor(image_copy, image, CV_BGR2BGRA);
}
#endif
- (IBAction)toggleTorchSwitch:(id)sender {
    
    self.torchIsOn = !self.torchIsOn;
    [self setTorchOn:self.torchIsOn];
    
}
- (IBAction)toggleCameraSwitch:(id)sender {
    
    if(self.cameraSwitch.on) {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
        [self.videoCamera stop];
        [self.videoCamera start];
        [self.torchSwitch setOn:(true)];
        self.torchIsOn = NO;
        self.torchSwitch.enabled = false;
        
    } else {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
        [self.videoCamera stop];
        [self.videoCamera start];
        self.torchSwitch.enabled = true;
    }
    
}

- (IBAction)toggleTorch:(id)sender {
    
}

- (void)setTorchOn: (BOOL) onOff
{
    AVCaptureDevice *device = nil;
    
    NSArray* allDevices = [AVCaptureDevice devices];
    for (AVCaptureDevice* currentDevice in allDevices) {
        if (currentDevice.position == AVCaptureDevicePositionBack) {
            device = currentDevice;
        }
    }
    
    
//    AVCaptureDevice *device = [AVCaptureDevice
//                               defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionBack && [device hasTorch]) {
        
        [device lockForConfiguration:nil];
        [device setTorchMode: onOff ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
        [device unlockForConfiguration];
        
    }
    
}


@end
