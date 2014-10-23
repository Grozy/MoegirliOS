//
//  mcViewController.m
//  moegirlwiki
//
//  Created by master on 14-10-21.
//  Copyright (c) 2014年 masterchan.me. All rights reserved.
//

#import "mcViewController.h"

@interface mcViewController ()

@end

@implementation mcViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _webViewList = [NSMutableArray new];
    _appDelegate = [[UIApplication sharedApplication] delegate];
    [_appDelegate setHook:self];
    webViewListPosition = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self visualInit];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self resetSizes];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)visualInit
{
    // 搜索框的圆角
    _SearchBox.layer.cornerRadius = 5;
    _SearchBox.layer.masksToBounds = YES;
    
    // 搜索建议框
    _searchSuggestionsTableView = [moegirlSearchSuggestionsTableView new];
    [_searchSuggestionsTableView setFrame:_MasterInitial.frame];
    [_searchSuggestionsTableView setDataSource:_searchSuggestionsTableView];
    [_searchSuggestionsTableView setDelegate:_searchSuggestionsTableView];
    [_searchSuggestionsTableView setHook:self];
    [_searchSuggestionsTableView setRowHeight:40];
    [_searchSuggestionsTableView setTargetURL:@"http://zh.moegirl.org"];
    [_MainView addSubview:_searchSuggestionsTableView];

    
    // 首页
    _mainPageScrollView = [moegirlMainPageScrollView new];
    [_mainPageScrollView setFrame:_MasterInitial.frame];
    [_mainPageScrollView setDelegate:_mainPageScrollView];
    [_mainPageScrollView setHook:self];
    [_mainPageScrollView setTargetURL:@"http://zh.moegirl.org"];
    [_mainPageScrollView loadMainPage:YES];
    [_MainView addSubview:_mainPageScrollView];
    
}

- (void)resetSizes
{
    [_mainPageScrollView setFrame:_MasterInitial.frame];
    [_mainPageScrollView refreshScrollView];
    [_searchSuggestionsTableView setFrame:_MasterInitial.frame];
    for (int i = 0 ; i < _webViewList.count; i++) {
        [[_webViewList objectAtIndex:i] setFrame:_MasterInitial.frame];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [UIView animateWithDuration:0.2
                          delay:0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         /*----------------------*/
                         [self resetSizes];
                         /*----------------------*/
                     }
                     completion:^(BOOL finished){
                         /*----------------------*/
                         
                         /*----------------------*/
                     }];
}

- (void)cancelKeyboard
{
    [_SearchTextField resignFirstResponder];
}

- (void)urlSchemeCall:(NSString *)target
{
    NSLog(@"%@",target);
    NSRange rangeA = [target rangeOfString:@"?w="];
    if (rangeA.location != NSNotFound) {
        target = [target substringFromIndex:rangeA.location + 3];
        [self createMoeWebView:target];
    }
}

- (void)createMoeWebView:(NSString *)target
{
    moegirlWebView * webView = [moegirlWebView new];
    [webView setFrame:_MasterInitial.frame];
    [webView setTargetURL:@"http://zh.moegirl.org"];
    [webView setDelegate:webView];
    [webView setHook:self];
    [webView loadContentWithDecodedKeyWord:target useCache:YES];
    [_MainView addSubview:webView];
    [_webViewList addObject:webView];
    webViewListPosition ++;
    for (int i = webViewListPosition; i < _webViewList.count ; i++) {
        [[_webViewList objectAtIndex:i] cancel];
        [_webViewList removeObjectAtIndex:i];
    }
}

- (IBAction)searchFieldEditChange:(id)sender
{
    if ([_SearchTextField.text isEqual:@""]) {
        [_MainView sendSubviewToBack:_searchSuggestionsTableView];
        return;
    }
    NSString * Keyword = _SearchTextField.text;
    NSRange rangeA = [Keyword rangeOfString:@" "];
    if (rangeA.location != NSNotFound) {
        Keyword = [Keyword substringToIndex:rangeA.location];
    }
    [_searchSuggestionsTableView checkSuggestions:Keyword];
    [_MainView bringSubviewToFront:_searchSuggestionsTableView];
}

- (void)newWebViewRequestFormWebView:(NSString *)decodedKeyword
{
    [self createMoeWebView:decodedKeyword];
}

@end
