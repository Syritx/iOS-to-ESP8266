//
//  ViewController.m
//  sockets
//
//  Created by Syritx on 2021-01-20.
//

#import "ViewController.h"
#import <CFNetwork/CFNetwork.h>
#import <Foundation/Foundation.h>
#import <stdio.h>
#import <string.h>
#import <stdlib.h>
#import <unistd.h>
#import <pthread.h>
#import <sys/socket.h>
#import <sys/un.h>
#import <sys/stat.h>
#import <sys/types.h>
#import <netinet/in.h>
#import <UIKit/UIKit.h>
#include <arpa/inet.h>

@interface ViewController ()

@end

@implementation ViewController

- (IBAction) sendMessageToServer : (id)sender {
    NSLog(@"sending");
    NSData *data = [[NSData alloc] initWithData:[@"[get_data]" dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
    
    
    uint8_t buffer[1024];
    int len;
    while ([inputStream hasBytesAvailable]) {
        len = [inputStream read:buffer maxLength:sizeof(buffer)];
        if (len > 0) {
            NSLog(@"got data");
            NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
            if (output != nil) {
                NSLog(@"%@", output);
                NSArray* COMMANDS = [output componentsSeparatedByString: @"[command_buffer]"];
                for (int i = 0; i < [COMMANDS count]; i++) {
                    NSLog(@"%@ index: %d", [COMMANDS objectAtIndex: i], i);
                    if ([[COMMANDS objectAtIndex: i] hasPrefix: @"[temperature]:"]) {
                        [temperatureLabel setText: [[COMMANDS objectAtIndex: i] uppercaseString]];
                    }
                    if ([[COMMANDS objectAtIndex: i] hasPrefix: @"[humidity]:"]) {
                        [humidityLabel setText: [[COMMANDS objectAtIndex: i] uppercaseString]];
                    }
                }
            }
        }
    }
}

- (IBAction) connectToServer : (id)sender {
    
    // CHANGE 'HOST' VARIABLE DECLARED AT LINE 96
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)HOST, 6060, &readStream, &writeStream);
    
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
    
    NSData *data = [[NSData alloc] initWithData:[@"IPhone app connected" dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
    
    
    NSLog(@"here");
}

- (IBAction) disconnectFromServer : (id)sender {
    NSLog(@"sending");
    NSData *data = [[NSData alloc] initWithData:[@"disconnect_ed" dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
    [outputStream close];
}

void getSocketCallBack(CFSocketRef cfSocketRef, CFSocketCallBackType cbType, CFDataRef address, const void *data, void *info) {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // IMPORTANT //
    HOST = @"ip-here"; // i.e. X.X.X.X
    
    UIView *mainview;
    [mainview setBackgroundColor: [UIColor blackColor]];
    
    float width = UIScreen.mainScreen.bounds.size.width-40;
    float yOffset = 20;
    float inlineOffset = 10;
    
    UIButton *messageButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 20+yOffset+inlineOffset, width, 50)];
    [messageButton setBackgroundColor:[UIColor linkColor]];
    [messageButton addTarget:self action:@selector(sendMessageToServer:) forControlEvents:UIControlEventTouchUpInside];
    [messageButton setTitle:@"Request Data" forState:UIControlStateNormal];
    
    UIButton *connect = [[UIButton alloc] initWithFrame: CGRectMake(20, 70+yOffset+inlineOffset*2, width, 50)];
    [connect setBackgroundColor:[UIColor linkColor]];
    [connect addTarget:self action:@selector(connectToServer:) forControlEvents:UIControlEventTouchUpInside];
    [connect setTitle:@"Connect" forState:UIControlStateNormal];
    
    UIButton *disconnect = [[UIButton alloc] initWithFrame: CGRectMake(20, 120+yOffset+inlineOffset*3, width, 50)];
    [disconnect setBackgroundColor:[UIColor linkColor]];
    [disconnect addTarget:self action:@selector(disconnectFromServer:) forControlEvents:UIControlEventTouchUpInside];
    [disconnect setTitle:@"Disconnect" forState:UIControlStateNormal];
    
    temperatureLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 170+yOffset+inlineOffset*4, width, 50)];
    [temperatureLabel setText: @"[TEMPERATURE]: "];
    [temperatureLabel setTextColor: [UIColor whiteColor]];
    [temperatureLabel setBackgroundColor: [UIColor blackColor]];
    
    humidityLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 200+yOffset+inlineOffset*5, width, 50)];
    [humidityLabel setText: @"[HUMIDITY]: "];
    [humidityLabel setTextColor: [UIColor whiteColor]];
    [humidityLabel setBackgroundColor: [UIColor blackColor]];
    
    [self.view setBackgroundColor: [UIColor blackColor]];
    [self.view addSubview: mainview];
    [self.view addSubview: messageButton];
    [self.view addSubview: connect];
    [self.view addSubview: disconnect];
    [self.view addSubview: temperatureLabel];
    [self.view addSubview: humidityLabel];
}

@end
