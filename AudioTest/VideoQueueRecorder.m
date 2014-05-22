//
//  VideoQueueRecorder.m
//  AudioTest
//
//  Created by wangbo on 5/18/14.
//  Copyright (c) 2014 Bob. All rights reserved.
//

#import "VideoQueueRecorder.h"
#import "x264Manager.h"

@implementation VideoQueueRecorder {
    dispatch_queue_t serial_queue;
    AVCaptureSession *avCaptureSession;
    AVCaptureDevice *avCaptureDevice;
    int producerFps;
    BOOL firstFrame;
}

+ (instancetype)sharedInstance {
    static VideoQueueRecorder *sharedNetUtilsInstance = nil;
    static dispatch_once_t predicate; dispatch_once(&predicate, ^{
        sharedNetUtilsInstance = [[self alloc] init];
        sharedNetUtilsInstance->serial_queue = dispatch_queue_create("com.bo.serial_video", NULL);
        sharedNetUtilsInstance->producerFps=15;
    });
    return sharedNetUtilsInstance;
}

#pragma mark -
#pragma mark VideoCapture
- (AVCaptureDevice *)getFrontCamera
{
    //获取前置摄像头设备
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in cameras)
    {
        if (device.position == AVCaptureDevicePositionFront)
            return device;
    }
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
}

- (void)startVideoCapture:(UIViewController *)vc
{
    //打开摄像设备，并开始捕抓图像
//    [labelStatesetText:@"Starting Video stream"];
    if(self->avCaptureDevice|| self->avCaptureSession)
    {
//        [labelStatesetText:@"Already capturing"];
        return;
    }
    
    if((self->avCaptureDevice = [self getFrontCamera]) == nil)
    {
//        [labelStatesetText:@"Failed to get valide capture device"];
        return;
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self->avCaptureDevice error:&error];
    if (!videoInput)
    {
//        [labelStatesetText:@"Failed to get video input"];
        self->avCaptureDevice= nil;
        return;
    }
    
    self->avCaptureSession = [[AVCaptureSession alloc] init];
    self->avCaptureSession.sessionPreset = AVCaptureSessionPresetLow;
    [self->avCaptureSession addInput:videoInput];
    
    // Currently, the only supported key is kCVPixelBufferPixelFormatTypeKey. Recommended pixel format choices are
    // kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange or kCVPixelFormatType_32BGRA.
    // On iPhone 3G, the recommended pixel format choices are kCVPixelFormatType_422YpCbCr8 or kCVPixelFormatType_32BGRA.
    //
    AVCaptureVideoDataOutput *avCaptureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
//    NSDictionary*settings = [[NSDictionary alloc] initWithObjectsAndKeys:
//                             //[NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
//                             [NSNumber numberWithInt:240], (id)kCVPixelBufferWidthKey,
//                             [NSNumber numberWithInt:320], (id)kCVPixelBufferHeightKey,
//                             nil];
//    avCaptureVideoDataOutput.videoSettings = settings;
//    [settings release];
    avCaptureVideoDataOutput.minFrameDuration = CMTimeMake(1, self->producerFps);
    /*We create a serial queue to handle the processing of our frames*/
//    dispatch_queue_t queue = dispatch_queue_create("org.doubango.idoubs", NULL);
    [avCaptureVideoDataOutput setSampleBufferDelegate:self queue:self->serial_queue];
    [self->avCaptureSession addOutput:avCaptureVideoDataOutput];
    [avCaptureVideoDataOutput release];
//    dispatch_release(queue);
    
    AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession: self->avCaptureSession];
//    previewLayer.frame = localView.bounds;
    previewLayer.frame = [UIScreen mainScreen].bounds;
    previewLayer.videoGravity= AVLayerVideoGravityResizeAspectFill;
    
    [vc.view.layer addSublayer: previewLayer];
    
    self->firstFrame= YES;
    [self->avCaptureSession startRunning];
    
//    [labelStatesetText:@"Video capture started"];
    
}
- (void)stopVideoCapture:(id)arg
{
    //停止摄像头捕抓
    if(self->avCaptureSession){
        [self->avCaptureSession stopRunning];
        self->avCaptureSession= nil;
//        [labelStatesetText:@"Video capture stopped"];
    }
    self->avCaptureDevice= nil;
    //移除localView里面的内容
//    for(UIView*view in self->localView.subviews) {
//        [view removeFromSuperview];
//    }
}
#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    
//    NSLog(@"main_thread:%d", [NSThread isMainThread]);
//    dispatch_async(serial_queue, ^(){
        [[x264Manager sharedInstance] encoderToH264:sampleBuffer];
//    });
    
    
    
    //捕捉数据输出 要怎么处理虽你便
//    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    /*Lock the buffer*/
//    if(CVPixelBufferLockBaseAddress(pixelBuffer, 0) == kCVReturnSuccess)
//    {
//        NSLog(@"plane_count:%zu", CVPixelBufferGetPlaneCount(pixelBuffer));
//    
//        NSData *data = [NSData dataWithBytes:pixelBuffer length:CVPixelBufferGetDataSize(pixelBuffer)];
//        NSLog(@"data:%@", data);
    
        
//        UInt8 *bufferPtr = (UInt8 *)CVPixelBufferGetBaseAddress(pixelBuffer);
//        size_t buffeSize = CVPixelBufferGetDataSize(pixelBuffer);
//        
//        
//        
//        if(self->firstFrame)
//        {
//            if(1)
//            {
//                //第一次数据要求：宽高，类型
//                int width = CVPixelBufferGetWidth(pixelBuffer);
//                int height = CVPixelBufferGetHeight(pixelBuffer);
//                
//                NSLog(@"width:%d height:%d bytesPerRow:%d bufferSize:%d", width, height, (int)CVPixelBufferGetBytesPerRow(pixelBuffer), (int)buffeSize);
//                
//                
//                int pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
//                NSLog(@"pixelFormat:%d", pixelFormat);
//                switch (pixelFormat) {
//                    case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
//                        //TMEDIA_PRODUCER(producer)->video.chroma = tmedia_nv12; // iPhone 3GS or 4
//                        NSLog(@"Capture pixel format=NV12");  
//                        break;  
//                    case kCVPixelFormatType_422YpCbCr8:
//                        //TMEDIA_PRODUCER(producer)->video.chroma = tmedia_uyvy422; // iPhone 3  
//                        NSLog(@"Capture pixel format=UYUY422");  
//                        break;  
//                    default:  
//                        //TMEDIA_PRODUCER(producer)->video.chroma = tmedia_rgb32;  
//                        NSLog(@"Capture pixel format=RGB32");  
//                        break;  
//                }  
//                
//                self->firstFrame = NO;  
//            }  
//        }  
//        /*We unlock the buffer*/  
//        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);   
//    }
}


@end
