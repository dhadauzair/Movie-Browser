//
//  MovieDetailViewController.h
//  Movie Browser
//
//  Created by Uzair Dhada on 19/11/17.
//  Copyright © 2017 Uzair Dhada. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieDetailViewController : UIViewController

@property (strong, nonatomic) NSString *movieId;
@property (strong, nonatomic) NSString *movieTitle;
@property (strong, nonatomic) NSDictionary *movieDict;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (copy, nonatomic) NSString *imagesBaseUrlString;

@property (weak, nonatomic) IBOutlet UIImageView *movieCoverImageView;
@property (weak, nonatomic) IBOutlet UITextView *movieDescriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *movieTitleLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *movieReleaseDate;

@end
