//
//  FlickrPhotoImageViewController.h
//  Shutterbug
//
//  Created by Norimasa Nabeta on 2012/07/26.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrPhotoImageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) NSURL *urlPhoto;
@end
