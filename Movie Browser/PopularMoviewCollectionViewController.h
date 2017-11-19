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

@interface PopularMoviewCollectionViewController : UICollectionViewController<UICollectionViewDataSource>

@property (copy, nonatomic) NSString *imagesBaseUrlString;
@property (strong, nonatomic) NSArray *moviesArray;
@property (strong, nonatomic) IBOutlet UICollectionView *gridViewMoviewCollection;

@end
