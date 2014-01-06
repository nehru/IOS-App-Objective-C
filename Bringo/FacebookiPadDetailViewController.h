//
//  FacebookiPadDetailViewController.h
//  Bringo
//
//  Created by Nehru Sathappan on 5/20/13.
//  Copyright (c) 2013 Nehru Sathappan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@interface FacebookiPadDetailViewController : UIViewController 

@property (weak, nonatomic) IBOutlet UITextView *facebookiPadLabel;
@property (weak, nonatomic) IBOutlet UIImageView *facebookiPadImage;
@property (weak, nonatomic)Photo *currentPhoto;

@end
