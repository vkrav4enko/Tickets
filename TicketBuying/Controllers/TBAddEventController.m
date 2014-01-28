//
//  TBAddEventController.m
//  TicketBuying
//
//  Created by Владимир on 27.01.14.
//  Copyright (c) 2014 Rost's company. All rights reserved.
//

#import "TBAddEventController.h"
#import "TBTextfieldCell.h"
#import "Image.h"
#import "Event.h"
#import "User.h"
#import "UIView+FindFirstResponder.h"
#import "TBWebEngine.h"

@interface TBAddEventController () <UITextFieldDelegate, UIAlertViewDelegate>
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString * date;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *discount;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, copy) NSString *imageUrl;

@end

@implementation TBAddEventController

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
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TextfieldCell";
    TBTextfieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (indexPath.row == 2)
    {
        DateInputTableViewCell *dateCell = [tableView dequeueReusableCellWithIdentifier:@"DateCell"];
        dateCell.textField.enabled = NO;
        if(_eventForEdit)
            dateCell.textField.text = _eventForEdit.date;
        dateCell.textField.placeholder = @"Date";
        return dateCell;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(TBTextfieldCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            if(_eventForEdit)
                cell.textField.text = _eventForEdit.title;
            cell.textField.placeholder = @"Title";
            cell.textField.returnKeyType = UIReturnKeyNext;
            break;
        case 1:
            if(_eventForEdit)
                cell.textField.text = _eventForEdit.eventDescription;
            cell.textField.placeholder = @"Description";
            cell.textField.returnKeyType = UIReturnKeyNext;
            break;
        case 3:
            if(_eventForEdit)
                cell.textField.text = [_eventForEdit.price stringValue];
            cell.textField.placeholder = @"Price";
            cell.textField.returnKeyType = UIReturnKeyNext;
            cell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            break;
        case 4:
            if(_eventForEdit)
                cell.textField.text = [_eventForEdit.discount stringValue];
            cell.textField.placeholder = @"Discount";
            cell.textField.returnKeyType = UIReturnKeyNext;
            cell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            break;
        case 5:
            if(_eventForEdit)
                cell.textField.text = [_eventForEdit.latitude stringValue];
            cell.textField.placeholder = @"Latitude";
            cell.textField.returnKeyType = UIReturnKeyNext;
            cell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            break;
        case 6:
            if(_eventForEdit)
                cell.textField.text = [_eventForEdit.longitude stringValue];
            cell.textField.placeholder = @"Longitude";
            cell.textField.returnKeyType = UIReturnKeyNext;
            cell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            break;
        case 7:
            if(_eventForEdit && [_eventForEdit.images count])
                cell.textField.text = [[[_eventForEdit.images allObjects] objectAtIndex:0] imageUrl];
            cell.textField.placeholder = @"Image url";
            cell.textField.returnKeyType = UIReturnKeyDone;
            cell.textField.keyboardType = UIKeyboardTypeURL;
            break;
            
        default:
            break;
    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[[textField superview] superview]superview]];
    
    switch (textField.returnKeyType) {
        case UIReturnKeyDone:
            // Last Row Done
            [self handleDone:nil];
            break;
        case UIReturnKeyNext:
        {
            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
            TBTextfieldCell *cell = (TBTextfieldCell *)[self.tableView cellForRowAtIndexPath:nextIndexPath];
            [cell.textField becomeFirstResponder];
        }
        default:
            break;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(TBTextfieldCell *)[[[textField superview] superview]superview]];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(TBTextfieldCell *)[[[textField superview] superview]superview]];
    if (indexPath.section == 0)
    {
        if(_eventForEdit)
        {
            if (indexPath.row == 0) _eventForEdit.title = textField.text;
            if (indexPath.row == 1) _eventForEdit.eventDescription = textField.text;
            if (indexPath.row == 3) _eventForEdit.price = @([textField.text floatValue]);
            if (indexPath.row == 4) _eventForEdit.discount = @([textField.text floatValue]);
            if (indexPath.row == 5) _eventForEdit.latitude = @([textField.text floatValue]);
            if (indexPath.row == 6) _eventForEdit.longitude = @([textField.text floatValue]);
            if (indexPath.row == 7) self.imageUrl = textField.text;
        }
        else
        {
            if (indexPath.row == 0) self.title = textField.text;
            if (indexPath.row == 1) self.description = textField.text;
            if (indexPath.row == 3) self.price = @([textField.text floatValue]);
            if (indexPath.row == 4) self.discount = @([textField.text floatValue]);
            if (indexPath.row == 5) self.latitude = @([textField.text floatValue]);
            if (indexPath.row == 6) self.longitude = @([textField.text floatValue]);
            if (indexPath.row == 7) self.imageUrl = textField.text;
        }
    }
}

- (BOOL)validateForm:(NSError *__autoreleasing *)error
{
    NSString *title = _eventForEdit? _eventForEdit.title: self.title;
    NSNumber *price = _eventForEdit? _eventForEdit.price: self.price;
    
    if (!title || title.length == 0)
    {
        *error = [NSError errorWithDomain:@"VAValidationError"
                                     code:0
                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Title cann't be empty", nil)}];
        return NO;
    }
    if (![price floatValue])
    {
        *error = [NSError errorWithDomain:@"VAValidationError"
                                     code:0
                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Price cann't be 0", nil)}];
        return NO;
    }
    
    return YES;
}

-(NSString *) genRandStringLength: (int) len {
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

- (IBAction)handleDone:(id)sender {
    [self.tableView resignAllResponder];
    NSError *error = nil;
    if (![self validateForm:&error])
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                    message:error.localizedDescription
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                          otherButtonTitles:nil] show];
        return;
    }
    if (_eventForEdit)
    {
        if (self.imageUrl.length)
        {
            Image *eventImage = nil;
            if([_eventForEdit.images count])
            {
                eventImage = [[_eventForEdit.images allObjects] objectAtIndex:0];
                eventImage.imageUrl = self.imageUrl;
            }
            else
            {
                eventImage = [Image createEntity];
                eventImage.identifier = [self genRandStringLength:12];
                [_eventForEdit addImagesObject:eventImage];
            }
        }
        [[TBWebEngine sharedManager] putEvent:_eventForEdit success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                            message:@"Event was edited"
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    }
    else
    {
        Event *newEvent = [Event createEntity];
        newEvent.title = self.title;
        newEvent.eventDescription = self.description;
        newEvent.price = self.price;
        newEvent.discount = self.discount;
        newEvent.latitude = self.latitude;
        newEvent.longitude = self.longitude;
        newEvent.owner = [[TBWebEngine sharedManager] userId];
        newEvent.date = self.date;
        Image *eventImage = [Image createEntity];
        eventImage.imageUrl = self.imageUrl;
        eventImage.identifier = [self genRandStringLength:12];
        
        [newEvent addImagesObject:eventImage];
        
        [[TBWebEngine sharedManager] postEvent:newEvent success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                            message:@"Event was added"
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - DateCell delegate

- (void)tableViewCell:(DateInputTableViewCell *)cell didEndEditingWithDate:(NSDate *)value {
	NSLog(@"%@ date changed to: %@", cell.textField.text, value);
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    cell.textField.text = [formatter stringFromDate:value];
    if(_eventForEdit)
        _eventForEdit.date = [formatter stringFromDate:value];
    else
        self.date = [formatter stringFromDate:value];
}

@end
