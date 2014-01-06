//
//  TwitterDisplayViewController.m
//  Bringo
//
//  Created by Nehru Sathappan on 5/13/13.
//  Copyright (c) 2013 Nehru Sathappan. All rights reserved.
//

#import "TwitterDisplayViewController.h"

@interface TwitterDisplayViewController ()

@end

@implementation TwitterDisplayViewController
@synthesize displayImage = _displayImage;
@synthesize displayLabel = _displayLabel;
@synthesize currentPhoto = _currentPhoto;

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
    self.displayLabel.text = [self.currentPhoto message];
    
    
    NSURL *url1 = [NSURL URLWithString:[_currentPhoto photoURL]];
    NSData *data1 = [[NSData alloc ]initWithContentsOfURL:url1];
    UIImage *image1 = [[UIImage alloc ]initWithData:data1];
    //  NSLog(@"image1 = %@",image1);
    //self.displayImage.contentMode = UIViewContentModeScaleAspectFit;
    //self.displayImage.clipsToBounds = YES;
    
    //NSLog(@"photoURL %@",[_currentPhoto photoURL]);
    
    [self.displayImage setImage:image1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
