//
//  FacebookViewController.h
//  Bringo
//
//  Created by Nehru Sathappan on 5/14/13.
//  Copyright (c) 2013 Nehru Sathappan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FacebookViewController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UITextView *facebookTextView;

@property (weak, nonatomic) IBOutlet UIImageView *currentPhoto;

@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;
@property (weak, nonatomic) IBOutlet UITableView *facebookTableView;
@property (nonatomic)BOOL logStaus;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property BOOL newMedia;
@property (weak, nonatomic) IBOutlet UIButton *photo;

- (IBAction)takePhoto:(id)sender;

-(void)readProfile;
-(void)getTimeLine;
- (void)showAlert:(NSString *)message result:(id)result error:(NSError *)error;
- (IBAction)pickPhoto:(id)sender;
- (IBAction)makeKeyboardGoaway:(id)sender;
- (IBAction)postMessageAndPhoto:(id)sender;

@end
