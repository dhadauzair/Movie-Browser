//
//  PopularMoviewCollectionViewController.m
//  Movie Browser
//
//  Created by Uzair Dhada on 19/11/17.
//  Copyright © 2017 Uzair Dhada. All rights reserved.
//

#import "PopularMoviewCollectionViewController.h"
#import "Constants.h"

@interface PopularMoviewCollectionViewController ()

@end

@implementation PopularMoviewCollectionViewController

static NSString * const reuseIdentifier = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pageSize = 20; // that's up to you, really
    self.preloadMargin = 5; // or whatever number that makes sense with your page size
    self.lastLoadedPage = 0;
    
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbConfiguration withParameters:nil andResponseBlock:^(id response, NSError *error) {
        if (!error)
            self.imagesBaseUrlString = [response[@"images"][@"base_url"] stringByAppendingString:@"w92"];
        else
            NSLog(@"Error");
    }];

    [self getData:1];
//    [self getMovieList];
    
}

-(void)getData:(NSInteger)page  {
    self.lastLoadedPage = page;
    // TODO: do the API call to get data
    NSString *strPage = [NSString stringWithFormat: @"%ld", (long)page];
    
    [self getMovieList:strPage];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.moviesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSInteger nextPage = (indexPath.item / self.pageSize) + 1;
    NSInteger preloadIndex = nextPage * self.pageSize - self.preloadMargin;
    
    // trigger the preload when you reach a certain point AND prevent multiple loads and updates
    if (indexPath.item >= preloadIndex && self.lastLoadedPage < nextPage) {
        [self getData:nextPage];
    }
    
    NSDictionary *movieDict = self.moviesArray[indexPath.row];
    cell.movieTitle.text = movieDict[ORIGINALTITLE];
    if (movieDict[POSTERPATH] != [NSNull null]) {
        NSString *imageUrl = [self.imagesBaseUrlString stringByAppendingString:movieDict[POSTERPATH]];
        [cell.movieImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:TMDB]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    MovieDetailViewController *movieDetailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:MOVIEDETAILVIEWCONTROLLERIDENTIFIER];
    movieDetailViewController.movieId = self.moviesArray[indexPath.row][MOVIEID];
    movieDetailViewController.movieTitle = self.moviesArray[indexPath.row][ORIGINALTITLE];
    movieDetailViewController.imagesBaseUrlString = self.imagesBaseUrlString;
    [self.navigationController pushViewController:movieDetailViewController animated:YES];
}

#pragma mark - UICollectionViewDelegate

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:COLLECTIONVIEWHEADERIDENTIFIER forIndexPath:indexPath];
        
        return headerView;
    }
    return nil;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar.text length] > 0) {
        [self searchMovie:searchBar.text];
    } else
        [self getMovieList:@"1"];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] == 0) {
        [self getMovieList:@"1"];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if ([searchBar.text length] > 0) {
        [self searchMovie:searchBar.text];
    } else
        [self getMovieList:@"1"];
}

- (IBAction)didSelectSettingsBtn:(id)sender {
    UIAlertController *customActionSheet = [UIAlertController alertControllerWithTitle:@"Sort Movie by" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *firstButton = [UIAlertAction actionWithTitle:@"Most Popular" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self setSortMovieByHighestRated:NO];
//        [self getMovieList];
        [self getMovieList:@"1"];
    }];
    
    
    UIAlertAction *secondButton = [UIAlertAction actionWithTitle:@"Highest Rated" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self setSortMovieByHighestRated:YES];
        [self getMovieList:@"1"];
    }];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    if ([self isSortMovieByHighestRated] == YES)
        [secondButton setValue:@true forKey:@"checked"];
    else
        [firstButton setValue:@true forKey:@"checked"];
    
    [customActionSheet addAction:firstButton];
    [customActionSheet addAction:secondButton];
    [customActionSheet addAction:cancelButton];
    
    [self presentViewController:customActionSheet animated:YES completion:nil];
}

#pragma mark - Set Order

- (void) setSortMovieByHighestRated:(BOOL) enable
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@(enable) forKey:SORT_MOVIE_HIGHEST_RATED];
    [defaults synchronize];
}

- (BOOL) isSortMovieByHighestRated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    return [[defaults objectForKey:SORT_MOVIE_HIGHEST_RATED] boolValue];
}

#pragma mark - Internal Methods

- (void) getMovieList:(NSString *)page
{
    [self animateActivityIndicator:YES];
    if ([self isSortMovieByHighestRated] == YES) {
        [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbMovieTopRated withParameters:@{@"page":page} andResponseBlock:^(id response, NSError *error) {
            if(!error){
                self.moviesArray = response[@"results"];
                [self.gridViewMoviewCollection reloadData];
                self.title = @"Highest Rated Movies";
            }
            [self animateActivityIndicator:NO];
        }];
    } else {
        [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbMoviePopular withParameters:@{@"page":page} andResponseBlock:^(id response, NSError *error) {
            if(!error){
                self.moviesArray = response[@"results"];
                [self.gridViewMoviewCollection reloadData];
                self.title = @"Popular Movies";
            }
            [self animateActivityIndicator:NO];
        }];
    }
}

- (void) searchMovie:(NSString *)searchText
{
    [self animateActivityIndicator:YES];
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbSearchMovie withParameters:@{@"query":searchText} andResponseBlock:^(id response, NSError *error) {
        if(!error){
            self.moviesArray = response[@"results"];
            [self.gridViewMoviewCollection reloadData];
        }
        [self animateActivityIndicator:NO];
    }];
}

- (void) animateActivityIndicator:(BOOL) animate
{
    if (animate == YES)
        [self.activityIndicator startAnimating];
    else
        [self.activityIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
