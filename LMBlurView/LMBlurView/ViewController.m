//
//  ViewController.m
//  LMBlurView
//
//  Created by by on 15/12/26.
//  Copyright © 2015年 dlm. All rights reserved.
//

#import "ViewController.h"
#import "LMBlurView.h"
#import "UIImage+Helper.h"

#import "SDScreenshotCapture.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet LMBlurView *blurView;
@property (nonatomic, strong) CALayer *layer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    swip.numberOfTouchesRequired = 1;
    swip.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swip];
    
    UISwipeGestureRecognizer *swip0 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    swip0.numberOfTouchesRequired = 1;
    swip0.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swip0];
    
    UIImage *bgimg = [UIImage imageNamed:[[NSBundle mainBundle] pathForResource:@"2" ofType:@"jpg"]];
    UIImageView *image = [[UIImageView alloc] initWithFrame:_blurView.blurProviderView.frame];
    [image setImage:bgimg];
//    _blurView.autoTransiton = YES;
    [_blurView setTransitionView:image];
    
    _blurView.blurEnable = YES;
    [_blurView blurAsync:NO completion:^{
        NSLog(@"completion");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)swipeAction:(UISwipeGestureRecognizer *)swip
{
    if (swip.direction == UISwipeGestureRecognizerDirectionRight) {
       [_blurView blurTransition:9.0];
    }else if(swip.direction == UISwipeGestureRecognizerDirectionLeft){
       [_blurView blurTransition:-9.0];
    }
   
}

@end
