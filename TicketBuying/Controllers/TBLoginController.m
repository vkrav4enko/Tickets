//
//  TBLoginController.m
//  TicketBuying
//
//  Created by Владимир on 09.10.13.
//  Copyright (c) 2013 Rost's company. All rights reserved.
//

#import "TBLoginController.h"
#import <AFNetworking/AFNetworking.h>
#import "TBWebEngine.h"
#define DEBUG_LOGIN YES

@interface TBLoginController () <UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) NSURL *baseURL;
- (IBAction)loginPressed:(id)sender;

@end

@implementation TBLoginController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (DEBUG_LOGIN)
    {
        _usernameField.text = @"admin";
        _passwordField.text = @"111111";
    }
    _baseURL = [[TBWebEngine sharedManager] baseURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginPressed:(id)sender {
    NSString *login = _usernameField.text;
    NSString *password = _passwordField.text;
    AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL: _baseURL];
    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"login" parameters:@{@"username": login, @"password": password}];
    AFHTTPRequestOperation *jsonOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog (@"%@", JSON);
        [[TBWebEngine sharedManager] setToken:[response.allHeaderFields valueForKey:@"token"]];
        [[TBWebEngine sharedManager] setUserId: [JSON objectForKey:@"userId"]]; 
        [self performSegueWithIdentifier:@"Events" sender:self];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[JSON valueForKey:@"status"]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        if ([[JSON valueForKey:@"status"] isEqualToString:@"User not found"])
        {
            [alert addButtonWithTitle:@"Register new"];
        }
        [alert show];
    }];
    [jsonOperation start];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Register new"])
    {
        NSString *login = _usernameField.text;
        NSString *password = _passwordField.text;
        AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL: _baseURL];
        [httpClient setParameterEncoding:AFJSONParameterEncoding];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"registration" parameters:@{@"username": login, @"password": password}];
        AFHTTPRequestOperation *jsonOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            NSLog (@"%@", JSON);
            [[TBWebEngine sharedManager] setToken:[response.allHeaderFields valueForKey:@"token"]];
            [[TBWebEngine sharedManager] setUserId: [JSON objectForKey:@"userId"]];
            [self performSegueWithIdentifier:@"Events" sender:self];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:[JSON valueForKey:@"status"]
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }];
        [jsonOperation start];
    }
}





@end
