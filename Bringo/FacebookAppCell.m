//
//  FacebookAppCell.m
//  Bringo
//
//  Created by Nehru Sathappan on 5/14/13.
//  Copyright (c) 2013 Nehru Sathappan. All rights reserved.
//

#import "FacebookAppCell.h"

@implementation FacebookAppCell
@synthesize myLabel,myImage;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
