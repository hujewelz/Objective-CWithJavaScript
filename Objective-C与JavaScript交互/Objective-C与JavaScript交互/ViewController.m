//
//  ViewController.m
//  Objective-C与JavaScript交互
//
//  Created by mac on 16/4/12.
//  Copyright (c) 2016年 hujewelz. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSObjectDelegate <JSExport>

- (void)pickImage;

@end

@interface ViewController () <UIWebViewDelegate, JSObjectDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    NSURL *_baseURL;
    NSString *_htmlStr;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) JSContext *jsContent;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil];
    NSString *htmlStr = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    _htmlStr = htmlStr;
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    _baseURL = baseURL;
    [self.webView loadHTMLString:htmlStr baseURL:baseURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refresh:(id)sender {
   [self.webView loadHTMLString:_htmlStr baseURL:_baseURL];
}

- (IBAction)buttonClicked:(UIButton *)sender {
    JSValue *value = self.jsContent[@"buttonClick"];
    [value callWithArguments:@[@(sender.tag)]];
}

#pragma mark - web view delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.jsContent = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContent[@"App"] = self;
    self.jsContent.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"异常信息：%@", exception);
    };
    
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"error: %@", error);
}

#pragma mark - JSObjectDelegate

- (void)pickImage {
    NSLog(@"info: %@", [NSThread currentThread]);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImagePickerController *pickvc = [[UIImagePickerController alloc] init];
        pickvc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickvc.delegate = self;
        [self presentViewController:pickvc animated:YES completion:nil];
    });
    
}

#pragma mark - image picker controller delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"info: %@", [NSThread currentThread]);
    [self dismissViewControllerAnimated:YES completion:nil];
    JSValue *picCallback = self.jsContent[@"picCallback"];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSString *url = info[UIImagePickerControllerReferenceURL];
    [picCallback callWithArguments:@[url]];
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
