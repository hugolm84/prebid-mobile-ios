/*   Copyright 2019-2022 Prebid.org, Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "GAMOriginalAPIVideoInterstitialViewController.h"
#import "PrebidDemoMacros.h"

@import PrebidMobile;

NSString * const storedResponseOriginalVideoInterstitial = @"response-prebid-video-interstitial-320-480-original-api";
NSString * const storedImpVideoInterstitial = @"imp-prebid-video-interstitial-320-480";
NSString * const gamAdUnitVideoInterstitialOriginal = @"/21808260008/prebid-demo-app-original-api-video-interstitial";

@interface GAMOriginalAPIVideoInterstitialViewController ()

// Prebid
@property (nonatomic) VideoInterstitialAdUnit * adUnit;

@end

@implementation GAMOriginalAPIVideoInterstitialViewController

- (void)loadView {
    [super loadView];
    
    Prebid.shared.storedAuctionResponse = storedResponseOriginalVideoInterstitial;
    [self createAd];
}

- (void)createAd {
    // 1. Create an VideoInterstitialAdUnit
    self.adUnit = [[VideoInterstitialAdUnit alloc] initWithConfigId:storedImpVideoInterstitial];
    
    // 2. Configure video parameters
    VideoParameters * parameters = [[VideoParameters alloc] init];
    parameters.mimes = @[@"video/mp4"];
    parameters.protocols = @[PBProtocols.VAST_2_0];
    parameters.playbackMethod = @[PBPlaybackMethod.AutoPlaySoundOff];
    self.adUnit.parameters = parameters;
    
    // 3. Make a bid request to Prebid Server
    GAMRequest * gamRequest = [GAMRequest new];
    @weakify(self);
    [self.adUnit fetchDemandWithAdObject:gamRequest completion:^(enum ResultCode resultCode) {
        @strongify(self);
        
        // 4. Load a GAM interstitial ad
        [GAMInterstitialAd loadWithAdManagerAdUnitID:gamAdUnitVideoInterstitialOriginal request:gamRequest completionHandler:^(GAMInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
            
            if (error != nil) {
                PBMLogError(@"%@", error.localizedDescription);
            } else if (interstitialAd != nil) {
                // 5. Present the interstitial ad
                interstitialAd.fullScreenContentDelegate = self;
                [interstitialAd presentFromRootViewController:self];
            }
        }];
    }];
}

// MARK: - GADFullScreenContentDelegate

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    PBMLogError(@"%@", error.localizedDescription);
}

@end
