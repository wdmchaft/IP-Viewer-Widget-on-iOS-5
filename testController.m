#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BBWeeAppController-Protocol.h"
#include <arpa/inet.h>
#include <ifaddrs.h>

float VIEW_HEIGHT = 70.0f;

@interface testController : NSObject <BBWeeAppController, UIGestureRecognizerDelegate> {
	UIView *_view;
	UILabel *ipAddress;
	UITapGestureRecognizer *tap;
}

- (NSString*)getIP;

@end


@implementation testController

- (id)init {
	if ((self = [super init]))
	{

	}
	return self;
}

- (UIView *)view {
	if (!_view) {
		_view = [[UIView alloc] initWithFrame:CGRectMake(2.0f, 0.0f, 316.0f, VIEW_HEIGHT)];

		UIImage *bgImg = [[UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/StocksWeeApp.bundle/WeeAppBackground.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(35.0f, 4.0f, 35.0f, 4.0f)];
		UIImageView *bg = [[UIImageView alloc] initWithImage:bgImg];
		bg.frame = CGRectMake(0.0f, 0.0f, 316.0f, VIEW_HEIGHT);
		[_view addSubview:bg];
		[bg release];

		tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ipReload:)];
		[_view addGestureRecognizer:tap];

		CGFloat width = _view.frame.size.width;
		CGFloat height = _view.frame.size.height;

		ipAddress = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];


		[ipAddress setText:[NSString stringWithFormat:@"%@", [self getIP]]];
		[ipAddress setFont:[UIFont fontWithName:@"Helvetica Bold" size:25.0]];
		[ipAddress setShadowOffset:CGSizeMake(1, 1)];
		[ipAddress setTextColor:[UIColor whiteColor]];
		[ipAddress setTextAlignment:UITextAlignmentCenter];
		[ipAddress adjustsFontSizeToFitWidth];
		[ipAddress baselineAdjustment];
		[ipAddress setBackgroundColor:[UIColor clearColor]];
		[ipAddress clipsToBounds];


		CGFloat size = 15;

		UIButton *refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(_view.frame.size.width-size, _view.frame.size.height-size, size, size+2)];
		//    [refreshButton setBackgroundImage:[UIImage imageNamed:@"01-refresh.png"] forState:UIControlStateNormal];
		[refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
		[refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[refreshButton addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchDown];
		[refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[_view addSubview:refreshButton];
		[_view addSubview:ipAddress];

	}
	return _view;

}



- (NSString*)getIP {
	NSString *address = @"No WiFi/IP. Tap to refresh.";
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *temp_addr = NULL;
	int success = 0;
	// retrieve the current interfaces - returns 0 on success
	success = getifaddrs(&interfaces);
	if (success == 0) {
		// Loop through linked list of interfaces
		temp_addr = interfaces;
		while(temp_addr != NULL) {
			if(temp_addr->ifa_addr->sa_family == AF_INET) {
				// Check if interface is en0 which is the wifi connection on the iPhone
				if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
					// Get NSString from C String
					address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];

				} 

			}

			temp_addr = temp_addr->ifa_next;
		}
	}  
	// Free memory
	freeifaddrs(interfaces);
	return address;
}

- (void) ipReload:(UITapGestureRecognizer*)tap {
	[ipAddress setText:[NSString stringWithFormat:@"%@", [self getIP]]];
}

- (void)viewWillAppear {
	[ipAddress setText:[NSString stringWithFormat:@"%@", [self getIP]]];
}

- (void) refresh:(id)sender {
	[ipAddress setText:[NSString stringWithFormat:@"%@", [self getIP]]];
}

- (float)viewHeight{
	return VIEW_HEIGHT;
}

@end
