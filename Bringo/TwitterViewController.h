//
//  TwitterViewController.h
//  Bringo
//
//  Created by Nehru Sathappan on 5/10/13.
//  Copyright (c) 2013 Nehru Sathappan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwitterViewController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSDictionary *tweet;
@property (weak, nonatomic) IBOutlet UITextView *TwitterTextView;
@property (weak, nonatomic) IBOutlet UIImageView *currentPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;
@property (weak, nonatomic) IBOutlet UISwitch *toggleCamera;
@property (weak, nonatomic) IBOutlet UITableView *tweetTableView;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;


@property (weak, nonatomic) IBOutlet UIButton *postButton;

@property (weak, nonatomic) IBOutlet UITableView *TwitterTable;
@property (strong, nonatomic) NSArray *dataSource;
@property BOOL newMedia;

- (IBAction)PostMessageAndPhoto:(id)sender;

- (IBAction)pickPhoto:(id)sender;
- (IBAction)makeKeyboardGoAway:(id)sender;




@end
