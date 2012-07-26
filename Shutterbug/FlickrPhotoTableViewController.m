//
//  FlickrPhotoTableViewController.m
//  Shutterbug
//
//  Created by Norimasa Nabeta on 2012/07/26.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "FlickrPhotoTableViewController.h"
#import "FlickrFetcher.h"
#import "FlickrPhotoImageViewController.h"

@interface FlickrPhotoTableViewController ()
// keys: photographer NSString, values: NSArray of photo NSDictionary
@property (nonatomic, strong) NSDictionary *photosByPhotographer;
@property (nonatomic, strong) NSURL *photoURL;
@end

@implementation FlickrPhotoTableViewController

- (IBAction)refresh:(id)sender {
    // might want to use introspection to be sure sender is UIBarButtonItem
    // (if not, it can skip the spinner)
    // that way this method can be a little more generic
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher recentGeoreferencedPhotos];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = sender;
            self.photos = photos;
        });
    });
    dispatch_release(downloadQueue);
}

- (void)updatePhotosByPhotographer
{
    NSMutableDictionary *photosByPhotographer = [NSMutableDictionary dictionary];
    for (NSDictionary *photo in self.photos) {
        NSString *photographer = [photo objectForKey:FLICKR_PHOTO_OWNER];
        NSMutableArray *photos = [photosByPhotographer objectForKey:photographer];
        if (!photos) {
            photos = [NSMutableArray array];
            [photosByPhotographer setObject:photos forKey:photographer];
            // NSLog(@"Photographer: %@", photographer);
        }
        [photos addObject:photo];
    }
    self.photosByPhotographer = photosByPhotographer;
}

-(void) setPhotos:(NSArray *)photos
{
    if(_photos != photos){
        _photos = photos;
        // Model changed, so update our View (the table)
        [self updatePhotosByPhotographer];
        if (self.tableView.window) [self.tableView reloadData];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source
- (NSString *)photographerForSection:(NSInteger)section
{
    return [[self.photosByPhotographer allKeys] objectAtIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return [self photographerForSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.photosByPhotographer count];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // return [self.photos count];
    NSString *photographer = [self photographerForSection:section];
    NSArray *photosByPhotographer = [self.photosByPhotographer objectForKey:photographer];
    return [photosByPhotographer count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    // NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    NSString *photographer = [self photographerForSection:indexPath.section];
    NSArray *photosByPhotographer = [self.photosByPhotographer objectForKey:photographer];
    NSDictionary *photo = [photosByPhotographer objectAtIndex:indexPath.row];
    cell.textLabel.text = [photo objectForKey:FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text = [photo objectForKey:FLICKR_PHOTO_OWNER];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        self.detailViewController.detailItem = object;
        NSString *photographer = [self photographerForSection:indexPath.section];
        NSArray *photosByPhotographer = [self.photosByPhotographer objectForKey:photographer];
        NSDictionary *photo = [photosByPhotographer objectAtIndex:indexPath.row];
        // cell.textLabel.text = [photo objectForKey:FLICKR_PHOTO_TITLE];
        // cell.detailTextLabel.text = [photo objectForKey:FLICKR_PHOTO_OWNER];
        self.photoURL = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge];
        NSLog(@"URL: %@", self.photoURL);
    }

}

 - (FlickrPhotoImageViewController *)splitViewHappinessViewController
{
    id hvc = [self.splitViewController.viewControllers lastObject];
    if (![hvc isKindOfClass:[FlickrPhotoImageViewController class]]) {
        hvc = nil;
    }
    return hvc; 
}
 -(void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *photographer = [self photographerForSection:indexPath.section];
    NSArray *photosByPhotographer = [self.photosByPhotographer objectForKey:photographer];
    NSDictionary *photo = [photosByPhotographer objectAtIndex:indexPath.row];
    // cell.textLabel.text = [photo objectForKey:FLICKR_PHOTO_TITLE];
    // cell.detailTextLabel.text = [photo objectForKey:FLICKR_PHOTO_OWNER];
    self.photoURL = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge];
    // NSLog(@"URL: %@", self.photoURL);

    
    if ([self splitViewHappinessViewController]) {                      // if in split view
        [self splitViewHappinessViewController].urlPhoto = self.photoURL;  // just set happiness in detail
    } else {
        [self performSegueWithIdentifier:@"FlickrPhotoImage" sender:self];
    }    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FlickrPhotoImage"]) {
        [segue.destinationViewController setUrlPhoto:self.photoURL ];
    }
}


@end
