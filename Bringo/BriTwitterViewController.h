//
//  BriTwitterViewController.h
//  Bringo
//
//  Created by Nehru Sathappan on 5/19/13.
//  Copyright (c) 2013 Nehru Sathappan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@interface BriTwitterViewController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *twitteriPadTableView;
@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSDictionary *tweet;
@property (strong, nonatomic) NSMutableArray *twitteriPadphotos;
@property (strong,nonatomic) Photo *tt;
@property BOOL newMedia;
@property (weak, nonatomic) IBOutlet UITextView *twitteriPadTextView;
@property (weak, nonatomic) IBOutlet UIImageView *currentPhoto;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
- (IBAction)pickPhoto:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *toggleCamera;
@property (nonatomic, strong) IBOutlet UIPopoverController *poc;
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;

- (IBAction)makeKeyboardGoAway:(id)sender;

- (IBAction)postMessageAndPhoto:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *postButton;

-(void)passwordCheck;
- (void)getTimeLine;
- (void)readProfile;
@end
