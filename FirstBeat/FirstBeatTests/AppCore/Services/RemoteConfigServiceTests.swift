//
//  RemoteConfigServiceTests.swift
//  FirstBeatTests
//
//  Created by Jason Hughes on 1/3/26.
//

import Foundation
import Testing
@testable import FirstBeat

struct RemoteConfigServiceTests {

    // MARK: - Cache Status Tests

    @Test func cacheStatusNotCached() {
        // Clear cache first
        RemoteConfigService.clearCache(for: FormatsRequest())

        let status = RemoteConfigService.cacheStatus(for: FormatsRequest())

        #expect(status.isValid == false)
        if case .notCached = status {
            // Success
        } else {
            Issue.record("Expected .notCached status")
        }
    }

    @Test func cacheStatusValid() async {
        // Clear cache first
        RemoteConfigService.clearCache(for: FormatsRequest())

        // Load data to populate cache
        _ = await RemoteConfigService.load(FormatsRequest())

        let status = RemoteConfigService.cacheStatus(for: FormatsRequest())

        if case .valid(let cachedAt, let expiresAt) = status {
            #expect(cachedAt <= Date())
            #expect(expiresAt > Date())
            #expect(status.isValid == true)
        } else {
            Issue.record("Expected .valid status after loading")
        }

        // Cleanup
        RemoteConfigService.clearCache(for: FormatsRequest())
    }

    // MARK: - Clear Cache Tests

    @Test func clearCacheRemovesData() async {
        // Load data to populate cache
        _ = await RemoteConfigService.load(OpeningsRequest())

        // Verify cache exists
        var status = RemoteConfigService.cacheStatus(for: OpeningsRequest())
        #expect(status.isValid == true)

        // Clear cache
        RemoteConfigService.clearCache(for: OpeningsRequest())

        // Verify cache is gone
        status = RemoteConfigService.cacheStatus(for: OpeningsRequest())
        if case .notCached = status {
            // Success
        } else {
            Issue.record("Expected .notCached after clearing cache")
        }
    }

    @Test func clearAllCacheRemovesAllData() async {
        // Load multiple types
        _ = await RemoteConfigService.load(FormatsRequest())
        _ = await RemoteConfigService.load(OpeningsRequest())
        _ = await RemoteConfigService.load(WarmUpsRequest())

        // Clear all
        RemoteConfigService.clearAllCache()

        // Verify all are gone
        let formatStatus = RemoteConfigService.cacheStatus(for: FormatsRequest())
        let openingStatus = RemoteConfigService.cacheStatus(for: OpeningsRequest())
        let warmUpStatus = RemoteConfigService.cacheStatus(for: WarmUpsRequest())

        if case .notCached = formatStatus,
           case .notCached = openingStatus,
           case .notCached = warmUpStatus {
            // Success
        } else {
            Issue.record("Expected all caches to be cleared")
        }
    }

    // MARK: - Request Tests

    @Test func formatsRequestConfiguration() {
        let request = FormatsRequest()

        #expect(request.baseURL == RemoteConfigConstants.baseURL)
        #expect(request.endpoint.contains("json/formats.json"))
        #expect(request.cacheFilename == "formats.json")
        #expect(request.bundleFilename == "formats")
    }

    @Test func openingsRequestConfiguration() {
        let request = OpeningsRequest()

        #expect(request.baseURL == RemoteConfigConstants.baseURL)
        #expect(request.endpoint.contains("json/openings.json"))
        #expect(request.cacheFilename == "openings.json")
        #expect(request.bundleFilename == "openings")
    }

    @Test func warmUpsRequestConfiguration() {
        let request = WarmUpsRequest()

        #expect(request.baseURL == RemoteConfigConstants.baseURL)
        #expect(request.endpoint.contains("json/warmups.json"))
        #expect(request.cacheFilename == "warmups.json")
        #expect(request.bundleFilename == "warmups")
    }

    // MARK: - Load Tests

    @Test func loadFallsBackToBundleWhenRemoteFails() async {
        // Clear cache to force remote/bundle fallback
        RemoteConfigService.clearCache(for: FormatsRequest())

        // Load should fall back to bundle if remote is unavailable
        let formats = await RemoteConfigService.load(FormatsRequest())

        #expect(formats != nil)
        #expect(formats?.isEmpty == false)

        // Cleanup
        RemoteConfigService.clearCache(for: FormatsRequest())
    }

    @Test func loadReturnsOpenings() async {
        RemoteConfigService.clearCache(for: OpeningsRequest())

        let openings = await RemoteConfigService.load(OpeningsRequest())

        #expect(openings != nil)
        #expect(openings?.isEmpty == false)

        // Cleanup
        RemoteConfigService.clearCache(for: OpeningsRequest())
    }

    @Test func loadReturnsWarmUps() async {
        RemoteConfigService.clearCache(for: WarmUpsRequest())

        let warmUps = await RemoteConfigService.load(WarmUpsRequest())

        #expect(warmUps != nil)
        #expect(warmUps?.isEmpty == false)

        // Cleanup
        RemoteConfigService.clearCache(for: WarmUpsRequest())
    }

    // MARK: - Constants Tests

    @Test func remoteConfigConstantsAreSet() {
        #expect(RemoteConfigConstants.baseURL.isEmpty == false)
        #expect(RemoteConfigConstants.baseURL.hasPrefix("https://"))
        #expect(RemoteConfigConstants.jsonPath == "json/")
    }
}
