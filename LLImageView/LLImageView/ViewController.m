//
//  ViewController.m
//  LLImageView
//
//  Created by luo luo on 26/01/2018.
//  Copyright © 2018 ChangeStrong. All rights reserved.
//

#import "ViewController.h"
#import "LLImageView.h"
/* 弧度转角度 */
#define SK_RADIANS_TO_DEGREES(radian) \
((radian) * (180.0 / M_PI))
/* 角度转弧度 */
#define SK_DEGREES_TO_RADIANS(angle) \
((angle) / 180.0 * M_PI)
@interface ViewController (){
    
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property(nonatomic, strong) LLImageView *imageView;
@end

@implementation ViewController{
    CGColorSpaceRef _colorSpace;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self createUI];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createUI
{
    self.imageView = [[LLImageView alloc]initWithFrame:CGRectMake(50, 100, 170, 100)];
//    view.backgroundColor = [UIColor greenColor];
    
    UIImage *image = [UIImage imageNamed:@"2.png"];
    GLubyte *imageData = [self getImageData:image];
    self.imageView->_imageData = imageData;
    self.imageView.imageWidth = image.size.width;
    self.imageView.imageHeight = image.size.height;
    [self.view addSubview:self.imageView];
    
    
    CGImageRef imageRef = [image CGImage];
    size_t imageWidth = CGImageGetWidth(imageRef);
    size_t imageHeight = CGImageGetHeight(imageRef);
    UIImage *image2 = [self imageFromBRGABytes:imageData imageSize:CGSizeMake(imageWidth, imageHeight)];
    self.imageView2.image = image2;
    NSLog(@"image2:%@",image2);
}

- (IBAction)testButton:(UIButton *)sender {
//    [self.imageView setNeedsDisplay];
//    [self.imageView layoutIfNeeded];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
}


#pragma mark 其它
/**
 *  获取图片数据的像素数据RGBA
 *
 *  @param image 图片
 *
 *  @return 像素数据
 */
- (void*)getImageData:(UIImage*)image{
    CGImageRef imageRef = [image CGImage];
    size_t imageWidth = CGImageGetWidth(imageRef);
    size_t imageHeight = CGImageGetHeight(imageRef);
    GLubyte *imageData = (GLubyte *)malloc(imageWidth*imageHeight*4);
    memset(imageData, 0,imageWidth *imageHeight*4);
    CGColorSpaceRef colorspace = CGImageGetColorSpace(imageRef);
    _colorSpace = CGColorSpaceRetain(colorspace);
    CGContextRef imageContextRef = CGBitmapContextCreate(imageData, imageWidth, imageHeight, 8, imageWidth*4, _colorSpace, kCGImageAlphaPremultipliedLast);
    //将uikit中的图片颠倒 方法一
//    CGContextTranslateCTM(imageContextRef, imageWidth, imageHeight);
//    CGContextRotateCTM(imageContextRef, SK_DEGREES_TO_RADIANS(-180));
    //将uikit中的图片颠倒 方法二
//    CGContextTranslateCTM(imageContextRef, 0, imageHeight);
//    CGContextScaleCTM(imageContextRef, 1.0, -1.0);
    CGContextDrawImage(imageContextRef, CGRectMake(0.0, 0.0, (CGFloat)imageWidth, (CGFloat)imageHeight), imageRef);
    CGContextRelease(imageContextRef);
    
    return  imageData;
}

- (UIImage *)imageFromBRGABytes:(unsigned char *)imageBytes imageSize:(CGSize)imageSize {
    CGImageRef imageRef = [self imageRefFromBGRABytes:imageBytes imageSize:imageSize];
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

- (CGImageRef)imageRefFromBGRABytes:(unsigned char *)imageBytes imageSize:(CGSize)imageSize {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(imageBytes,
                                                 imageSize.width,
                                                 imageSize.height,
                                                 8,
                                                 imageSize.width * 4,
                                                 colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return imageRef;
}


@end
