//
//  PopularMoviewCollectionViewController.h
//  Movie Browser
//
//  Created by Uzair Dhada on 19/11/17.
//  Copyright © 2017 Uzair Dhada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JLTMDbClient.h>
#import "CustomCell.h"
#import <UIImageView+AFNetworking.h>
#import "MovieDetailViewController.h"
#import "SearchCollectionReusableView.h"

@interface PopularMoviewCollectionViewController : UICollectionViewController<UICollectionViewDataSource,UISearchBarDelegate>

@property (copy, nonatomic) NSString *imagesBaseUrlString;
@property (strong, nonatomic) NSArray *moviesArray;
@property (strong, nonatomic) IBOutlet UICollectionView *gridViewMoviewCollection;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic,assign)NSInteger pageSize;
@property(nonatomic,assign)NSInteger preloadMargin;
@property(nonatomic,assign)NSInteger lastLoadedPage;

@end
