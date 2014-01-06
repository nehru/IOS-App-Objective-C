//
//  TwitteriPadDetailViewController.h
//  Bringo
//
//  Created by Nehru Sathappan on 5/19/13.
//  Copyright (c) 2013 Nehru Sathappan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@interface TwitteriPadDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *displayiPadImage;
@property (weak, nonatomic) IBOutlet UITextView *displayiPadLabel;
@property (weak, nonatomic)Photo *currentPhoto;
@end
