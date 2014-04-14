//
//  SA_OAuthTwitterController.m
//
//  Created by Ben Gottlieb on 24 July 2009.
//  Copyright 2009 Stand Alone, Inc.
//
//  Some code and concepts taken from examples provided by
//  Matt Gemmell, Chris Kimpton, and Isaiah Carew
//  See ReadMe for further attributions, copyrights and license info.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "SA_OAuthTwitterEngine.h"

#import "SA_OAuthTwitterController.h"
//#import "UIImage+Additions.h"

#define kNavigationBarHeightPortrait 44.f
#define kNavigationBarHeightLandscape 32.f

// Constants
static NSString* const kGGTwitterLoadingBackgroundImage = @"twitter_load.png";

@interface SA_OAuthTwitterController ()
@property (nonatomic, readonly) UIToolbar *pinCopyPromptBar;
@property (nonatomic, readwrite) UIInterfaceOrientation orientation;

- (id) initWithEngine: (SA_OAuthTwitterEngine *) engine andOrientation:(UIInterfaceOrientation)theOrientation;
//- (void) performInjection;
- (NSString *) locateAuthPinInWebView: (UIWebView *) webView;

- (void) showPinCopyPrompt;
- (void) gotPin: (NSString *) pin;
@end


@interface DummyClassForProvidingSetDataDetectorTypesMethod
- (void) setDataDetectorTypes: (int) types;
- (void) setDetectsPhoneNumbers: (BOOL) detects;
@end

@interface NSString (TwitterOAuth)
- (BOOL) oauthtwitter_isNumeric;
@end

@implementation NSString (TwitterOAuth)
- (BOOL) oauthtwitter_isNumeric {
	const char				*raw = (const char *) [self UTF8String];
	
	for (int i = 0; i < strlen(raw); i++) {
		if (raw[i] < '0' || raw[i] > '9') return NO;
	}
	return YES;
}
@end


@implementation SA_OAuthTwitterController
@synthesize engine = _engine, delegate = _delegate, navigationBar = _navBar, orientation = _orientation;


- (void) dealloc {
	[_backgroundView release];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	_webView.delegate = nil;
	[_webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: @""]]];
	[_webView release];
	
	self.view = nil;
	self.engine = nil;
	[super dealloc];
}

+ (SA_OAuthTwitterController *) controllerToEnterCredentialsWithTwitterEngine: (SA_OAuthTwitterEngine *) engine delegate: (id <SA_OAuthTwitterControllerDelegate>) delegate forOrientation: (UIInterfaceOrientation)theOrientation {
	if (![self credentialEntryRequiredWithTwitterEngine: engine]) return nil;			//not needed
	
	SA_OAuthTwitterController					*controller = [[[SA_OAuthTwitterController alloc] initWithEngine: engine andOrientation: theOrientation] autorelease];
	
	controller.delegate = delegate;
	return controller;
}

+ (SA_OAuthTwitterController *) controllerToEnterCredentialsWithTwitterEngine: (SA_OAuthTwitterEngine *) engine delegate: (id <SA_OAuthTwitterControllerDelegate>) delegate {
	return [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: engine delegate: delegate forOrientation: UIInterfaceOrientationPortrait];
}


+ (BOOL) credentialEntryRequiredWithTwitterEngine: (SA_OAuthTwitterEngine *) engine {
	return ![engine isAuthorized];
}


- (id) initWithEngine: (SA_OAuthTwitterEngine *) engine andOrientation:(UIInterfaceOrientation)theOrientation {
	if (self = [super init]) {
		self.engine = engine;
		if (!engine.OAuthSetup) [_engine requestRequestToken];
		self.orientation = theOrientation;
		_firstLoad = YES;
		
		if (UIInterfaceOrientationIsLandscape( self.orientation ) )
			_webView = [[UIWebView alloc] init];
		else
			_webView = [[UIWebView alloc] init];
		
		_webView.alpha = 0.0;
		_webView.delegate = self;
		_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		if ([_webView respondsToSelector: @selector(setDetectsPhoneNumbers:)]) [(id) _webView setDetectsPhoneNumbers: NO];
		if ([_webView respondsToSelector: @selector(setDataDetectorTypes:)]) [(id) _webView setDataDetectorTypes: 0];
		
		NSURLRequest			*request = _engine.authorizeURLRequest;
        DLog(@"request = %@", request);
		[_webView loadRequest: request];

		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(pasteboardChanged:) name: UIPasteboardChangedNotification object: nil];
	}
	return self;
}

//=============================================================================================================================
#pragma mark Actions
- (void) denied {
	if ([_delegate respondsToSelector: @selector(OAuthTwitterControllerFailed:)]) [_delegate OAuthTwitterControllerFailed: self];
	[self performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 1.0];
}

- (void) gotPin: (NSString *) pin {
	_engine.pin = pin;
	[_engine requestAccessToken];
	
	if ([_delegate respondsToSelector: @selector(OAuthTwitterController:authenticatedWithUsername:)]) [_delegate OAuthTwitterController: self authenticatedWithUsername: _engine.username];
	[self performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 1.0];
}

- (void) cancel: (id) sender {
	if ([_delegate respondsToSelector: @selector(OAuthTwitterControllerCanceled:)]) [_delegate OAuthTwitterControllerCanceled: self];
	[self performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
}

//=============================================================================================================================
#pragma mark View Controller Stuff
- (void) loadView {
	[super loadView];

    CGFloat offset = 0.f;
#ifdef __IPHONE_7_0
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        // shift frames;
        offset =  20.f;
    }
#endif
    
	_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kGGTwitterLoadingBackgroundImage]];
	_backgroundView.backgroundColor = [UIColor blackColor];
    
	if ( UIInterfaceOrientationIsLandscape( self.orientation ) ) {
        _navBar = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0, offset, self.view.frame.size.width, kNavigationBarHeightLandscape)] autorelease];
        _backgroundView.frame =  CGRectMake(0, offset + kNavigationBarHeightLandscape, self.view.frame.size.width, self.view.frame.size.height - kNavigationBarHeightLandscape - offset);
		
	} else {
        _navBar = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0, offset, self.view.frame.size.width, kNavigationBarHeightPortrait)] autorelease];
        _backgroundView.frame =  CGRectMake(0, kNavigationBarHeightPortrait + offset, self.view.frame.size.width, self.view.frame.size.height - kNavigationBarHeightPortrait - offset);
	}
	_navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _navBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UIColor *color = [UIColor whiteColor];
    if (color) {
#ifdef __IPHONE_7_0
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            // IPAD-1593 TourDeFrance, iOS 7: Issues related with new design
            // 4. Incorrect status bar background for Twitter screen (screen 4)
            self.view.backgroundColor = color;
            
            if ([self.navigationBar respondsToSelector:@selector(setBarTintColor:)])
                [self.navigationBar performSelector:@selector(setBarTintColor:) withObject:color];
            
            self.navigationBar.translucent = NO;
            self.navigationBar.tintColor = [UIColor whiteColor];
        }
        else
#endif
            self.navigationBar.tintColor = color;
    }
    
	if (!UIInterfaceOrientationIsLandscape( self.orientation)) [self.view addSubview:_backgroundView];
	
    _webView.frame = _backgroundView.frame;

	[self.view addSubview: _webView];
	[self.view addSubview: _navBar];
	
	_blockerView = [[[UIView alloc] initWithFrame: CGRectMake(0, 0, 200, 60)] autorelease];
	_blockerView.backgroundColor = [UIColor colorWithWhite: 0.0 alpha: 0.8];
	_blockerView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
	_blockerView.alpha = 0.0;
	_blockerView.clipsToBounds = YES;
	if ([_blockerView.layer respondsToSelector: @selector(setCornerRadius:)]) [(id) _blockerView.layer setCornerRadius: 10];
	
	UILabel	*label = [[[UILabel alloc] initWithFrame: CGRectMake(0, 5, _blockerView.bounds.size.width, 15)] autorelease];
	label.text = NSLocalizedString(@"Please Wait…", nil);
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont boldSystemFontOfSize: 15];
	[_blockerView addSubview: label];
	
	UIActivityIndicatorView				*spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite] autorelease];
	
	spinner.center = CGPointMake(_blockerView.bounds.size.width / 2, _blockerView.bounds.size.height / 2 + 10);
	[_blockerView addSubview: spinner];
	[self.view addSubview: _blockerView];
	[spinner startAnimating];
	
	UINavigationItem				*navItem = [[[UINavigationItem alloc] initWithTitle: NSLocalizedString(@"Twitter Info", nil)] autorelease];
	navItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target: self action: @selector(cancel:)] autorelease];
	
	[_navBar pushNavigationItem: navItem animated: NO];
	[self locateAuthPinInWebView: nil];
}

#pragma mark - UIViewController (UIViewControllerRotation)

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation {
	self.orientation = self.interfaceOrientation;
	_blockerView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
//	[self performInjection];			//removed due to twitter update
}

//=============================================================================================================================
#pragma mark Notifications
- (void) pasteboardChanged: (NSNotification *) note {
	UIPasteboard *pb = [UIPasteboard generalPasteboard];
	
	if ([note.userInfo objectForKey: UIPasteboardChangedTypesAddedKey] == nil) return;		//no meaningful change
	
	NSString *copied = pb.string;
	
	if (copied.length != 7 || !copied.oauthtwitter_isNumeric) return;
	
	[self gotPin: copied];
}

//=============================================================================================================================
#pragma mark Webview Delegate stuff
- (void) webViewDidFinishLoad: (UIWebView *) webView {
	_loading = NO;
	//[self performInjection];
	if (_firstLoad) {
		[_webView performSelector: @selector(stringByEvaluatingJavaScriptFromString:) withObject: @"window.scrollBy(0,200)" afterDelay: 0];
		_firstLoad = NO;
	} else {
		NSString *authPin = [self locateAuthPinInWebView: webView];
        
		if (authPin.length) {
			[self gotPin: authPin];
			return;
		}
		
		NSString *formCount = [webView stringByEvaluatingJavaScriptFromString: @"document.forms.length"];
		
		if ([formCount isEqualToString: @"0"]) {
			[self showPinCopyPrompt];
		}
	}    
	
	[UIView beginAnimations: nil context: nil];
	_blockerView.alpha = 0.0;
	[UIView commitAnimations];
	
	if ([_webView isLoading]) {
		_webView.alpha = 0.0;
	} else {
		_webView.alpha = 1.0;
	}
}

- (void) showPinCopyPrompt {
	if (self.pinCopyPromptBar.superview) return;		//already shown
	self.pinCopyPromptBar.center = CGPointMake(self.pinCopyPromptBar.bounds.size.width / 2, self.pinCopyPromptBar.bounds.size.height / 2);
	[self.view insertSubview: self.pinCopyPromptBar belowSubview: self.navigationBar];
	
	[UIView beginAnimations: nil context: nil];
	self.pinCopyPromptBar.center = CGPointMake(self.pinCopyPromptBar.bounds.size.width / 2, self.navigationBar.bounds.size.height + self.pinCopyPromptBar.bounds.size.height / 2);
	[UIView commitAnimations];
}

/*********************************************************************************************************
 I am fully aware that this code is chock full 'o flunk. That said:
 
 - first we check, using standard DOM-diving, for the pin, looking at both the old and new tags for it.
 - if not found, we try a regex for it. This did not work for me (though it did work in test web pages).
 - if STILL not found, we iterate the entire HTML and look for an all-numeric 'word', 7 characters in length

Ugly. I apologize for its inelegance. Bleah.

*********************************************************************************************************/

- (NSString *) locateAuthPinInWebView: (UIWebView *) webView {
	NSString			*js = @"var d = document.getElementById('oauth-pin'); if (d == null) d = document.getElementById('oauth_pin'); if (d) d = d.innerHTML; if (d == null) {var r = new RegExp('\\\\s[0-9]+\\\\s'); d = r.exec(document.body.innerHTML); if (d.length > 0) d = d[0];} d.replace(/^\\s*/, '').replace(/\\s*$/, ''); d;";
	NSString			*pin = [webView stringByEvaluatingJavaScriptFromString: js];
	
//	if (pin.length > 0) return pin;
	
	NSString			*html = [webView stringByEvaluatingJavaScriptFromString: @"document.body.innerText"];
	
	if (html.length == 0) return nil;
	
	const char			*rawHTML = (const char *) [html UTF8String];
	int					length = strlen(rawHTML), chunkLength = 0;
	
	for (int i = 0; i < length; i++) {
		if (rawHTML[i] < '0' || rawHTML[i] > '9') {
			if (chunkLength == 7) {
				char				*buffer = (char *) malloc(chunkLength + 1);
				
				memmove(buffer, &rawHTML[i - chunkLength], chunkLength);
				buffer[chunkLength] = 0;
				
				pin = [NSString stringWithUTF8String: buffer];
				free(buffer);
				return pin;
			}
			chunkLength = 0;
		} else
			chunkLength++;
	}
	
	return nil;
    #pragma unused(pin)
}

- (UIToolbar *) pinCopyPromptBar {
	if (_pinCopyPromptBar == nil){
		CGRect					bounds = self.view.bounds;
		
		_pinCopyPromptBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 44, bounds.size.width, 44)] autorelease];
		_pinCopyPromptBar.barStyle = UIBarStyleBlackTranslucent;
		_pinCopyPromptBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;

		_pinCopyPromptBar.items = [NSArray arrayWithObjects: 
							  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil] autorelease],
							  [[[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Select and Copy the PIN", @"Select and Copy the PIN") style: UIBarButtonItemStylePlain target: nil action: nil] autorelease], 
							  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil] autorelease], 
							nil];
	}
	
	return _pinCopyPromptBar;
}



//removed since Twitter changed the page format
//- (void) performInjection {
//	if (_loading) return;
//	
//	NSError					*error;
//	NSString				*filename = UIInterfaceOrientationIsLandscape(self.orientation ) ? @"jQueryInjectLandscape" : @"jQueryInject";
//	NSString				*path = [[NSBundle mainBundle] pathForResource: filename ofType: @"txt"];
//	
//    NSString *dataSource = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
//	
//    if (dataSource == nil) {
//        NSLog(@"An error occured while processing the jQueryInject file");
//    }
//	
//	[_webView stringByEvaluatingJavaScriptFromString:dataSource]; //This line injects the jQuery to make it look better	
//}

- (void) webViewDidStartLoad: (UIWebView *) webView {
	//[_activityIndicator startAnimating];
	_loading = YES;
	[UIView beginAnimations: nil context: nil];
	_blockerView.alpha = 1.0;
	[UIView commitAnimations];
}


- (BOOL) webView: (UIWebView *) webView shouldStartLoadWithRequest: (NSURLRequest *) request navigationType: (UIWebViewNavigationType) navigationType {
    NSString *urlString = [NSString stringWithFormat:@"%@", [request URL]];
    // check for the Twitter dev app's callback URL
    if ([urlString rangeOfString:@"https://dev.twitter.com"].location == NSNotFound) {
        NSData *data = [request HTTPBody];
        char *raw = data ? (char *) [data bytes] : "";
        
        if (raw && strstr(raw, "cancel=")) {
            [self denied];
            return NO;
        }
        if (navigationType != UIWebViewNavigationTypeOther)
            _webView.alpha = 0.1;
        return YES;
    } else {
        //Do authentication for request
        [self gotPin: nil];
        return NO;
    }
}

@end
