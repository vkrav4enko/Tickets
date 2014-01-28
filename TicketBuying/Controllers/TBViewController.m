//
//  TBViewController.m
//  TicketBuying
//
//  Created by Владимир on 07.10.13.
//  Copyright (c) 2013 Rost's company. All rights reserved.
//

#import "TBViewController.h"
#import "TBCollectionCell.h"
#import "TBDescriptionCell.h"
#import "TBPriceCell.h"
#import "TBAddressCell.h"
#import "TBDateCell.h"
#import "TBBookCell.h"
#import "TBMapController.h"
#import "TBWebEngine.h"
#import "Event.h"
#import "Image.h"
#import "User.h"
#import "NSManagedObject+ActiveRecord.h"
#import "NSEntityDescription+RKAdditions.h"
#import "TBAddEventController.h"

@interface TBViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
- (IBAction)bookButtonClick:(id)sender;
@end

@implementation TBViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _pageControl.numberOfPages = _event.images.count;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.separatorColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ticket_table_devider"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    if (indexPath.row == 0)
        cellIdentifier = @"TitleCell";
    if (indexPath.row == 1)
        cellIdentifier = @"PriceCell";
    if (indexPath.row == 2)
        cellIdentifier = @"DescriptionCell";
    if (indexPath.row == 3)
        cellIdentifier = @"AddressCell";
    if (indexPath.row == 4)
        cellIdentifier = @"DateCell";
    if (indexPath.row == 5)
        cellIdentifier = @"BookCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void) configureCell: (UITableViewCell *) cell atIndexPath: (NSIndexPath *) indexPath
{
    UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ticket_table_devider.png"]];
    separator.frame = CGRectMake(0, cell.frame.size.height - 4, cell.frame.size.width, 4);
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = _event.title;
    }
    if (indexPath.row == 1)
    {
        TBPriceCell *priceCell = (TBPriceCell *) cell;
        priceCell.priceLabel.text = [NSString stringWithFormat:@"€ %.2f", [_event.price floatValue]];
        NSString *oldPrice = [NSString stringWithFormat:@"€ %.2f", [_event.price floatValue] + [_event.discount floatValue]];
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString: oldPrice];
        [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                value:@1
                                range:(NSRange){0,[attributeString length]}];
        priceCell.oldPriceLabel.attributedText = attributeString;
        priceCell.discountLabel.text = [NSString stringWithFormat:@"Save up to € %.2f", [_event.discount floatValue]];
    }
    if (indexPath.row == 2)
    {
        TBDescriptionCell *descriptionCell = (TBDescriptionCell *) cell;
        descriptionCell.descriptionLabel.text = _event.eventDescription;
        separator.frame = CGRectMake(0, [self sizeOfString:_event.eventDescription].height +36, cell.frame.size.width, 4);
        [cell.contentView addSubview:separator];
    }
    if (indexPath.row == 3)
    {
        TBAddressCell *addressCell = (TBAddressCell *) cell;
        addressCell.locationLabel.text = @"Address";
        addressCell.addressLabel.text = [NSString stringWithFormat:@"%@ \n%@, %@",_event.street, _event.country, _event.city];
        [cell.contentView addSubview:separator];
        UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 60)];
        [accessoryView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ticket_cell_arrow"]]];
        cell.accessoryView = accessoryView;
    }
    if (indexPath.row == 4)
    {
        TBDateCell *dateCell = (TBDateCell *) cell;
        dateCell.dateLabel.text = @"Date";
        dateCell.timeLabel.text = _event.date;
        [cell.contentView addSubview:separator];
    }
    if (indexPath.row == 5)
    {
        TBBookCell *bookCell = (TBBookCell *) cell;
        UIImage *bgImage = [[UIImage imageNamed:@"ticket_booknow_button"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8) resizingMode:UIImageResizingModeStretch];
        [bookCell.bookButton setBackgroundImage:bgImage forState:UIControlStateNormal];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForRow = 50;
    if (indexPath.row == 0)
        heightForRow = 50;
    if (indexPath.row == 1)
        heightForRow = 100;
    if (indexPath.row == 2)
        heightForRow = [self sizeOfString:_event.eventDescription].height + 40;
    if (indexPath.row == 3)
        heightForRow = 120;
    if (indexPath.row == 4)
        heightForRow = 100;
    if (indexPath.row == 5)
        heightForRow = 70;
    
    return heightForRow;
}

- (CGSize) sizeOfString: (NSString *) string
{
    return [string boundingRectWithSize:CGSizeMake(280, CGFLOAT_MAX)
                                                   options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:13]}
                                                   context:nil].size;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[TBMapController class]])
    {
        [segue.destinationViewController setLocation: CLLocationCoordinate2DMake([_event.latitude floatValue], [_event.longitude floatValue])];
    }
    if ([segue.destinationViewController isKindOfClass:[TBAddEventController class]])
    {
        [segue.destinationViewController setEventForEdit:_event];
    }
}

#pragma mark - CollectionView

-(NSInteger) numberOfSectionsInCollectionView: (UICollectionView*) collectionView
{
    return 1;
}

-(NSInteger) collectionView: (UICollectionView*) collectionView numberOfItemsInSection: (NSInteger) section
{
    return _event.images.count;
}


-(UICollectionViewCell*) collectionView: (UICollectionView*) collectionView cellForItemAtIndexPath: (NSIndexPath*) indexPath
{
    Image *image = [[_event.images allObjects] objectAtIndex:indexPath.item];
    NSURL *imageUrl = [NSURL URLWithString:image.imageUrl];
    TBCollectionCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [cell.imageView setImageWithURL:imageUrl placeholderImage: nil];
    return cell;
}

- (IBAction)pageChanged:(UIPageControl *)sender {
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem: sender.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    self.pageControl.currentPage = self.collectionView.contentOffset.x / pageWidth;
}


- (IBAction)bookButtonClick:(id)sender {    
}
@end
