//
//  BriFacebookViewController.h
//  Bringo
//
//  Created by Nehru Sathappan on 5/19/13.
//  Copyright (c) 2013 Nehru Sathappan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface BriFacebookViewController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource, UITableViewDelegate,UIPopoverControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *facebookiPadTableView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;
@property (weak, nonatomic) IBOutlet UIImageView *currentPhoto;
- (IBAction)pickPhoto:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
- (IBAction)takePhoto:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *photo;

@property (weak, nonatomic) IBOutlet UITextView *facebookTextView;
- (IBAction)postMessageAndPhoto:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property BOOL newMedia;
@property (nonatomic, strong) IBOutlet UIPopoverController *poc;
  
-(void)readProfile;
-(void)getTimeLine;
- (void)showAlert:(NSString *)message result:(id)result error:(NSError *)error;

- (IBAction)makeKeyboardGoAway:(id)sender;


@end
