//
//  PopularMoviewCollectionViewController.m
//  Movie Browser
//
//  Created by Uzair Dhada on 19/11/17.
//  Copyright © 2017 Uzair Dhada. All rights reserved.
//

#import "PopularMoviewCollectionViewController.h"

@interface PopularMoviewCollectionViewController ()

@end

@implementation PopularMoviewCollectionViewController

static NSString * const reuseIdentifier = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.gridViewMoviewCollection registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.title = @"Popular Movies";
    
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbConfiguration withParameters:nil andResponseBlock:^(id response, NSError *error) {
        if (!error)
            self.imagesBaseUrlString = [response[@"images"][@"base_url"] stringByAppendingString:@"w92"];
        else
            NSLog(@"Error");
    }];
    
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbMoviePopular withParameters:nil andResponseBlock:^(id response, NSError *error) {
        if(!error){
            self.moviesArray = response[@"results"];
            NSLog(@"Popular Movies: %@",response);
            [self.gridViewMoviewCollection reloadData];
        }
    }];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
//    [self.gridViewMoviewCollection registerClass:[CustomCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
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

#pragma mark <UICollectionViewDataSource>

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
////#warning Incomplete implementation, return the number of sections
//    return self.moviesArray.count;
//}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of items
    return self.moviesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
//    MovieCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCell" forIndexPath:indexPath];
    
    NSDictionary *movieDict = self.moviesArray[indexPath.row];
    cell.movieTitle.text = movieDict[@"original_title"];
    if (movieDict[@"poster_path"] != [NSNull null]) {
        NSString *imageUrl = [self.imagesBaseUrlString stringByAppendingString:movieDict[@"poster_path"]];
        [cell.movieImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"TMDB"]];
    }
    // Configure the cell
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    MovieDetailViewController *movieDetailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MovieDetailViewController"];
    movieDetailViewController.movieId = self.moviesArray[indexPath.row][@"id"];
    movieDetailViewController.movieTitle = self.moviesArray[indexPath.row][@"original_title"];
    movieDetailViewController.imagesBaseUrlString = self.imagesBaseUrlString;
    [self.navigationController pushViewController:movieDetailViewController animated:YES];
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
