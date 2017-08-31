//
//  ViewController.h
//  LxThroughPointsBezierDemo
//

#import <UIKit/UIKit.h>

@interface BezierViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *pointViewArray;
@property (nonatomic, strong) NSArray *points;

- (id)initWithPoints:(NSArray *)points withColor:(UIColor *)color;
- (void)pointsChanged;

@end

