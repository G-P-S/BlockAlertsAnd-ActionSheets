//
//  BlockActionSheet.m
//
//

#import "BlockActionSheet.h"
#import "BlockBackground.h"

@implementation BlockActionSheet
{
    NSInteger _cancelButtonIndex;
}

@synthesize view = _view;

static UIImage *background = nil;
static UIFont *titleFont = nil;
static UIFont *buttonFont = nil;

#define kBounce         10
#define kBorder         10
#define kButtonHeight   45
#define kTopMargin      15

#define kActionSheetBackground   @"action-sheet-panel.png"
#define kActionSheetBackgroundCapHeight  30

#pragma mark - init

+ (void)initialize
{
    if (self == [BlockActionSheet class])
    {
        background = [UIImage imageNamed:kActionSheetBackground];
        background = [[background stretchableImageWithLeftCapWidth:0 topCapHeight:kActionSheetBackgroundCapHeight] retain];
        titleFont = [[UIFont systemFontOfSize:18] retain];
        buttonFont = [[UIFont boldSystemFontOfSize:20] retain];
    }
}

+ (id)sheetWithTitle:(NSString *)title
{
    return [[[BlockActionSheet alloc] initWithTitle:title] autorelease];
}

- (void)setViewTransform:(UIView*)view forOrientation:(UIInterfaceOrientation)orientation
{
    switch(orientation)
    {
        case UIInterfaceOrientationPortrait:
            view.transform = CGAffineTransformMakeRotation(0);
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            view.transform = CGAffineTransformMakeRotation((-2) *M_PI/2);
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            view.transform = CGAffineTransformMakeRotation(M_PI/2);
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            view.transform = CGAffineTransformMakeRotation((-1) * M_PI/2);
            break;
    }
}

- (id)initWithTitle:(NSString *)title
{
    if ((self = [super init]))
    {
        _title = [title retain];
        _blocks = [[NSMutableArray alloc] init];
        _view = [[UIView alloc] initWithFrame:CGRectZero];
        _cancelButtonIndex = -1;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];

    }
    return self;
}

- (void)setupTitleLabel
{
    _height = kTopMargin;
    CGRect frame = [BlockBackground sharedInstance].bounds;
    if (_title)
    {
        CGSize size = [_title sizeWithFont:titleFont
                         constrainedToSize:CGSizeMake(frame.size.width-kBorder*2, 1000)
                             lineBreakMode:UILineBreakModeWordWrap];
        
        UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(kBorder, _height, frame.size.width-kBorder*2, size.height)];
        labelView.font = titleFont;
        labelView.numberOfLines = 0;
        labelView.lineBreakMode = UILineBreakModeWordWrap;
        labelView.textColor = [UIColor whiteColor];
        labelView.backgroundColor = [UIColor clearColor];
        labelView.textAlignment = UITextAlignmentCenter;
        labelView.shadowColor = [UIColor blackColor];
        labelView.shadowOffset = CGSizeMake(0, -1);
        labelView.text = _title;
        [_view addSubview:labelView];
        [labelView release];
        
        _height += size.height + 5;
    }
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_title release];
    [_view release];
    [_blocks release];
    [super dealloc];
}

- (NSUInteger)buttonCount
{
    return _blocks.count;
}

- (void)addButtonWithTitle:(NSString *)title color:(NSString*)color block:(void (^)())block atIndex:(NSInteger)index
{
    if (index >= 0)
    {
        [_blocks insertObject:[NSArray arrayWithObjects:
                               block ? [[block copy] autorelease] : [NSNull null],
                               title,
                               color,
                               nil]
                      atIndex:index];
    }
    else
    {
        [_blocks addObject:[NSArray arrayWithObjects:
                            block ? [[block copy] autorelease] : [NSNull null],
                            title,
                            color,
                            nil]];
    }
}

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"red" block:block atIndex:-1];
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"black" block:block atIndex:-1];
    if(_cancelButtonIndex == -1) _cancelButtonIndex = [_blocks count] - 1;
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block 
{
    [self addButtonWithTitle:title color:@"gray" block:block atIndex:-1];
}

- (void)setDestructiveButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"red" block:block atIndex:index];
}

- (void)setCancelButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"black" block:block atIndex:index];
    if(_cancelButtonIndex == -1) _cancelButtonIndex = [_blocks count] - 1;
}

- (void)addButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block 
{
    [self addButtonWithTitle:title color:@"gray" block:block atIndex:index];
}

- (void)setupButtons
{
    NSUInteger i = 1;
    for (NSArray *block in _blocks)
    {
        NSString *title = [block objectAtIndex:1];
        NSString *color = [block objectAtIndex:2];
        
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"action-%@-button.png", color]];
        image = [image stretchableImageWithLeftCapWidth:(int)(image.size.width)>>1 topCapHeight:0];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(kBorder, _height, _view.bounds.size.width-kBorder*2, kButtonHeight);
        button.titleLabel.font = buttonFont;
        button.titleLabel.minimumFontSize = 6;
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.textAlignment = UITextAlignmentCenter;
        button.titleLabel.shadowOffset = CGSizeMake(0, -1);
        button.backgroundColor = [UIColor clearColor];
        button.tag = i++;
        
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        button.accessibilityLabel = title;
        
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_view addSubview:button];
        _height += kButtonHeight + kBorder;
    }
}

- (void)showInView:(UIView *)view
{
    BlockBackground* blockBackground = [BlockBackground sharedInstance];
    
    [self setViewTransform:blockBackground forOrientation:blockBackground.orientation];
    [blockBackground sizeToFill];
    
    CGRect blockRect = blockBackground.bounds;
    _view.bounds = blockRect;
    
    [self setupTitleLabel];
    [self setupButtons];
    
    UIImageView *modalBackground = [[UIImageView alloc] initWithFrame:_view.bounds];
    modalBackground.image = background;
    modalBackground.contentMode = UIViewContentModeScaleToFill;
    [_view insertSubview:modalBackground atIndex:0];
    [modalBackground release];
    
    [blockBackground addToMainWindow:_view];
    
    CGFloat viewHeight = _height + kTopMargin;
    _view.bounds = CGRectMake(_view.bounds.origin.x, _view.bounds.origin.y, _view.bounds.size.width, viewHeight + kBorder);
    CGFloat center_x = blockRect.size.width/2;
    CGFloat center_finish_y = blockRect.size.height - (viewHeight / 2) + (blockBackground.statusBarHeight / 2);
    CGPoint centerStart = CGPointMake(center_x, blockRect.size.height + viewHeight/2);
    CGPoint centerFinish = CGPointMake(center_x, blockRect.size.height - viewHeight/2);

    _view.center = centerStart;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         _view.center = centerFinish;
                         [BlockBackground sharedInstance].alpha = 1.0f;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1
                                               delay:0.0
                                             options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              _view.center = CGPointMake(center_x, center_finish_y + kBounce);
                                          } completion: nil];
                     }];
    
    [self retain];
}

- (void)orientationDidChange
{
    // on orientation change, just cancel the alert ... cheap way out 
    if(_cancelButtonIndex != -1)
    {
        [self dismissWithClickedButtonIndex:_cancelButtonIndex animated:YES];
    }
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    if (buttonIndex >= 0 && buttonIndex < [_blocks count])
    {
        id obj = [[_blocks objectAtIndex: buttonIndex] objectAtIndex:0];
        if (![obj isEqual:[NSNull null]])
        {
            ((void (^)())obj)();
        }
    }
    
    if (animated)
    {
        CGPoint center = _view.center;
        center.y += _view.bounds.size.height;
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             _view.center = center;
                             [[BlockBackground sharedInstance] reduceAlphaIfEmpty];
                         } completion:^(BOOL finished) {
                             [[BlockBackground sharedInstance] removeView:_view];
                             [_view release]; _view = nil;
                             [self autorelease];
                         }];
    }
    else
    {
        [[BlockBackground sharedInstance] removeView:_view];
        [_view release]; _view = nil;
        [self autorelease];
    }
}

#pragma mark - Action

- (void)buttonClicked:(id)sender 
{
    /* Run the button's block */
    int buttonIndex = [sender tag] - 1;
    [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end
