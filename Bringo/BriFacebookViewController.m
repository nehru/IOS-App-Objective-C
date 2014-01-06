//
//  BriFacebookViewController.m
//  Bringo
//
//  Created by Nehru Sathappan on 5/19/13.
//  Copyright (c) 2013 Nehru Sathappan. All rights reserved.
//

#import "BriFacebookViewController.h"
#import <objc/runtime.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FacebookPhoto.h"
#import "BriFacebookTableViewCell.h"
#import "FacebookiPadDetailViewController.h"
#import "Global.h"


@interface BriFacebookViewController () <FBLoginViewDelegate>

@end

static char titleKey;

@implementation UIImageView(Title)
- (NSString *)title
{
    return objc_getAssociatedObject(self, &titleKey);
}

- (void)setTitle:(NSString *)title
{
    objc_setAssociatedObject(self, &titleKey, title, OBJC_ASSOCIATION_COPY);
}
@end




@implementation BriFacebookViewController
UIActivityIndicatorView *activity;
NSMutableArray *facebookiPadPhotos;
UIButton * loginButton;
UILabel * loginLabel;
UIImagePickerController *imagePicker;
@synthesize poc = _poc;

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
    
    
    
    facebookiPadPhotos = [[NSMutableArray alloc]init];
    
    FBLoginView *loginview = [[FBLoginView alloc] init];
    loginview.frame = CGRectMake(250, 25, 90, 50);
    
    
    for (id obj in loginview.subviews)
    {
        if ([obj isKindOfClass:[UIButton class]])
        {
            loginButton =  obj;
            UIImage *loginImage = [UIImage imageNamed:@"cube2.png"];
            [loginButton setBackgroundImage:loginImage forState:UIControlStateNormal];
            [loginButton setBackgroundImage:nil forState:UIControlStateSelected];
            [loginButton setBackgroundImage:nil forState:UIControlStateHighlighted];
            [loginButton sizeToFit];
            
            //self.navigationController.navigationItem.rightBarButtonItem = loginButton;
        }
        if ([obj isKindOfClass:[UILabel class]])
        {
            UILabel * loginLabel =  obj;
            //loginLabel.text = @"Log In";
            
            
            loginLabel.textAlignment = NSTextAlignmentCenter;
            loginLabel.frame = CGRectMake(10, 10, 80, 37);
        }
    }
    
    
    
    loginview.delegate = self;
    [self.view addSubview:loginview];
    [loginButton sizeToFit];
    
    
    self.postButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.photo.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.uploadButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    
    activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activity.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    //activity.center = CGPointMake(self.view.center.x,self.view.center.y-180);
    activity.center = CGPointMake(self.view.center.x,self.view.center.y-320);
    activity.color =[UIColor blueColor];
    [self.view addSubview:activity];
    
    //category for UIImage
    [self.currentPhoto setTitle:@"12650188.gif"];
    self.currentPhoto.image = [UIImage imageNamed:[self.currentPhoto title]];
    
    
    
    if(FBSession.activeSession.isOpen == false){
        //NSLog(@"it is open false");
        
        self.uploadButton.enabled = NO;
        self.postButton.enabled = NO;
        self.photo.enabled = NO;
    }
    
    Global *gl = [[Global alloc]init];
    BOOL flg = [gl start];
    
    if(flg == false){
        [activity stopAnimating];
    }
    
    
    
    
    //[self getTimeLine];
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error{
    
    
    [[[UIAlertView alloc] initWithTitle:@"MESSAGE"
                                message:@"Please setup username and password in the iPhone settings"
                               delegate:self
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil]show];
    
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView{
    
    loginLabel.text = @"Log Out";
    self.uploadButton.enabled = YES;
    self.uploadButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.postButton.enabled = YES;
    self.postButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.photo.enabled = YES;
    self.photo.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    [self readProfile];
    [self getTimeLine];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView{
    
    
    loginLabel.text = @"Log In";
    [activity stopAnimating];
    
    
    self.uploadButton.enabled = NO;
    self.uploadButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    self.postButton.enabled = NO;
    self.postButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    self.photo.enabled = NO;
    self.photo.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    
    [FBSession.activeSession closeAndClearTokenInformation];
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"FacebookDisplayID"]){
        FacebookiPadDetailViewController *fdc = [segue destinationViewController];
        NSIndexPath *path = [self.facebookiPadTableView indexPathForSelectedRow];
        Photo *tt = [facebookiPadPhotos objectAtIndex:[path row]];
        [fdc setCurrentPhoto:tt];
        
        
    }
    
    
}

-(void)readProfile{
    
    [activity startAnimating];
    NSString *query = @"SELECT pic FROM user WHERE uid = me()";
    NSDictionary *queryParam = [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
    
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
     {
         
         if(error)
         {
             NSLog(@"Debug --- Error: %@", [error localizedDescription]);
             [activity stopAnimating];
         }
         else
         {
             
             //NSLog(@"myresult = %@",result);
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [activity startAnimating];
             });
             NSMutableArray *rArray = [result objectForKey:@"data"];
             
             NSString *mprofile = [[rArray objectAtIndex:0] objectForKey:@"pic"];
            // NSLog(@"profile = %@",mprofile);
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSURL *url1 = [NSURL URLWithString:mprofile];
                 NSData *data1 = [[NSData alloc]initWithContentsOfURL:url1];
                 UIImage *image1 = [[UIImage alloc]initWithData:data1];
                 [self.profilePhoto setImage:image1];
                 
                 
                 
                 
                 
             });
             
             
             
         }
         
         
     }];//[FBRequestConnection
    
    
    
    
}



-(void)getTimeLine{
    
    
    
    NSString *query = @"SELECT attachment, post_id, message, created_time FROM stream WHERE source_id = me() order by post_id ASC LIMIT 0,50";
    
    //NSString *query = @"SELECT attachment, post_id, message, created_time FROM stream WHERE source_id = me() AND message != '' LIMIT 0,50";
    
    NSDictionary *queryParam = [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
    
    
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
     {
         
         //[NSThread sleepForTimeInterval:1.0];
         
         if(error)
         {
             NSLog(@"Error: %@", [error localizedDescription]);
         }
         else
         {
             
            // NSLog(@"myresult = %@",result);
             
             
             
             NSMutableArray *rArray = [result objectForKey:@"data"];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [activity startAnimating];
             });
             
             
             
             int count = [rArray count];
            // NSLog(@"data count = %d",count);
             
             [facebookiPadPhotos removeAllObjects];
             for(int i = 0;i<count;i++)
             {
                 NSDictionary *post = [rArray objectAtIndex:i];
                 NSDictionary *attachment = [post objectForKey:@"attachment"];
                 //  NSString *msg = [post objectForKey:@"message"];
                 
                 NSString *msg = [post objectForKey:@"message"];
                 
                 if([msg length] != 0){
                     
                    // NSLog(@"msg = %@",msg);
                     FacebookPhoto *pic = [[FacebookPhoto alloc]init];
                     [pic setMessage:msg];
                     [pic setPhotoURL:@""];
                     [facebookiPadPhotos addObject:pic];
                 }
                 
                 NSArray *array = [attachment objectForKey:@"media"];
                 
               //  NSLog(@"count = %d",[array count]);
                 
                 if([array count] == 0){
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [activity stopAnimating];
                         return;
                     });
                     
                 }
                 
                 for(int i=0;i<[array count];i++)
                 {
                     NSDictionary *media = [array objectAtIndex:i];
                     
                     FacebookPhoto *pic = [[FacebookPhoto alloc]init];
                     
                     NSString *tphoto = [media objectForKey:@"src"];
                     if(tphoto)
                         [pic setPhotoURL:tphoto];
                     
                     NSString *mmsg = [media objectForKey:@"alt"];
                     if(mmsg)
                         [pic setMessage:mmsg];
                     
                     
                     [facebookiPadPhotos addObject:pic];
                     
                 }
                 
             }
             
             if(facebookiPadPhotos.count != 0)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.facebookiPadTableView reloadData];
                  
                     self.facebookTextView.text = @"";
                     self.currentPhoto.image = [UIImage imageNamed:@"12650188.gif"];
                     
                     
                     
                     self.uploadButton.enabled = YES;
                     self.photo.enabled = YES;
                     self.postButton.enabled = YES;
                     // loginButton.enabled = YES;
                     self.uploadButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
                     self.photo.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
                     self.postButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
                     [activity stopAnimating];
                     
                 });
             }
             
             
         }
         
         
     }];//[FBRequestConnection
    
   // NSLog(@"Error getting data");
    /* dispatch_async(dispatch_get_main_queue(), ^{
     [activity stopAnimating];
     
     });*/
}

#pragma mark -
#pragma mark UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return facebookiPadPhotos.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"FacebookiPadCell";
    
    BriFacebookTableViewCell *cell = [self.facebookiPadTableView
                            dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[BriFacebookTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    FacebookPhoto *tt = [facebookiPadPhotos objectAtIndex:[indexPath row]];
    
    NSString *pt = [tt photoURL];
    if(pt != Nil)
    {
        
        NSURL *url = [NSURL URLWithString:pt];
        NSData *data = [[NSData alloc ]initWithContentsOfURL:url];
        UIImage *image = [[UIImage alloc ]initWithData:data];
        [cell.myImage setImage:image];
    }
    
    cell.myLabel.text =[tt message];
    
    return cell;
}

- (IBAction)pickPhoto:(id)sender {
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _newMedia = NO;
    
    imagePicker.delegate = self;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
   // [self presentViewController:imagePicker animated:YES completion:nil];
    
    self.poc = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
    [self.poc presentPopoverFromRect:((UIButton *)sender).bounds inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    

}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    if(self.poc){
        [self.poc dismissPopoverAnimated:YES];
    }
}

-(void)image:(UIImage *)image
finishedSaving:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    if(_newMedia){
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:finishedSaving:contextInfo:), nil);
        return;
    }
    else
    {
        self.currentPhoto.image = image;
        
        // get the ref url
        NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
        
        
        
        // define the block to call when we get the asset based on the url (below)
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
        {
            ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
          //  NSLog(@"[imageRep filename] : %@", [imageRep filename]);
            [self.currentPhoto setTitle:[imageRep filename]];
        };
        
        // get the asset library and fetch the asset based on the ref url (pass in block above)
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];
        
    }
    
}
- (IBAction)takePhoto:(id)sender {
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _newMedia = YES;
    
    imagePicker.delegate = self;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [self presentViewController:imagePicker animated:YES completion:nil];

    
}
- (IBAction)postMessageAndPhoto:(id)sender {
    
    
    [activity startAnimating];
    NSString *testMessage;
    NSMutableDictionary *params;
    NSString *fl;
    
    if(_newMedia == NO){
        
        testMessage = self.facebookTextView.text;
       // NSLog(@"test = %@",testMessage);
        //  UIImage *curImg = self.currentPhoto.image;
       // NSLog(@"image = %@",[self.currentPhoto title]);
        
        params = [[NSMutableDictionary alloc]init];
        
        NSString *img = [self.currentPhoto title];
        NSRange nr = [img rangeOfString:@"."];
        fl = [img substringFromIndex:nr.location+1];
    }
    
    
    
    self.uploadButton.enabled = NO;
    self.photo.enabled = NO;
    self.postButton.enabled = NO;
    // loginButton.enabled = NO;
    self.uploadButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    self.photo.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    self.postButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    
    
    //no text and no photo
    if(([testMessage isEqualToString:@""] || ([testMessage length] == 0) ) && ([[self.currentPhoto title] isEqualToString: @"12650188.gif"]))
    {
      //  NSLog(@"image = %@",[self.currentPhoto title]);
      //  NSLog(@"test = %@",testMessage);
        
        [activity stopAnimating];
        [self.facebookTextView resignFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:@"MESSAGE"
                                    message:@"Please enter message or insert photo"
                                   delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil]show];
        
        self.uploadButton.enabled = YES;
        self.photo.enabled = YES;
        self.postButton.enabled = YES;
        // loginButton.enabled = YES;
        self.uploadButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        self.photo.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        self.postButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        
        
        return;
        
    }   //test and no photo
    else if((![testMessage isEqualToString:@""])&& ([[self.currentPhoto title] isEqualToString: @"12650188.gif"]))
    {
       // NSLog(@"YES test and NO photo");
        
        
        [params setObject:testMessage forKey:@"message"];
        [params setObject:UIImagePNGRepresentation([UIImage imageNamed:@"tphoto.png"]) forKey:@"picture"];
        
        /*  NSString *msg = self.facebookTextView.text;
         
         if(msg != nil){
         [self performPublishAction:^{
         
         [FBRequestConnection startForPostStatusUpdate:msg
         completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
         
         [self showAlert:msg result:result error:error];
         //     self.buttonPostStatus.enabled = YES;
         }];
         
         }];
         }*/
        
        [params setObject:testMessage forKey:@"message"];
        UIImage *um = [UIImage imageNamed:@"tphoto.png"];
        [params setObject:UIImageJPEGRepresentation(um, 0.1) forKey:@"picture"];
        
        [FBRequestConnection startWithGraphPath:@"me/photos"
                                     parameters:params
                                     HTTPMethod:@"POST"
                              completionHandler:^(FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error)
         {
             if (error)
             {
                 //showing an alert for failure
                 //[self alertWithTitle:@"Facebook" message:@"Unable to share the photo please try later."];
                 [self showAlert:@"Photo Post" result:result error:error];
             }
             else
             {
                 //showing an alert for success
                 //[UIUtils alertWithTitle:@"Facebook" message:@"Shared the photo successfully"];
                // NSLog(@"photo and message posted");
             }
         }];
        
        
    }//no test and photo
    else if([testMessage isEqualToString:@""]&& (![[self.currentPhoto title] isEqualToString: @"12650188.gif"]))
    {
       // NSLog(@"NO test and YES photo");
        
        
        [params setObject:@" " forKey:@"message"];
        
        if(_newMedia == YES){
            [params setObject:UIImageJPEGRepresentation(self.currentPhoto.image, 0.1) forKey:@"picture"];
        }
        else{
            if(([fl isEqualToString:@"png"]) || ([fl isEqualToString:@"PNG"])){
                [params setObject:UIImagePNGRepresentation(self.currentPhoto.image) forKey:@"picture"];
            }
            else if(([fl isEqualToString:@"jpg"]) || ([fl isEqualToString:@"JPG"])){
                [params setObject:UIImageJPEGRepresentation(self.currentPhoto.image, 0.1) forKey:@"picture"];
            }
        }
        
        
        [FBRequestConnection startWithGraphPath:@"me/photos"
                                     parameters:params
                                     HTTPMethod:@"POST"
                              completionHandler:^(FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error)
         {
             if (error)
             {
                 //showing an alert for failure
                 //[self alertWithTitle:@"Facebook" message:@"Unable to share the photo please try later."];
                 [self showAlert:@"Photo Post" result:result error:error];
             }
             else
             {
                 //showing an alert for success
                 //[UIUtils alertWithTitle:@"Facebook" message:@"Shared the photo successfully"];
                // NSLog(@"photo and message posted");
             }
         }];
        
        
        
        
        
        
        /* UIImage *img = self.currentPhoto.image;
         
         if(img != nil){
         
         [self performPublishAction:^{
         
         [FBRequestConnection startForUploadPhoto:img
         completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
         [self showAlert:@"Photo Post" result:result error:error];
         //self.buttonPostPhoto.enabled = YES;
         }];
         
         //self.buttonPostPhoto.enabled = NO;
         }];
         }*/
        
        
    } //test and photo
    else
    {
        //NSLog(@"YES test and YES photo");
        [params setObject:testMessage forKey:@"message"];
        
        if(_newMedia == YES){
            [params setObject:UIImageJPEGRepresentation(self.currentPhoto.image, 0.1) forKey:@"picture"];
        }
        else{
            if(([fl isEqualToString:@"png"]) || ([fl isEqualToString:@"PNG"])){
                [params setObject:UIImagePNGRepresentation(self.currentPhoto.image) forKey:@"picture"];
            }
            else if(([fl isEqualToString:@"jpg"]) || ([fl isEqualToString:@"JPG"])){
                [params setObject:UIImageJPEGRepresentation(self.currentPhoto.image, 0.1) forKey:@"picture"];
            }
        }
        
        
        [FBRequestConnection startWithGraphPath:@"me/photos"
                                     parameters:params
                                     HTTPMethod:@"POST"
                              completionHandler:^(FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error)
         {
             if (error)
             {
                 //showing an alert for failure
                 //[self alertWithTitle:@"Facebook" message:@"Unable to share the photo please try later."];
                 [self showAlert:@"Photo Post" result:result error:error];
             }
             else
             {
                 //showing an alert for success
                 //[UIUtils alertWithTitle:@"Facebook" message:@"Shared the photo successfully"];
                // NSLog(@"photo and message posted");
             }
         }];
        
        
    }
    
    self.currentPhoto.image = [UIImage imageNamed:@"12650188.gif"];
    [self.facebookTextView resignFirstResponder];
    
    [self performSelector:@selector(getTimeLine) withObject:nil afterDelay:5.0f];
    
    
}

- (void)showAlert:(NSString *)message
           result:(id)result
            error:(NSError *)error
{
    
    NSString *alertMsg;
    NSString *alertTitle;
    if (error)
    {
        alertTitle = @"Error";
        if (error.fberrorShouldNotifyUser ||
            error.fberrorCategory == FBErrorCategoryPermissions ||
            error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession)
        {
            alertMsg = error.fberrorUserMessage;
        }
        else
        {
            alertMsg = @"Operation failed due to a connection problem, retry later.";
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                            message:alertMsg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        
    }
    
}

- (IBAction)makeKeyboardGoAway:(id)sender {
    [self.facebookTextView resignFirstResponder];
}

@end
