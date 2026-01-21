//
//  RemoteConfigService.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/3/26.
//

import Foundation

// MARK: - Configuration

enum RemoteConfigConstants {
    /// Base URL for remote JSON files
    static let baseURL = "https://raw.githubusercontent.com/jasonhuge/firstBeatConfig/main/"

    /// Path to JSON folder within the repository
    static let jsonPath = "json/"

    /// Supported languages (must have corresponding folders on server)
    static let supportedLanguages = ["en", "es"]

    /// Default language fallback
    static let defaultLanguage = "en"

    /// Returns the current language code, falling back to default if unsupported
    static var currentLanguageCode: String {
        guard let languageCode = Locale.current.language.languageCode?.identifier else {
            return defaultLanguage
        }
        return supportedLanguages.contains(languageCode) ? languageCode : defaultLanguage
    }
}

// MARK: - Errors

enum RemoteConfigError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid configuration URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingError(let error):
            return "Failed to parse configuration: \(error.localizedDescription)"
        }
    }
}

// MARK: - Protocol

protocol RemoteConfigRequest {
    associatedtype ResponseModel: Decodable

    var baseURL: String { get }
    var endpoint: String { get }
}

// MARK: - Data Request Types (structural data)

struct FormatsDataRequest: RemoteConfigRequest {
    typealias ResponseModel = [FormatData]

    let baseURL = RemoteConfigConstants.baseURL

    var endpoint: String {
        "\(RemoteConfigConstants.jsonPath)data/formats.json"
    }
}

struct OpeningsDataRequest: RemoteConfigRequest {
    typealias ResponseModel = [OpeningData]

    let baseURL = RemoteConfigConstants.baseURL

    var endpoint: String {
        "\(RemoteConfigConstants.jsonPath)data/openings.json"
    }
}

struct WarmUpsDataRequest: RemoteConfigRequest {
    typealias ResponseModel = [WarmUpData]

    let baseURL = RemoteConfigConstants.baseURL

    var endpoint: String {
        "\(RemoteConfigConstants.jsonPath)data/warmups.json"
    }
}

struct SuggestionsDataRequest: RemoteConfigRequest {
    typealias ResponseModel = SuggestionsDataResponse

    let baseURL = RemoteConfigConstants.baseURL

    var endpoint: String {
        "\(RemoteConfigConstants.jsonPath)data/suggestions.json"
    }
}

// MARK: - Translation Request Types (localized content)

struct FormatsTranslationRequest: RemoteConfigRequest {
    typealias ResponseModel = [String: FormatTranslation]

    let baseURL = RemoteConfigConstants.baseURL
    let languageCode = RemoteConfigConstants.currentLanguageCode

    var endpoint: String {
        "\(RemoteConfigConstants.jsonPath)translations/\(languageCode)/formats.json"
    }
}

struct OpeningsTranslationRequest: RemoteConfigRequest {
    typealias ResponseModel = [String: OpeningTranslation]

    let baseURL = RemoteConfigConstants.baseURL
    let languageCode = RemoteConfigConstants.currentLanguageCode

    var endpoint: String {
        "\(RemoteConfigConstants.jsonPath)translations/\(languageCode)/openings.json"
    }
}

struct WarmUpsTranslationRequest: RemoteConfigRequest {
    typealias ResponseModel = [String: WarmUpTranslation]

    let baseURL = RemoteConfigConstants.baseURL
    let languageCode = RemoteConfigConstants.currentLanguageCode

    var endpoint: String {
        "\(RemoteConfigConstants.jsonPath)translations/\(languageCode)/warmups.json"
    }
}

struct SuggestionsTranslationRequest: RemoteConfigRequest {
    typealias ResponseModel = [String: SuggestionCategoryTranslation]

    let baseURL = RemoteConfigConstants.baseURL
    let languageCode = RemoteConfigConstants.currentLanguageCode

    var endpoint: String {
        "\(RemoteConfigConstants.jsonPath)translations/\(languageCode)/suggestions.json"
    }
}

// MARK: - Service

/// Service for loading JSON configuration from remote sources
struct RemoteConfigService {

    /// Loads JSON from remote URL
    /// - Parameter request: The RemoteConfigRequest defining the resource to load
    /// - Returns: Decoded object
    /// - Throws: RemoteConfigError if loading fails
    static func load<Request: RemoteConfigRequest>(_ request: Request) async throws -> Request.ResponseModel {
        guard let url = URL(string: "\(request.baseURL)\(request.endpoint)") else {
            throw RemoteConfigError.invalidURL
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw RemoteConfigError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw RemoteConfigError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(Request.ResponseModel.self, from: data)
        } catch {
            throw RemoteConfigError.decodingError(error)
        }
    }
}
