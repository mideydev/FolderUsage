//
//  BSAlertViewDelegateBlock.m
//  SpeechTimer2
//
//  Created by Sasmito Adibowo on 25-12-13.
//  Copyright (c) 2013-2014 Basil Salad Software. All rights reserved.
//  http://basilsalad.com
//
//  Licensed under the BSD License <http://www.opensource.org/licenses/bsd-license>
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
//  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
//  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//


#import <objc/runtime.h>

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

#import "BSAlertViewDelegateBlock.h"

const char* const BSAlertViewDelegateBlockKey = "BSAlertViewDelegateBlockKey";

@interface BSAlertViewDelegateBlock ()

@property (nonatomic,weak) UIAlertView* alertView;

@end

@implementation BSAlertViewDelegateBlock

-(void) alertViewDelegateBlock_cleanup
{
    UIAlertView* alertView = self.alertView;
    
    // remove all handler blocks in case one of these blocks inadvertendly caused a circular reference to this delegate object.
    self.clickedButtonAtIndexBlock  = nil;
    self.alertViewCancelBlock = nil;
    self.willPresentAlertViewBlock = nil;
    self.didPresentAlertViewBlock = nil;
    self.willDismissWithButtonIndexBlock = nil;
    self.didDismissWithButtonIndexBlock = nil;
    self.alertViewShouldEnableFirstOtherButtonBlock = nil;
    
    // finally remove this delegate from the alert view
    if (alertView.delegate == self) {
        alertView.delegate = nil;
        objc_setAssociatedObject(alertView, BSAlertViewDelegateBlockKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

-(id) initWithAlertView:(UIAlertView *)alertView
{
    if (self = [super init]) {
        self.alertView = alertView;
        objc_setAssociatedObject(alertView, BSAlertViewDelegateBlockKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        alertView.delegate = self;
    }
    return self;
}


#pragma mark UIAlertViewDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    void(^clickedButtonAtIndexBlock)(UIAlertView* alertView,NSInteger buttonIndex) = self.clickedButtonAtIndexBlock;
    if (clickedButtonAtIndexBlock) {
        clickedButtonAtIndexBlock(alertView,buttonIndex);
    }
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(UIAlertView *)alertView
{
    void(^alertViewCancelBlock)(UIAlertView* alertView) = self.alertViewCancelBlock;
    if (alertViewCancelBlock) {
        alertViewCancelBlock(alertView);
    }
    [self alertViewDelegateBlock_cleanup];
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    void(^willPresentAlertViewBlock)(UIAlertView* alertView) = self.willPresentAlertViewBlock;
    if (willPresentAlertViewBlock) {
        willPresentAlertViewBlock(alertView);
    }   
}


- (void)didPresentAlertView:(UIAlertView *)alertView
{
    void(^didPresentAlertViewBlock)(UIAlertView* alertView) = self.didPresentAlertViewBlock;
    if (didPresentAlertViewBlock) {
        didPresentAlertViewBlock(alertView);
    }   
}


- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    void(^willDismissWithButtonIndexBlock)(UIAlertView* alertView,NSInteger buttonIndex) = self.willDismissWithButtonIndexBlock;
    if (willDismissWithButtonIndexBlock) {
        willDismissWithButtonIndexBlock(alertView,buttonIndex);
    }
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	void(^didDismissWithButtonIndexBlock)(UIAlertView* alertView,NSInteger buttonIndex) = self.didDismissWithButtonIndexBlock;
    if (didDismissWithButtonIndexBlock) {
        didDismissWithButtonIndexBlock(alertView,buttonIndex);
    }   
    [self alertViewDelegateBlock_cleanup];
}


- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    BOOL(^alertViewShouldEnableFirstOtherButtonBlock)(UIAlertView* alertView) = self.alertViewShouldEnableFirstOtherButtonBlock;
    if (alertViewShouldEnableFirstOtherButtonBlock) {
        return alertViewShouldEnableFirstOtherButtonBlock(alertView);
    }   

    // default to enable.
    return YES;
}

@end

#pragma GCC diagnostic pop
