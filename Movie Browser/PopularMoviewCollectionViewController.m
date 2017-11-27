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
    
    self.moviesArray = [[NSMutableArray alloc] init];
    self.lastLoadedPage = 1;
    
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbConfiguration withParameters:nil andResponseBlock:^(id response, NSError *error) {
        if (!error)
            self.imagesBaseUrlString = [response[@"images"][@"base_url"] stringByAppendingString:@"w92"];
        else
            NSLog(@"Error");
    }];

    [self getData:self.lastLoadedPage];
    
}

-(void)getData:(NSInteger)page  {
    self.lastLoadedPage = page;
    [self getMovieList];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    float endScrolling = (scrollView.contentOffset.y + scrollView.frame.size.height);
    if (endScrolling >= scrollView.contentSize.height)
        [self getData:self.lastLoadedPage+1];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.moviesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
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
        [self searchBarTextDidEndEditing:searchBar];
    } else {
        self.lastLoadedPage = 1;
        [self getMovieList];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] == 0) {
        self.lastLoadedPage = 1;
        [self getMovieList];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if ([searchBar.text length] > 0) {
        [self searchMovie:searchBar.text];
    } else {
        self.lastLoadedPage = 1;
        [self getMovieList];
    }
}

- (IBAction)didSelectSettingsBtn:(id)sender {
    UIAlertController *customActionSheet = [UIAlertController alertControllerWithTitle:@"Sort Movie by" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *firstButton = [UIAlertAction actionWithTitle:@"Most Popular" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self setSortMovieByHighestRated:NO];
        self.lastLoadedPage = 1;
        [self getMovieList];
    }];
    
    
    UIAlertAction *secondButton = [UIAlertAction actionWithTitle:@"Highest Rated" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self setSortMovieByHighestRated:YES];
        self.lastLoadedPage = 1;
        [self getMovieList];
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

- (void) getMovieList
{
    [self animateActivityIndicator:YES];
    if ([self isSortMovieByHighestRated] == YES) {
        [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbMovieTopRated withParameters:@{@"page":[NSString stringWithFormat:@"%ld",(long)self.lastLoadedPage]} andResponseBlock:^(id response, NSError *error) {
            if(!error){
                if (self.lastLoadedPage == 1 && [self.moviesArray count] > 0) {
                    [self.moviesArray removeAllObjects];
                    self.moviesArray = [[NSArray arrayWithArray:response[@"results"]] mutableCopy];
                } else if ([self.moviesArray count] > 0) {
                    for (NSDictionary *singleObject in response[@"results"]) {
                        [self.moviesArray addObject:singleObject];
                    }
                }else
                    self.moviesArray = [[NSArray arrayWithArray:response[@"results"]] mutableCopy];
                [self.gridViewMoviewCollection reloadData];
                self.title = @"Highest Rated Movies";
            }
            [self animateActivityIndicator:NO];
        }];
    } else {
        [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbMoviePopular withParameters:@{@"page":[NSString stringWithFormat:@"%ld",(long)self.lastLoadedPage]} andResponseBlock:^(id response, NSError *error) {
            if(!error){
                if (self.lastLoadedPage == 1 && [self.moviesArray count] > 0) {
                    [self.moviesArray removeAllObjects];
                    self.moviesArray = [[NSArray arrayWithArray:response[@"results"]] mutableCopy];
                } else if ([self.moviesArray count] > 0) {
                    for (NSDictionary *singleObject in response[@"results"]) {
                        [self.moviesArray addObject:singleObject];
                    }
                }else {
                    self.moviesArray = [[NSArray arrayWithArray:response[@"results"]] mutableCopy];
                }
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
            self.moviesArray = [[NSArray arrayWithArray:response[@"results"]] mutableCopy];
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
