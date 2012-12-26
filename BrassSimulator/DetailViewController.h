//
//  DetailViewController.h
//  masterDetail
//
//  Created by KenjiArai on 2012/12/17.
//  Copyright (c) 2012年 KenjiArai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
