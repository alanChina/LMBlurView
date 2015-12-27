//
//  LMBlurView.m
//  LMBlurView
//
//  Created by by on 15/12/26.
//  Copyright © 2015年 dlm. All rights reserved.
//

#import "LMBlurView.h"
#import "UIImage+Helper.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#pragma mark ---- blur layer
@interface LMBlurLayer : CALayer
@property (nonatomic, assign) CGFloat blurRadius;           //图片半径
@end

@implementation LMBlurLayer

/**
 *  layer属性改变时是否需要重新绘制
 *
 *  @param key 变动的属性
 *
 *  @return 默认NO，YES表示需要重新绘制
 */
+(BOOL)needsDisplayForKey:(NSString *)key
{
    if ([@[@"blurRadius", @"bounds", @"position"] containsObject:key]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

@end

#pragma mark ---- blur view

@interface LMBlurView ()

@property (nonatomic, assign) BOOL needsDrawViewHierarchy;      //模糊视图提供者的层级上是否需要重新绘制
@property (nonatomic, strong) LMBlurLayer *transitionLayer;         //过渡视图层
@property (nonatomic, strong) CADisplayLink *link;

@end

@implementation LMBlurView

#pragma mark -------- override
- (id)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])){
        [self setUp];
        self.clipsToBounds = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super initWithCoder:aDecoder])){
        [self setUp];
    }
    return self;
}

+(Class)layerClass{
    return [LMBlurLayer class];
}

- (void)setNeedsDisplay{
    [super setNeedsDisplay];
    [self.layer setNeedsDisplay];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (!_blurProviderView){
        _needsDrawViewHierarchy = [self viewOrSubviewNeedsDrawViewHierarchy:newSuperview];
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self.layer setNeedsDisplay];
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
}

#pragma mark ---- delegate
/**
 *  显示图层代理，layer -display 方法调用， layer -setNeedsDisplay会调用-display
 *
 *  @param layer
 */
-(void)displayLayer:(CALayer *)layer{
    [self blurAsync:NO completion:NULL];
}

- (nullable id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event{
    if ([event isEqualToString:@"blurRadius"]){
        //animations are enabled
        CAAnimation *action = (CAAnimation *)[super actionForLayer:layer forKey:@"backgroundColor"];
        if ((NSNull *)action != [NSNull null]){
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:event];
            animation.fromValue = [layer.presentationLayer valueForKey:event];
            
            //CAMediatiming attributes
            animation.beginTime = action.beginTime;
            animation.duration = action.duration;
            animation.speed = action.speed;
            animation.timeOffset = action.timeOffset;
            animation.repeatCount = action.repeatCount;
            animation.repeatDuration = action.repeatDuration;
            animation.autoreverses = action.autoreverses;
            animation.fillMode = action.fillMode;
            
            //CAAnimation attributes
            animation.timingFunction = action.timingFunction;
            animation.delegate = action.delegate;
            
            return animation;
        }
    }
    return [super actionForLayer:layer forKey:event];
}

#pragma mark --- public 
- (void)blurAsync:(BOOL)async completion:(void (^)())completion{
    [self blurAsync:async isTransition:NO completion:completion];
}

- (void)blurTransition:(CGFloat)byValue
{
    if (byValue < 0) {
        byValue = -(fabs(byValue) <= 0.01 ? : fabs(byValue) / 100.0f);
    }else{
        byValue = byValue <= 0.01 ? : byValue / 100.0f;
    }
    
    self.transitionLayer.opacity += byValue;
    
}

- (void)clearBlurImage{
    self.layer.contents = nil;
    [self setNeedsDisplay];
}

#pragma mark --- setter getter
-(UIView *)blurProviderView{
    return _blurProviderView ? : self.superview;
}

-(void)setBlurProviderView:(UIView *)blurProviderView{
    _blurProviderView = blurProviderView;
    _needsDrawViewHierarchy = [self viewOrSubviewNeedsDrawViewHierarchy:self.blurProviderView];
    [self setNeedsDisplay];
}

- (void)setBlurRadius:(CGFloat)blurRadius
{
    [self blurLayer].blurRadius = blurRadius;
    [self setNeedsDisplay];
}

- (CGFloat)blurRadius
{
    return [self blurLayer].blurRadius;
}

-(void)setBlurLevel:(NSUInteger)blurLevel
{
    _blurLevel = blurLevel;
}

-(NSUInteger)blurLevel{
    return _blurLevel;
}

-(void)setTransitionView:(UIView *)transitionView
{
    _transitionView = transitionView;
    self.transitionLayer = [LMBlurLayer layer];
    self.transitionLayer.opacity = 0.0f;
    self.transitionLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    [self.transitionLayer addObserver:self forKeyPath:@"opacity" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew  context:NULL];
    [self.layer addSublayer:self.transitionLayer];
    [self blurAsync:YES isTransition:YES completion:NULL];
}

-(UIView *)transitionView
{
    return _transitionView;
}

-(void)setAutoTransiton:(BOOL)autoTransiton
{
    _autoTransiton = autoTransiton;
}

-(BOOL)autoTransiton
{
    return _autoTransiton;
}

-(void)setBlurEnable:(BOOL)blurEnable
{
    _blurEnable = blurEnable;
}

-(BOOL)isBlurEnable
{
    return _blurEnable;
}

#pragma mark --- private
-(void)setUp{
    self.blurRadius = 60;
    self.blurLevel = 3;
    self.layer.magnificationFilter = @"linear"; // kCAFilterLinear
    
    unsigned int numberOfMethods;
    Method *methods = class_copyMethodList([UIView class], &numberOfMethods);
    for (unsigned int i = 0; i < numberOfMethods; i++){
        Method method = methods[i];
        SEL selector = method_getName(method);
        if (selector == @selector(tintColor)){
            _tintColor = ((id (*)(id,SEL))method_getImplementation(method))(self, selector);
            break;
        }
    }
    free(methods);
}

- (LMBlurLayer *)blurLayer{
    return (LMBlurLayer *)self.layer;
}

/**
 *  获取当前显示的图层
 *
 *  @return 当前显示的图层对象
 */
- (LMBlurLayer *)blurPresentationLayer{
    LMBlurLayer *blurLayer = [self blurLayer];
    return (LMBlurLayer *)blurLayer.presentationLayer ?: blurLayer;
}

/**
 *  获取模糊视图提供者的layer
 *
 *  @return layer
 */
- (CALayer *)blurProviderViewLayer{
    return self.blurProviderView.layer;
}

-(CALayer *)transitionViewLayer
{
    return self.transitionView.layer;
}

- (BOOL)viewOrSubviewNeedsDrawViewHierarchy:(UIView *)view{
    if ([view isKindOfClass:NSClassFromString(@"SKView")] || [view.layer isKindOfClass:NSClassFromString(@"CAEAGLLayer")] || [view.layer isKindOfClass:NSClassFromString(@"AVPlayerLayer")] || ABS(view.layer.transform.m34) > 0){
        return YES;
    }
    for (UIView *subview in view.subviews){
        if ([self viewOrSubviewNeedsDrawViewHierarchy:subview]){
            return YES;
        }
    }
    return  NO;
}
- (NSArray *)hideEmptyLayers:(CALayer *)layer
{
    NSMutableArray *layers = [NSMutableArray array];
    if (CGRectIsEmpty(layer.bounds)){
        layer.hidden = YES;
        [layers addObject:layer];
    }
    for (CALayer *sublayer in layer.sublayers){
        [layers addObjectsFromArray:[self hideEmptyLayers:sublayer]];
    }
    return layers;
}

- (NSArray *)prepareUnderlyingViewForSnapshot
{
    __strong CALayer *blurlayer = [self blurLayer];
    __strong CALayer *blurProviderViewLayer = [self blurProviderViewLayer];
    while (blurlayer.superlayer && blurlayer.superlayer != blurProviderViewLayer){
        blurlayer = blurlayer.superlayer;
    }
    NSMutableArray *layers = [NSMutableArray array];
    NSUInteger index = [blurProviderViewLayer.sublayers indexOfObject:blurlayer];
    if (index != NSNotFound){
        for (NSUInteger i = index; i < [blurProviderViewLayer.sublayers count]; i++){
            CALayer *layer = blurProviderViewLayer.sublayers[i];
            if (!layer.hidden){
                layer.hidden = YES;
                [layers addObject:layer];
            }
        }
    }
    
    //also hide any sublayers with empty bounds to prevent a crash on iOS 8
    [layers addObjectsFromArray:[self hideEmptyLayers:blurProviderViewLayer]];
    
    return layers;
}

- (void)restoreSuperviewAfterSnapshot:(NSArray *)hiddenLayers
{
    for (CALayer *layer in hiddenLayers){
        layer.hidden = NO;
    }
}

- (BOOL)shouldUpdate
{
    __strong CALayer *blurProviderViewLayer = [self blurProviderViewLayer];
    
    return blurProviderViewLayer && !blurProviderViewLayer.hidden && _blurEnable && !CGRectIsEmpty([self.layer.presentationLayer ?: self.layer bounds]) && !CGRectIsEmpty(blurProviderViewLayer.bounds);
}

/**
 *  获取视图的截图
 *
 *  @param view 作为模糊图片的视图
 *
 *  @return 该视图的截图
 */
- (UIImage *)snapshotOfBlurProviderView:(BOOL)isTransitionView
{
    /*
    UIGraphicsBeginImageContext(self.blurProviderView.bounds.size);
    [self.blurProviderView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData * data = UIImagePNGRepresentation(image);
    
    return [UIImage imageWithData:data];
    */
    __strong LMBlurLayer *blurLayer = [self blurPresentationLayer];
    __strong CALayer *blurViewLayer = isTransitionView ? [self transitionView].layer : [self blurProviderViewLayer];
    CGRect bounds = [blurLayer convertRect:blurLayer.bounds toLayer:blurViewLayer];
    CGFloat scale = 0.5;
    CGSize size = bounds.size;
    if (self.contentMode == UIViewContentModeScaleToFill || self.contentMode == UIViewContentModeScaleAspectFill || self.contentMode == UIViewContentModeScaleAspectFit || self.contentMode == UIViewContentModeRedraw) {
        //prevents edge artefacts
        size.width = floor(size.width * scale) / scale;
        size.height = floor(size.height * scale) / scale;
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0 && [UIScreen mainScreen].scale == 1.0){
        //prevents pixelation on old devices
        scale = 1.0;
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context){
//        CGContextTranslateCTM(context, -bounds.origin.x, -bounds.origin.y);
        NSArray *hiddenViews = [self prepareUnderlyingViewForSnapshot];
        if (self.needsDrawViewHierarchy){
            __strong UIView *blurProviderView = self.blurProviderView;
            [blurProviderView drawViewHierarchyInRect:blurProviderView.bounds afterScreenUpdates:YES];
        }else{
            [blurViewLayer renderInContext:context];
        }
        [self restoreSuperviewAfterSnapshot:hiddenViews];
        UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
       
        return snapshot;
    }
    return nil;
}

/**
 *  更新图层内容
 *
 *  @param image 图片对象
 */
-(void)updateLayerContent:(UIImage *)image isTransition:(BOOL)isTransition
{
    if (isTransition) {
        self.transitionLayer.contents = (id)image.CGImage;
        self.transitionLayer.contentsScale = image.scale;
        if (_autoTransiton) {
            self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateOpacity)];
            [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
    }else{
        self.layer.contents = (id)image.CGImage;
        self.layer.contentsScale = image.scale;
    }
}

-(void)updateOpacity
{
    self.transitionLayer.opacity = self.transitionLayer.opacity + 0.01f;
}
/**
 *  模糊图片显示
 *
 *  @param async        是否异步
 *  @param isTransition 是否过渡的显示
 *  @param completion   完成回调
 */
- (void)blurAsync:(BOOL)async isTransition:(BOOL)isTransition completion:(void (^)())completion{
    if ([self shouldUpdate]) {
        UIImage *blurProviderViewSnapshot = [self snapshotOfBlurProviderView:isTransition];
        if (async) {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *blurredImage = [blurProviderViewSnapshot blurredImageWithRadius:weakSelf.blurRadius blurLevel:weakSelf.blurLevel tintColor:weakSelf.tintColor];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [weakSelf updateLayerContent:blurredImage isTransition:isTransition];
                    if (completion) completion();
                });
            });
            return;
        }
        [self updateLayerContent:[blurProviderViewSnapshot blurredImageWithRadius:self.blurRadius/*[[self blurPresentationLayer] blurRadius]*/ blurLevel:self.blurLevel tintColor:self.tintColor] isTransition:isTransition];
        if (completion) completion();
    }
    
    if (completion) completion();
}

#pragma mark ------ tansition layer opacity kvo
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    NSLog(@"self.transitionLayer.opacity ==> %f",self.transitionLayer.opacity);
    BOOL shouldDisplayWithLink = NO;
    if (self.transitionLayer.opacity >= 1.0f) {
        shouldDisplayWithLink = YES;
        [self.transitionLayer removeObserver:self forKeyPath:@"opacity"];
        self.layer.contents = self.transitionLayer.contents;
        self.layer.contentsScale = self.transitionLayer.contentsScale;
        [self.transitionLayer removeFromSuperlayer];
        self.transitionLayer = nil;
    }else if(self.transitionLayer.opacity <= 0){
        shouldDisplayWithLink = YES;
        [self.transitionLayer removeObserver:self forKeyPath:@"opacity"];
        [self.transitionLayer removeFromSuperlayer];
        self.transitionLayer = nil;
    }
    
    if (shouldDisplayWithLink && _autoTransiton && self.link) {
        [self.link invalidate];
        [self.link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.autoTransiton = NO;
        self.link = nil;
    }
}

@synthesize blurProviderView = _blurProviderView;
@synthesize blurRadius = _blurRadius;
@synthesize blurLevel = _blurLevel;
@synthesize transitionView = _transitionView;
@synthesize autoTransiton = _autoTransiton;
@synthesize blurEnable = _blurEnable;

@end
