//
//  FlickrPhotoImageViewController.m
//  Shutterbug
//
//  Created by Norimasa Nabeta on 2012/07/26.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "FlickrPhotoImageViewController.h"

@interface FlickrPhotoImageViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation FlickrPhotoImageViewController
@synthesize toolbar;
@synthesize imageView;
@synthesize scrollView;
@synthesize splitViewBarButtonItem=_splitViewBarButtonItem;

// http://stackoverflow.com/questions/3739996/reload-the-view-in-iphone-in-viewwillappear
-(void) resetView
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    // http://stackoverflow.com/questions/11587513/how-to-center-uiactivityindicator
    //spinner.center = self.view.center;
    spinner.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    // http://stackoverflow.com/questions/8585715/could-not-resize-the-activity-indicator-in-ios-5-0
    spinner.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
    [spinner startAnimating];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [self.imageView addSubview:spinner];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr image downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSData *photo = [NSData dataWithContentsOfURL:self.urlPhoto];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = [UIImage imageWithData:photo];
            self.scrollView.contentSize=self.imageView.image.size;
            self.imageView.frame=CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
            [spinner removeFromSuperview];
        });
    });
    dispatch_release(downloadQueue);
    [self.view setNeedsDisplay];
}

- (void) setUrlPhoto:(NSURL *)urlPhoto
{
    if(_urlPhoto != urlPhoto){
        _urlPhoto = urlPhoto;
        [self resetView];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [self resetView];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [self setToolbar:nil];
    [self setToolbar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - SplitViewBarButtonItemPresenter
- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}


-(void) awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate=self;
}

#pragma mark - UISplitViewControllerDelegate
-(id <SplitViewBarButtonItemPresenter>) splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}

-(BOOL) splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}
-(void) splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = self.title;
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
    
}

-(void) splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

@end
