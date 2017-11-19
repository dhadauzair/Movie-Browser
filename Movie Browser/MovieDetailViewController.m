//
//  MovieDetailViewController.m
//  Movie Browser
//
//  Created by Uzair Dhada on 19/11/17.
//  Copyright © 2017 Uzair Dhada. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import <JLTMDbClient.h>
#import "MovieDetailViewController.h"

@interface MovieDetailViewController ()

@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.movieTitle;
    __block NSString *imageBackdrop;
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbMovie withParameters:@{@"id":self.movieId} andResponseBlock:^(id response, NSError *error) {
        [self.activityIndicator startAnimating];
        if (!error) {
            self.movieDict = response;
//            if (self.movieDict[@"backdrop_path"] != [NSNull null]){
//                imageBackdrop = [self.imagesBaseUrlString stringByReplacingOccurrencesOfString:@"w92" withString:@"w780"];
//                [self.movieCoverImageView setImageWithURL:[NSURL URLWithString:[imageBackdrop stringByAppendingString:self.movieDict[@"backdrop_path"]]]];
//            } else {
                imageBackdrop = [self.imagesBaseUrlString stringByReplacingOccurrencesOfString:@"w92" withString:@"w500"];
                [self.movieCoverImageView setImageWithURL:[NSURL URLWithString:[imageBackdrop stringByAppendingString:self.movieDict[@"poster_path"]]]];
            [self.movieTitleLabel setText:self.movieTitle];
            [self.movieReleaseDate setText:[NSString stringWithFormat:@"Release Date:%@",self.movieDict[@"release_date"]]];
            
            [self.activityIndicator stopAnimating];
//            }
        }
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.movieDescriptionTextView.text = self.movieDict[@"overview"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
