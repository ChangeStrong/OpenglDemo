//
//  ViewController.m
//  LLImageView
//
//  Created by luo luo on 26/01/2018.
//  Copyright © 2018 ChangeStrong. All rights reserved.
//

#import "ViewController.h"
#import "LLImageView.h"
@interface ViewController (){
    
}
@property(nonatomic, strong) LLImageView *imageView;
@end

@implementation ViewController

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
}

- (IBAction)testButton:(UIButton *)sender {
//    [self.imageView setNeedsDisplay];
//    [self.imageView layoutIfNeeded];
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
    CGContextRef imageContextRef = CGBitmapContextCreate(imageData, imageWidth, imageHeight, 8, imageWidth*4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
    CGContextTranslateCTM(imageContextRef, 0, imageHeight);
    CGContextScaleCTM(imageContextRef, 1.0, -1.0);
    CGContextDrawImage(imageContextRef, CGRectMake(0.0, 0.0, (CGFloat)imageWidth, (CGFloat)imageHeight), imageRef);
    CGContextRelease(imageContextRef);
    return  imageData;
}


@end
