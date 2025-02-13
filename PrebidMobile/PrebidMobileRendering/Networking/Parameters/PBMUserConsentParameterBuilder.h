/*   Copyright 2018-2021 Prebid.org, Inc.

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

#import <Foundation/Foundation.h>
#import "PBMParameterBuilderProtocol.h"

#import "PrebidMobileSwiftHeaders.h"
#import <PrebidMobile/PrebidMobile-Swift.h>

/**
 @c PBMUserConsentParameterBuilder is responsible for enriching its provided
 @c PBMORTBBidRequest object with consent values to an ad request.
 */
@interface PBMUserConsentParameterBuilder : NSObject <PBMParameterBuilder>

/**
 Convenience initializer that uses the @c UserConsentDataManager shared.
 */
- (nonnull instancetype)init;

/**
 Initializer exposed primarily for dependency injection.
 */
- (nonnull instancetype)initWithUserConsentManager:(nullable UserConsentDataManager *)userConsentManager NS_DESIGNATED_INITIALIZER;

@end
