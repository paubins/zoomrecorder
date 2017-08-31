//
//  ViewController.m
//  LxThroughPointsBezierDemo
//

#import "BezierViewController.h"
#import "UIBezierPath+LxThroughPointsBezier.h"

@interface BezierViewController ()

@end

@implementation BezierViewController
{
    UIBezierPath * _curve;
    CAShapeLayer * _shapeLayer;
    UIColor *_lineColor;
}

- (id)initWithPoints:(NSArray *)points withColor:(UIColor *)color
{
    if (self = [super init]) {
        self.points = points;
        _lineColor = color;
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _pointViewArray = [[NSMutableArray alloc]init];

    _curve = [UIBezierPath bezierPath];
    
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.strokeColor = _lineColor.CGColor;
    _shapeLayer.fillColor = nil;
    _shapeLayer.lineWidth = 5;
    _shapeLayer.path = _curve.CGPath;
    _shapeLayer.lineCap = kCALineCapButt;
    _shapeLayer.shadowPath = _curve.CGPath;
    _shapeLayer.shadowColor = [UIColor blackColor].CGColor;
    
    [self.view.layer addSublayer:_shapeLayer];
}

- (void)pointsChanged
{
    [_curve removeAllPoints];
    _curve.contractionFactor = 0.7;
    
    [_curve moveToPoint:[self.points.firstObject CGPointValue]];
    [_curve addBezierThroughPoints:self.points];
    
    _shapeLayer.path = _curve.CGPath;
}

@end
