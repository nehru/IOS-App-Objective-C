//
//  FacebookiPadDetailViewController.m
//  Bringo
//
//  Created by Nehru Sathappan on 5/20/13.
//  Copyright (c) 2013 Nehru Sathappan. All rights reserved.
//

#import "FacebookiPadDetailViewController.h"

@interface FacebookiPadDetailViewController ()

@end

@implementation FacebookiPadDetailViewController

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
    self.facebookiPadLabel.text = [self.currentPhoto message];
    
    NSURL *url1 = [NSURL URLWithString:[_currentPhoto photoURL]];
    NSData *data1 = [[NSData alloc ]initWithContentsOfURL:url1];
    UIImage *image1 = [[UIImage alloc ]initWithData:data1];
    [self.facebookiPadImage setImage:image1];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
