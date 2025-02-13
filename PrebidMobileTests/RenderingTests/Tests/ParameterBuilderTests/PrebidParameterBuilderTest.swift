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

import XCTest
@testable import PrebidMobile

class PrebidParameterBuilderTest: XCTestCase {
    
    private let sdkConfiguration = Prebid.mock
    private var targeting: Targeting!
    
    override func setUp() {
        super.setUp()

        targeting = Targeting.shared
        UtilitiesForTesting.resetTargeting(targeting)
    }
    
    override func tearDown() {
        UtilitiesForTesting.resetTargeting(targeting)
        Prebid.reset()
    }
    
    func testAdPositionHeader() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        adUnitConfig.adFormats = [.display]
        
        var bidRequest = buildBidRequest(with: adUnitConfig)
        
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Banner object!")
            return
        }
        
        PBMAssertEq(imp.instl, 0)
        
        guard let banner = imp.banner else {
            XCTFail("No Banner object!")
            return
        }
        XCTAssertNil(banner.pos)
        
        adUnitConfig.adPosition = .header
        
        bidRequest = buildBidRequest(with: adUnitConfig)
        
        XCTAssertEqual(bidRequest.imp.first?.banner?.pos?.intValue, AdPosition.header.rawValue)
        XCTAssertEqual(bidRequest.imp.first?.banner?.pos?.intValue, 4)
    }
    
    func testAdPositionFullScreen() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let interstitialAdUnit = InterstitialRenderingAdUnit(configID: configId)
        
        let bidRequest = buildBidRequest(with: interstitialAdUnit.adUnitConfig)
        
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Banner object!")
            return
        }
        
        PBMAssertEq(imp.instl, 1)
        
        guard let banner = imp.banner else {
            XCTFail("No Banner object!")
            return
        }
        XCTAssertEqual(banner.pos?.intValue, AdPosition.fullScreen.rawValue)
        XCTAssertEqual(banner.pos?.intValue, 7)
    }
    
    func testAdditionalSizes() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        adUnitConfig.adFormats = [.display]
        
        var bidRequest = buildBidRequest(with: adUnitConfig)
        
        guard let banner = bidRequest.imp.first?.banner else {
            XCTFail("No Banner object!")
            return
        }
        
        XCTAssertEqual(banner.format.count, 1)
        PBMAssertEq(banner.format.first?.w, 320)
        PBMAssertEq(banner.format.first?.h, 50)
        
        adUnitConfig.additionalSizes = [CGSize(width: 728, height: 90)]
        
        bidRequest = buildBidRequest(with: adUnitConfig)
        
        XCTAssertEqual(bidRequest.imp.first?.banner?.format.count, 2)
        PBMAssertEq(bidRequest.imp.first?.banner?.format[1].w, 728)
        PBMAssertEq(bidRequest.imp.first?.banner?.format[1].h, 90)
    }
    
    func testVideo() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        adUnitConfig.adFormats = [.video]
        adUnitConfig.adPosition = .header
        
        let parameters = VideoParameters()
        parameters.linearity = 1
        parameters.placement = .Interstitial
        parameters.api = [Signals.Api.MRAID_1]
        parameters.minDuration = 1
        parameters.maxDuration = 10
        parameters.minBitrate = 1
        parameters.maxBitrate = 10
        parameters.startDelay = Signals.StartDelay.GenericMidRoll
        
        adUnitConfig.adConfiguration.videoParameters = parameters
        
        let bidRequest = buildBidRequest(with: adUnitConfig)
        
        guard let video = bidRequest.imp.first?.video else {
            XCTFail("No Video object!")
            return
        }
        
        PBMAssertEq(video.linearity, 1)
        PBMAssertEq(video.placement, 5)
        PBMAssertEq(video.w, 320)
        PBMAssertEq(video.h, 50)
        PBMAssertEq(video.api, [3])
        PBMAssertEq(video.minduration, 1)
        PBMAssertEq(video.maxduration, 10)
        PBMAssertEq(video.minbitrate, 1)
        PBMAssertEq(video.maxbitrate, 10)
        PBMAssertEq(video.protocols, [2, 5])
        PBMAssertEq(video.startdelay, -1)
        PBMAssertEq(video.mimes, PBMConstants.supportedVideoMimeTypes)
        PBMAssertEq(video.playbackend, 2)
        PBMAssertEq(video.delivery, [3])
        XCTAssertEqual(video.pos.intValue, AdPosition.header.rawValue)
        XCTAssertEqual(video.pos.intValue, 4)
    }
    
    func testFirstPartyData() {
        
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        
        targeting.addBidderToAccessControlList("prebid-mobile")
        targeting.updateUserData(key: "fav_colors", value: Set(["red", "orange"]))
        targeting.addContextData(key: "last_search_keywords", value: "wolf")
        targeting.addContextData(key: "last_search_keywords", value: "pet")
        
        let userDataObject1 = PBMORTBContentData()
        userDataObject1.id = "data id"
        userDataObject1.name = "test name"
        let userDataObject2 = PBMORTBContentData()
        userDataObject2.id = "data id"
        userDataObject2.name = "test name"
        
        adUnitConfig.addUserData([userDataObject1, userDataObject2])
        let objects = adUnitConfig.getUserData()!
        
        adUnitConfig.addContextData(key: "buy", value: "mushrooms")
        
        let bidRequest = buildBidRequest(with: adUnitConfig)
        
        XCTAssertEqual(bidRequest.extPrebid.dataBidders, ["prebid-mobile"])
        
        XCTAssertEqual(2, objects.count)
        XCTAssertEqual(objects.first, userDataObject1)
        
        let extData = bidRequest.app.ext.data!
        XCTAssertTrue(extData.keys.count == 1)
        let extValues = extData["last_search_keywords"]!.sorted()
        XCTAssertEqual(extValues, ["pet", "wolf"])

        let userData = bidRequest.user.ext!["data"] as! [String :AnyHashable]
        XCTAssertTrue(userData.keys.count == 1)
        let userValues = userData["fav_colors"] as! Array<String>
        XCTAssertEqual(Set(userValues), ["red", "orange"])
        
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Impression object!")
            return
        }
        
        XCTAssertEqual(imp.extContextData, ["buy": ["mushrooms"]])
    }

    func testPbAdSlotWithContextDataDictionary() {
        let testAdSlot = "test ad slot"
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))

        adUnitConfig.setPbAdSlot(testAdSlot)

        adUnitConfig.addContextData(key: "key", value: "value1")
        adUnitConfig.addContextData(key: "key", value: "value2")

        let bidRequest = buildBidRequest(with: adUnitConfig)

        bidRequest.imp.forEach { imp in
            guard let extContextData = imp.extContextData as? [String: Any], let result = extContextData["key"] as? [String] else {
                XCTFail()
                return
            }

            XCTAssertEqual(Set(result), Set(["value1", "value2"]))
            XCTAssertEqual(extContextData["adslot"] as? String, testAdSlot)
        }
    }

    func testSourceOMID() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))

        var bidRequest = buildBidRequest(with: adUnitConfig)

        XCTAssertEqual(bidRequest.source.extOMID.omidpn, "Prebid")
        XCTAssertEqual(bidRequest.source.extOMID.omidpv, PBMFunctions.omidVersion())

        targeting.omidPartnerVersion = "test omid version"
        targeting.omidPartnerName = "test omid name"

        bidRequest = buildBidRequest(with: adUnitConfig)

        XCTAssertEqual(bidRequest.source.extOMID.omidpn, "test omid name")
        XCTAssertEqual(bidRequest.source.extOMID.omidpv, "test omid version")

        targeting.omidPartnerVersion = nil
        targeting.omidPartnerName = nil
    }

    func testSubjectToCOPPA() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))

        targeting.subjectToCOPPA = true

        var bidRequest = buildBidRequest(with: adUnitConfig)
        
        XCTAssertEqual(bidRequest.regs.coppa, 1)

        targeting.subjectToCOPPA = false

        bidRequest = buildBidRequest(with: adUnitConfig)

        XCTAssertEqual(bidRequest.regs.coppa, 0)
    }

    func testSubjectToGDPR() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))

        targeting.subjectToGDPR = true

        let bidRequest = buildBidRequest(with: adUnitConfig)

        guard let extRegs = bidRequest.regs.ext as? [String: Any] else {
            XCTFail()
            return
        }
        XCTAssertEqual(extRegs["gdpr"] as? NSNumber, 1)
    }

    func testGDPRConsentString() {
        let testGDPRConsentString = "test gdpr consent string"

        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))

        targeting.gdprConsentString = testGDPRConsentString
        
        let bidRequest = buildBidRequest(with: adUnitConfig)

        guard let userExt = bidRequest.user.ext as? [String: Any] else {
            XCTFail()
            return
        }

        XCTAssertEqual(userExt["consent"] as? String, testGDPRConsentString)
    }

    func testStoredBidResponses() {
        Prebid.shared.addStoredBidResponse(bidder: "testBidder", responseId: "testResponseId")

        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))

        let bidRequest = buildBidRequest(with: adUnitConfig)

        let resultStoredBidResponses = [
            [
                "bidder": "testBidder",
                "id" : "testResponseId"
            ]
        ]

        XCTAssertEqual(bidRequest.extPrebid.storedBidResponses, resultStoredBidResponses)
    }
    
    func testDefaultCaching() {
        XCTAssertFalse(sdkConfiguration.useCacheForReportingWithRenderingAPI)

        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))

        let bidRequest = buildBidRequest(with: adUnitConfig)
        
        guard bidRequest.extPrebid.cache == nil else {
            XCTFail("Cache should be nil by default.")
            return
        }
    }
    
    func testEnableCaching() {
        sdkConfiguration.useCacheForReportingWithRenderingAPI = true

        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))

        let bidRequest = buildBidRequest(with: adUnitConfig)
        
        guard let cache = bidRequest.extPrebid.cache else {
            XCTFail("Cache shouldn't be nil if useCacheForReportingWithRenderingAPI is turned on.")
            return
        }
        
        XCTAssertNotNil(cache["bids"])
        XCTAssertNotNil(cache["vastxml"])
    }
    
    func testCachingForOriginalAPI() {
        // This should not impact on caching the bid in original api
        sdkConfiguration.useCacheForReportingWithRenderingAPI = false
        
        let adUnit = AdUnit(configId: "test", size: CGSize(width: 320, height: 50))
        let adUnitConfig = adUnit.adUnitConfig
        
        let bidRequest = buildBidRequest(with: adUnitConfig)
        
        guard let cache = bidRequest.extPrebid.cache else {
            XCTFail("Cache shouldn't be nil for original api.")
            return
        }
        
        XCTAssertNotNil(cache["bids"])
        XCTAssertNotNil(cache["vastxml"])
    }
    
    func testDefaultAPISignalsInAllAdUnits() {
        // Original API
        let adUnit = AdUnit(configId: "test", size: CGSize(width: 320, height: 50))
        
        var bidRequest = buildBidRequest(with: adUnit.adUnitConfig)
        
        bidRequest.imp.forEach {
            // API signals should be nil for original API
            XCTAssertEqual($0.banner?.api, nil)
        }
        
        let apiSignalsAsNumbers = PrebidConstants.supportedRenderingBannerAPISignals.map { NSNumber(value: $0.value) }
        
        // Rendering API
        let renderingBannerAdUnit = BannerView(frame: .init(origin: .zero, size: CGSize(width: 320, height: 50)), configID: "test", adSize: CGSize(width: 320, height: 50))
        bidRequest = buildBidRequest(with: renderingBannerAdUnit.adUnitConfig)
        
        bidRequest.imp.forEach { imp in
            // Supported banner api signals for rendering API is MRAID_1, MRAID_2, MRAID_3, OMID_1
            XCTAssertEqual(imp.banner?.api, apiSignalsAsNumbers)
        }
        
        let redenderingInterstitialAdUnit = BaseInterstitialAdUnit(configID: "configID")
        bidRequest = buildBidRequest(with: redenderingInterstitialAdUnit.adUnitConfig)
        
        bidRequest.imp.forEach {
            // Supported banner api signals for rendering API is MRAID_1, MRAID_2, MRAID_3, OMID_1
            XCTAssertEqual($0.banner?.api, apiSignalsAsNumbers)
        }
        
        // Mediation API
        let mediationBannerAdUnit = MediationBannerAdUnit(configID: "configId", size: CGSize(width: 320, height: 50), mediationDelegate: MockMediationUtils(adObject: MockAdObject()))
        bidRequest = buildBidRequest(with: mediationBannerAdUnit.adUnitConfig)
        
        bidRequest.imp.forEach {
            // Supported banner api signals for rendering API is MRAID_1, MRAID_2, MRAID_3, OMID_1
            XCTAssertEqual($0.banner?.api, apiSignalsAsNumbers)
        }
        
        let mediationInterstitialAdUnit = MediationBaseInterstitialAdUnit(configId: "configId", mediationDelegate: MockMediationUtils(adObject: MockAdObject()))
        bidRequest = buildBidRequest(with: mediationInterstitialAdUnit.adUnitConfig)
        
        bidRequest.imp.forEach {
            // Supported banner api signals for rendering API is MRAID_1, MRAID_2, MRAID_3, OMID_1
            XCTAssertEqual($0.banner?.api, apiSignalsAsNumbers)
        }
    }
    
    // MARK: - Helpers
    
    func buildBidRequest(with adUnitConfig: AdUnitConfig) -> PBMORTBBidRequest {
        let bidRequest = PBMORTBBidRequest()
        PBMBasicParameterBuilder(adConfiguration: adUnitConfig.adConfiguration,
                                 sdkConfiguration: sdkConfiguration,
                                 sdkVersion: "MOCK_SDK_VERSION",
                                 targeting: targeting)
            .build(bidRequest)

        PBMPrebidParameterBuilder(adConfiguration: adUnitConfig,
                                  sdkConfiguration: sdkConfiguration,
                                  targeting: targeting,
                                  userAgentService: MockUserAgentService())
            .build(bidRequest)
        
        return bidRequest
    }
}
