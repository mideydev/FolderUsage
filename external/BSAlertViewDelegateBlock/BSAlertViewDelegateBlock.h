//
//  BSAlertViewDelegateBlock.h
//  SpeechTimer2
//
//  Created by Sasmito Adibowo on 25-12-13.
//  Copyright (c) 2013-2014 Basil Salad Software. All rights reserved.
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

#import <UIKit/UIKit.h>

/**
 Adapts UIAlertViewDelegate protocol into a block-friendly interface.
 */
@interface BSAlertViewDelegateBlock : NSObject<UIAlertViewDelegate>

/**
 Designated initializer.
 */
-(id) initWithAlertView:(UIAlertView*) alertView;

@property (nonatomic,strong) void(^clickedButtonAtIndexBlock)(UIAlertView* alertView,NSInteger buttonIndex);
@property (nonatomic,strong) void(^alertViewCancelBlock)(UIAlertView* alertView);
@property (nonatomic,strong) void(^willPresentAlertViewBlock)(UIAlertView* alertView);
@property (nonatomic,strong) void(^didPresentAlertViewBlock)(UIAlertView* alertView);

@property (nonatomic,strong) void(^willDismissWithButtonIndexBlock)(UIAlertView* alertView,NSInteger buttonIndex);
@property (nonatomic,strong) void(^didDismissWithButtonIndexBlock)(UIAlertView* alertView,NSInteger buttonIndex);

@property (nonatomic,strong) BOOL(^alertViewShouldEnableFirstOtherButtonBlock)(UIAlertView* alertView);

@end
