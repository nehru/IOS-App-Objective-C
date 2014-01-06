//
//  BriTwitterViewController.m
//  Bringo
//
//  Created by Nehru Sathappan on 5/19/13.
//  Copyright (c) 2013 Nehru Sathappan. All rights reserved.
//

#import "BriTwitterViewController.h"
#import "BriTwitterTableViewCell.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "Photo.h"
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Global.h"
#import "TwitterDisplayViewController.h"



@interface UIImageView(Title)
@property(nonatomic, copy) NSString *title;
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


@interface BriTwitterViewController ()

@end

@implementation BriTwitterViewController
 
NSMutableArray *twitteriPadphotos;
@synthesize postButton = _postButton;
@synthesize uploadButton = _uploadButton;
@synthesize toggleCamera = _toggleCamera;
@synthesize currentPhoto = _currentPhoto;
@synthesize profilePhoto = _profilePhoto;
@synthesize twitteriPadTextView = _twitteriPadTextView;
UIActivityIndicatorView *activity2;
@synthesize poc;

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
    
    Global *gl = [[Global alloc]init];
    [gl start];
    
    twitteriPadphotos = [[NSMutableArray alloc]init];
    
    activity2 = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activity2.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    activity2.center = CGPointMake(self.view.center.x,self.view.center.y-330);
    activity2.color =[UIColor blueColor];
    [self.view addSubview:activity2];

    self.postButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.uploadButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    [self.currentPhoto setTitle:@"12650188.gif"];
    self.currentPhoto.image = [UIImage imageNamed:[self.currentPhoto title]];
    [activity2 startAnimating];
    
    
    [self passwordCheck];
    [self readProfile];
        
    [self getTimeLine];
}

- (void)readProfile {
    
    __block BOOL status = false;
    
    dispatch_queue_t qtr = dispatch_queue_create("profiling", NULL);
    
    [activity2 startAnimating];
    
    dispatch_async(qtr, ^{
        
        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account
                                      accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [account requestAccessToAccountsWithType:accountType
                                         options:nil completion:^(BOOL granted, NSError *error)
         {
             if (granted == YES)
             {
                 
                 NSArray *arrayOfAccounts = [account
                                             accountsWithAccountType:accountType];
                 
                 if ([arrayOfAccounts count] > 0)
                 {
                     ACAccount *twitterAccount =
                     [arrayOfAccounts lastObject];
                     
                     NSURL *requestURL = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/home_timeline.json"];
                     
                     NSMutableDictionary *parameters =
                     [[NSMutableDictionary alloc] init];
                     [parameters setObject:@"20" forKey:@"count"];
                     [parameters setObject:@"1" forKey:@"include_entities"];
                     
                     SLRequest *postRequest = [SLRequest
                                               requestForServiceType:SLServiceTypeTwitter
                                               requestMethod:SLRequestMethodGET
                                               URL:requestURL parameters:parameters];
                     
                     postRequest.account = twitterAccount;
                     
                     //try 3 times if urlresponse is not 200
                     for(int i=0;i<3;i++)
                     {
                         
                         [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                          {
                              
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  if([responseData length] < 5)
                                  {
                                      [activity2 stopAnimating];
                                     // NSLog(@"stopped");
                                      
                                  }
                                  
                              });
                              
                              
                              
                              if([urlResponse statusCode] == 200)
                              {
                                  status = true;
                                  self.dataSource = [NSJSONSerialization
                                                     JSONObjectWithData:responseData
                                                     options:NSJSONReadingMutableLeaves
                                                     error:&error];
                                  
                                  NSString *profile;
                                  
                                  for(int i=0; i < [self.dataSource count];i++)
                                  {
                                      profile = [[[self.dataSource objectAtIndex:i]objectForKey:@"user"]objectForKey:@"profile_image_url"];
                                      
                                      if(profile != Nil)
                                          break;
                                  }
                                  
                                  if (profile)
                                  {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          
                                          NSURL *url1 = [NSURL URLWithString:profile];
                                          NSData *data1 = [[NSData alloc ]initWithContentsOfURL:url1];
                                          UIImage *image1 = [[UIImage alloc ]initWithData:data1];
                                          [self.profilePhoto setImage:image1];
                                          [activity2 stopAnimating];
                                      });
                                      
                                  }
                              }
                              
                              
                          }];
                         
                         if(status)
                             break;
                         
                     }
                     
                 }
             }
             else //if not granted
             {
                 // Handle failure to get account access
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [activity2 stopAnimating];
                     
                     self.uploadButton.enabled = NO;
                     self.postButton.enabled = NO;
                     self.postButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
                     self.uploadButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
                     
                     [[[UIAlertView alloc] initWithTitle:@"MESSAGE"
                                                 message:@"Account access denied, Please set your username and password in the setting"
                                                delegate:self
                                       cancelButtonTitle:nil
                                       otherButtonTitles:@"OK", nil]show];
                     
                     
                     
                 });
                 
                 
                 
             }
         }];
        
    });
    
}

-(void)passwordCheck
{
    // __block BOOL pass = false;
    dispatch_queue_t qt = dispatch_queue_create("passLoad", NULL);
    
    dispatch_async(qt, ^{
        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account
                                      accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [account requestAccessToAccountsWithType:accountType
                                         options:nil completion:^(BOOL granted, NSError *error)
         {
             
             int err;
             
             err = [error code];
             
            // NSLog(@"error = %d -- %d",err, granted);
             
             if((err > 0) || granted != 1)
             {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     UIAlertView *anAlert = [[UIAlertView alloc] initWithTitle:@"Hit Home Button to Exit" message:@"Please setup username and password in the settings Twitter" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                     [anAlert show];
                     
                     
                 });
                 
                 
             }
             
             
         }];
        
        
        
    });
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"TwitteriPadSegue"]){
        TwitterDisplayViewController *tdc = [segue destinationViewController];
        NSIndexPath *path = [self.twitteriPadTableView indexPathForSelectedRow];
        Photo *tt = [twitteriPadphotos objectAtIndex:[path row]];
        [tdc setCurrentPhoto:tt];
    }
    
}




- (IBAction)pickPhoto:(id)sender {
    
    UIImagePickerController *imagePicker;
    imagePicker = [[UIImagePickerController alloc]init];
    
    if([self.toggleCamera isOn])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _newMedia = YES;
        imagePicker.delegate = self;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _newMedia = NO;
        
        imagePicker.delegate = self;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
        // [self presentViewController:imagePicker animated:YES completion:nil];
        
        self.poc = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [self.poc presentPopoverFromRect:((UIButton *)sender).bounds inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        

    }
    
    
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    if(self.poc){
        [self.poc dismissPopoverAnimated:YES];
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
    self.currentPhoto.image = image;
    
  //  NSLog(@"image = %@",self.currentPhoto.image);
    
    //NSURL *imagePath = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
   // NSLog(@"imagePath = %@",imagePath);
    
  //  NSString *imageName = [imagePath lastPathComponent];
   // NSLog(@"imageName = %@",imageName);
    
    if(_newMedia){
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:finishedSaving:contextInfo:), nil);
    }
    
    
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

- (IBAction)makeKeyboardGoAway:(id)sender {
    [self.twitteriPadTextView resignFirstResponder];
}

- (IBAction)postMessageAndPhoto:(id)sender {  //deb
    
    //   __block BOOL status = false;
    __block SLRequest *postRequest;
    __block NSURL *requestURL;
    __block ACAccount *twitterAccount;
    
    [activity2 startAnimating];
    
    
    NSString *testMessage = self.twitteriPadTextView.text;
    UIImage *curImg = self.currentPhoto.image;
    
    //Reset image and textview
    
    
    
    
  //  NSLog(@"test = %@",testMessage);
   // NSLog(@"image = %@",[self.currentPhoto title]);
    
    if([testMessage isEqualToString:@""])
    {
        NSLog(@"test = %@",testMessage);
    }
    
    if([[self.currentPhoto title] isEqualToString: @"12650188.gif"])
    {
        NSLog(@"image = %@",[self.currentPhoto title]);
    }
    //NSLog(@"image = %@",[self.currentPhoto title]);
    
    
    
    
    
    if([testMessage isEqualToString:@""] && ([[self.currentPhoto title] isEqualToString: @"12650188.gif"]))
    {
        
        [self.twitteriPadTextView resignFirstResponder];
        
        [[[UIAlertView alloc] initWithTitle:@"MESSAGE"
                                    message:@"Please enter message or insert photo"
                                   delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil]show];
        
        [activity2 stopAnimating];
        return;
        
    }
    
    self.uploadButton.enabled = NO;
    self.postButton.enabled = NO;
    self.postButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    self.uploadButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    
    
    dispatch_queue_t qtt = dispatch_queue_create("sending", NULL);
    dispatch_async(qtt, ^{
        
        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:
                                      ACAccountTypeIdentifierTwitter];
        
        [account requestAccessToAccountsWithType:accountType options:nil
                                      completion:^(BOOL granted, NSError *error)
         {
             
             if (granted == YES)
             {
                 NSArray *arrayOfAccounts = [account
                                             accountsWithAccountType:accountType];
                 
                 //NSLog(@"check");
                 
                 if ([arrayOfAccounts count] > 0)
                 {
                     twitterAccount = [arrayOfAccounts lastObject];
                     
                     // NSDictionary *message = @{@"status": self.TwitterTextView.text};
                     NSDictionary *message;
                     
                     if([testMessage isEqual:nil]){
                         message = nil;
                     }
                     else
                     {
                         message = @{@"status": testMessage};
                     }
                     
                     
                     //  requestURL = [NSURL
                     // URLWithString:@"http://api.twitter.com/1/statuses/update.json"];
                     
                     requestURL = [NSURL URLWithString:@"https://upload.twitter.com/1/statuses/update_with_media.json"];
                     
                     //UIImage *image =[UIImage imageNamed:@"fan8b.png"];
                     
                     postRequest = [SLRequest
                                    requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodPOST
                                    URL:requestURL parameters:message];
                     
                     
                    // NSLog(@"image = %@",[self.currentPhoto title]);
                     NSString *img = [self.currentPhoto title];
                     NSRange nr = [img rangeOfString:@"."];
                     NSString *fl = [img substringFromIndex:nr.location+1];
                     
                     
                     if(([fl caseInsensitiveCompare:@"jpg"] == NSOrderedSame) || ([fl caseInsensitiveCompare:@"png"] == NSOrderedSame))
                     {
                         if([fl caseInsensitiveCompare:@"jpg"] == NSOrderedSame)
                         {
                             [postRequest addMultipartData:UIImageJPEGRepresentation((curImg), 0.1) withName:@"media" type:@"multipart/jpg" filename:nil];
                         }
                         else if([fl caseInsensitiveCompare:@"png"] == NSOrderedSame)
                         {
                             [postRequest addMultipartData:UIImagePNGRepresentation(curImg) withName:@"media" type:@"multipart/png" filename:nil];
                         }
                         
                     }
                     else
                     {
                         
                         if(![testMessage isEqualToString:@""])
                         {
                             UIImage *um = [UIImage imageNamed:@"tphoto.png"];
                             [postRequest addMultipartData:UIImagePNGRepresentation(um) withName:@"media" type:@"multipart/png" filename:nil];
                         }
                         
                         /* [[[UIAlertView alloc] initWithTitle:@"MESSAGE"
                          message:@"Please upload .jpg or .png files"
                          delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil]show];*/
                         
                         
                     }
                     
                     
                     
                     /*     if(curImg != nil){
                      
                      [postRequest addMultipartData:UIImagePNGRepresentation(curImg) withName:@"media" type:@"multipart/png" filename:nil];
                      }*/
                     
                     
                     postRequest.account = twitterAccount;
                     
                     
                     
                     
                     if([testMessage isEqualToString:@""] && ([[self.currentPhoto title] isEqualToString: @"12650188.gif"])){
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             //[activity2 stopAnimating];
                             [[[UIAlertView alloc] initWithTitle:@"MESSAGE"
                                                         message:@"Please enter message"
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil]show];
                             
                             
                             return;
                             //self.TwitterTextView.text = @" ";
                         });
                         
                         
                     }
                     
                     
                     
                     
                     [postRequest performRequestWithHandler:^(NSData *responseData,
                                                              NSHTTPURLResponse *urlResponse, NSError *error)
                      {
                         // NSLog(@"anew Twitter HTTP response: %i", [urlResponse statusCode]);
                          
                          
                          
                          if([urlResponse statusCode] == 403){
                              
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  
                                  
                                  [[[UIAlertView alloc] initWithTitle:@"MESSAGE"
                                                              message:@"Same message exists"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:@"OK", nil]show];
                                  
                                  
                                  
                                  //self.TwitterTextView.text = @" ";
                                  //[activity2 stopAnimating];
                                  return;
                              });
                              
                          }else if([urlResponse statusCode] == 200)
                          {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  
                                  self.twitteriPadTextView.text = @"";
                                  
                                  
                                  //deb removed temp -Nehru
                                  self.currentPhoto.image = [UIImage imageNamed:@"12650188.gif"];
                                  
                                  //[activity2 stopAnimating];
                              });
                              
                          }
                          
                          
                          
                          
                      }];
                     
                 } //arrayOfAccounts
                 
                 
             }
             else //granted NO
             {
                 
             }
         }];
        
    });
    
    //self.TwitterTextView.text = @"";
    
    [self.twitteriPadTextView resignFirstResponder];
    //********************************************************
    
    [self performSelector:@selector(getTimeLine) withObject:nil afterDelay:5.0f];
    
    //*********************************************************
   
    
}

- (void)getTimeLine {
    
    __block BOOL status = false;
    
    dispatch_queue_t qt = dispatch_queue_create("loading", NULL);
    
    dispatch_async(qt, ^{
        
        
        
        
        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account
                                      accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [account requestAccessToAccountsWithType:accountType
                                         options:nil completion:^(BOOL granted, NSError *error)
         {
             if (granted == YES)
             {
                 NSArray *arrayOfAccounts = [account
                                             accountsWithAccountType:accountType];
                 
                 if ([arrayOfAccounts count] > 0)
                 {
                     ACAccount *twitterAccount =
                     [arrayOfAccounts lastObject];
                     
                     NSURL *requestURL = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/home_timeline.json"];
                     
                     NSMutableDictionary *parameters =
                     [[NSMutableDictionary alloc] init];
                     [parameters setObject:@"100" forKey:@"count"];
                     [parameters setObject:@"1" forKey:@"include_entities"];
                     
                     SLRequest *postRequest = [SLRequest
                                               requestForServiceType:SLServiceTypeTwitter
                                               requestMethod:SLRequestMethodGET
                                               URL:requestURL parameters:parameters];
                     
                     postRequest.account = twitterAccount;
                     
                     //try 3 times if urlresponse is not 200
                     //   for(int i=0;i<3;i++)
                     //  {
                     // NSLog(@"i value = %d",i);
                     //NSLog(@"outer status = %d",status);
                     [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                      {
                          //NSLog(@"responseData = %@",[responseData description]);
                          //NSLog(@"Error code = %d",[error code]);
                          //NSLog(@"urlResponse = %d",[urlResponse statusCode]);
                          
                          if([urlResponse statusCode] == 200)
                          {
                              status = true;
                              self.dataSource = [NSJSONSerialization
                                                 JSONObjectWithData:responseData
                                                 options:NSJSONReadingMutableLeaves
                                                 error:&error];
                              
                              // NSLog(@"i status = %d",status);
                              //  NSLog(@"datasource == %@",_dataSource);
                              
                              
                              
                              [twitteriPadphotos removeAllObjects];
                              
                              for(int i=0;i<_dataSource.count;i++)
                              {
                                  //// NSLog(@" %d ---- \n  %@",i,[_dataSource objectAtIndex:i]);
                                  // NSLog(@"------------------------------------------------------------");
                                  
                                  _tweet = [_dataSource objectAtIndex:i];
                                  NSString *pt = [[[[_tweet objectForKey:@"entities"]objectForKey:@"media"]objectAtIndex:0]objectForKey:@"media_url"];
                                  // NSLog(@" %d ---- \n  %@",i,pt);
                                  // NSLog(@"%@",_tweet[@"text"]);
                                  
                                  NSString *myURL = [[[[_tweet objectForKey:@"entities"]objectForKey:@"media"]objectAtIndex:0]objectForKey:@"url"];
                                  //  NSLog(@"url = %@",myURL);
                                  
                                  NSString *whole = _tweet[@"text"];
                                  NSString *finalStr;
                                  
                                  if(myURL != nil)
                                  {
                                      NSRange range = [whole rangeOfString:myURL];
                                      finalStr = [whole substringWithRange:NSMakeRange(0, range.location)];
                                      
                                  }
                                  
                                  Photo *pic = [[Photo alloc]init];
                                  [pic setMessage:finalStr];
                                  [pic setPhotoURL:pt];
                                  
                                  [twitteriPadphotos addObject:pic];
                                  
                                  
                              }
                              
                              
                              
                              if (self.dataSource.count != 0)
                              {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self.twitteriPadTableView reloadData];
                                      
                                      
                                      //reset image and message to null
                                      
                                      self.uploadButton.enabled = YES;
                                      self.postButton.enabled = YES;
                                      self.postButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
                                      self.uploadButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
                                      
                                      //deb
                                      self.twitteriPadTextView.text = @"";
                                      //self.currentPhoto.image = [UIImage imageNamed:@"12650188.gif"];
                                      
                                      [self.currentPhoto setTitle:@"12650188.gif"];
                                      self.currentPhoto.image = [UIImage imageNamed:[self.currentPhoto title]];
                                      [activity2 stopAnimating];
                                      
                                      
                                  });
                                  
                              }
                          }
                          
                          
                      }];
                     
                     //  [NSThread sleepForTimeInterval:1.0];
                     //NSLog(@"iiii status = %d",status);
                     
                     //if(status)
                     //      break;
                     
                     //  }
                     
                 }
             }
             else //if not granted
             {
                 // Handle failure to get account access
                 
                 
                 /*  dispatch_async(dispatch_get_main_queue(), ^{
                  UIAlertView * alert = [[UIAlertView alloc]
                  initWithTitle:@"Announcement" message:@"Twitter access denied" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                  [alert show];
                  
                  });*/
                 
                 
             }
         }];
        
    });
    
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"******** count = %ld",(unsigned long)twitteriPadphotos.count);
    return twitteriPadphotos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"TwitteriPadCell";
    
    BriTwitterTableViewCell  *cell = [self.twitteriPadTableView
                            dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[BriTwitterTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }

    Photo *tt = [twitteriPadphotos objectAtIndex:[indexPath row]];
    
    NSString *pt = [tt photoURL];
    if(pt != Nil)
    {
        
        NSURL *url = [NSURL URLWithString:pt];
        NSData *data = [[NSData alloc ]initWithContentsOfURL:url];
        UIImage *image = [[UIImage alloc ]initWithData:data];
        [cell.myImage setImage:image];
        
        
        
    }
    
    
   // NSLog(@"******** text = %@",[tt message]);
    //cell.myText.text = tweet[@"text"];
    cell.myLabel.text =[tt message];
    
    // NSLog(@"----------------------------------------------");
    //cell.txt.text;
    
    //cell.textLabel.text = tweet[@"text"];
    return cell;
}

@end
