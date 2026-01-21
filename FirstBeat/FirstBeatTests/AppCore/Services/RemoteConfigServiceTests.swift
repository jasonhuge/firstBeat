//
//  RemoteConfigServiceTests.swift
//  FirstBeatTests
//
//  Created by Jason Hughes on 1/3/26.
//

import Foundation
import Testing
@testable import FirstBeat

@MainActor
struct RemoteConfigServiceTests {

    // MARK: - Data Request Configuration Tests

    @Test func formatsDataRequestConfiguration() {
        let request = FormatsDataRequest()

        #expect(request.baseURL == RemoteConfigConstants.baseURL)
        #expect(request.endpoint == "json/data/formats.json")
    }

    @Test func openingsDataRequestConfiguration() {
        let request = OpeningsDataRequest()

        #expect(request.baseURL == RemoteConfigConstants.baseURL)
        #expect(request.endpoint == "json/data/openings.json")
    }

    @Test func warmUpsDataRequestConfiguration() {
        let request = WarmUpsDataRequest()

        #expect(request.baseURL == RemoteConfigConstants.baseURL)
        #expect(request.endpoint == "json/data/warmups.json")
    }

    @Test func suggestionsDataRequestConfiguration() {
        let request = SuggestionsDataRequest()

        #expect(request.baseURL == RemoteConfigConstants.baseURL)
        #expect(request.endpoint == "json/data/suggestions.json")
    }

    // MARK: - Translation Request Configuration Tests

    @Test func formatsTranslationRequestConfiguration() {
        let request = FormatsTranslationRequest()

        #expect(request.baseURL == RemoteConfigConstants.baseURL)
        #expect(request.endpoint.contains("json/translations/"))
        #expect(request.endpoint.contains("/formats.json"))
    }

    @Test func openingsTranslationRequestConfiguration() {
        let request = OpeningsTranslationRequest()

        #expect(request.baseURL == RemoteConfigConstants.baseURL)
        #expect(request.endpoint.contains("json/translations/"))
        #expect(request.endpoint.contains("/openings.json"))
    }

    @Test func warmUpsTranslationRequestConfiguration() {
        let request = WarmUpsTranslationRequest()

        #expect(request.baseURL == RemoteConfigConstants.baseURL)
        #expect(request.endpoint.contains("json/translations/"))
        #expect(request.endpoint.contains("/warmups.json"))
    }

    @Test func suggestionsTranslationRequestConfiguration() {
        let request = SuggestionsTranslationRequest()

        #expect(request.baseURL == RemoteConfigConstants.baseURL)
        #expect(request.endpoint.contains("json/translations/"))
        #expect(request.endpoint.contains("/suggestions.json"))
    }

    // MARK: - Constants Tests

    @Test func remoteConfigConstantsAreSet() {
        #expect(RemoteConfigConstants.baseURL.isEmpty == false)
        #expect(RemoteConfigConstants.baseURL.hasPrefix("https://"))
        #expect(RemoteConfigConstants.jsonPath == "json/")
    }

    @Test func supportedLanguagesIncludesEnglishAndSpanish() {
        #expect(RemoteConfigConstants.supportedLanguages.contains("en"))
        #expect(RemoteConfigConstants.supportedLanguages.contains("es"))
    }

    @Test func defaultLanguageIsEnglish() {
        #expect(RemoteConfigConstants.defaultLanguage == "en")
    }

    @Test func currentLanguageCodeReturnsValidLanguage() {
        let languageCode = RemoteConfigConstants.currentLanguageCode
        #expect(RemoteConfigConstants.supportedLanguages.contains(languageCode))
    }

    // MARK: - Load Tests (Integration)

    @Test func loadFormatsData() async throws {
        let formats = try await RemoteConfigService.load(FormatsDataRequest())

        #expect(formats.isEmpty == false)
        #expect(formats.first?.id.isEmpty == false)
    }

    @Test func loadFormatsTranslations() async throws {
        let translations = try await RemoteConfigService.load(FormatsTranslationRequest())

        #expect(translations.isEmpty == false)
    }

    @Test func loadOpeningsData() async throws {
        let openings = try await RemoteConfigService.load(OpeningsDataRequest())

        #expect(openings.isEmpty == false)
        #expect(openings.first?.id.isEmpty == false)
    }

    @Test func loadOpeningsTranslations() async throws {
        let translations = try await RemoteConfigService.load(OpeningsTranslationRequest())

        #expect(translations.isEmpty == false)
    }

    @Test func loadWarmUpsData() async throws {
        let warmUps = try await RemoteConfigService.load(WarmUpsDataRequest())

        #expect(warmUps.isEmpty == false)
        #expect(warmUps.first?.id.isEmpty == false)
    }

    @Test func loadWarmUpsTranslations() async throws {
        let translations = try await RemoteConfigService.load(WarmUpsTranslationRequest())

        #expect(translations.isEmpty == false)
    }

    @Test func loadSuggestionsData() async throws {
        let data = try await RemoteConfigService.load(SuggestionsDataRequest())

        #expect(data.categories.isEmpty == false)
    }

    @Test func loadSuggestionsTranslations() async throws {
        let translations = try await RemoteConfigService.load(SuggestionsTranslationRequest())

        #expect(translations.isEmpty == false)
    }
}
