//
//  FacebookDisplayViewController.h
//  Bringo
//
//  Created by Nehru Sathappan on 5/17/13.
//  Copyright (c) 2013 Nehru Sathappan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@interface FacebookDisplayViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *displayImage;
@property (weak, nonatomic) IBOutlet UITextView *displayLabel;
@property (nonatomic, strong) Photo *currentPhoto;
@end
