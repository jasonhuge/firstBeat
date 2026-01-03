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
}

// MARK: - Protocol

protocol RemoteConfigRequest {
    associatedtype ResponseModel: Decodable

    var baseURL: String { get }
    var endpoint: String { get }
    var cacheFilename: String { get }
    var bundleFilename: String { get }
}

// MARK: - Request Types

struct FormatsRequest: RemoteConfigRequest {
    typealias ResponseModel = [FormatType]

    let baseURL = RemoteConfigConstants.baseURL
    let endpoint = "\(RemoteConfigConstants.jsonPath)formats.json"
    let cacheFilename = "formats.json"
    let bundleFilename = "formats"
}

struct OpeningsRequest: RemoteConfigRequest {
    typealias ResponseModel = [Opening]

    let baseURL = RemoteConfigConstants.baseURL
    let endpoint = "\(RemoteConfigConstants.jsonPath)openings.json"
    let cacheFilename = "openings.json"
    let bundleFilename = "openings"
}

struct WarmUpsRequest: RemoteConfigRequest {
    typealias ResponseModel = [WarmUp]

    let baseURL = RemoteConfigConstants.baseURL
    let endpoint = "\(RemoteConfigConstants.jsonPath)warmups.json"
    let cacheFilename = "warmups.json"
    let bundleFilename = "warmups"
}

/// Service for loading JSON configuration from remote sources with caching
///
/// Features:
/// - Remote-first loading from GitHub
/// - Time-based cache expiration (default: 1 hour)
/// - Automatic background updates when cache is valid
/// - Offline support with stale cache fallback
/// - Bundle JSON as ultimate fallback
///
/// Usage:
/// ```swift
/// // Load data
/// let formats = await RemoteConfigService.load(FormatsRequest())
///
/// // Check cache status
/// let status = RemoteConfigService.cacheStatus(for: FormatsRequest())
/// switch status {
/// case .valid(let cachedAt, let expiresAt):
///     print("Cache valid until \(expiresAt)")
/// case .expired(let cachedAt):
///     print("Cache expired (was cached at \(cachedAt))")
/// case .notCached:
///     print("No cache available")
/// }
///
/// // Clear cache
/// RemoteConfigService.clearCache(for: FormatsRequest())
/// RemoteConfigService.clearAllCache()
/// ```
struct RemoteConfigService {

    // MARK: - Configuration

    /// Cache expiration time in seconds (default: 1 hour)
    /// Change this value to adjust how long cached data remains valid
    private static let cacheExpirationInterval: TimeInterval = 3600

    private static let cacheDirectory: URL = {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDir = paths[0].appendingPathComponent("RemoteConfig")
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        return cacheDir
    }()

    // MARK: - Cache Metadata

    enum CacheStatus {
        case notCached
        case valid(cachedAt: Date, expiresAt: Date)
        case expired(cachedAt: Date)

        var isValid: Bool {
            if case .valid = self { return true }
            return false
        }
    }

    private struct CacheMetadata: Codable {
        let filename: String
        let cachedAt: Date
        let expiresAt: Date

        var isExpired: Bool {
            Date() > expiresAt
        }
    }

    // MARK: - Public API

    /// Gets the cache status for a specific request
    /// - Parameter request: The RemoteConfigRequest to check
    /// - Returns: CacheStatus indicating current cache state
    static func cacheStatus<Request: RemoteConfigRequest>(for request: Request) -> CacheStatus {
        guard let metadata = loadMetadata(for: request.cacheFilename) else {
            return .notCached
        }

        if metadata.isExpired {
            return .expired(cachedAt: metadata.cachedAt)
        }

        return .valid(cachedAt: metadata.cachedAt, expiresAt: metadata.expiresAt)
    }

    /// Clears the cache for a specific request
    /// - Parameter request: The RemoteConfigRequest to clear cache for
    static func clearCache<Request: RemoteConfigRequest>(for request: Request) {
        let cacheURL = cacheDirectory.appendingPathComponent(request.cacheFilename)
        let metadataURL = cacheDirectory.appendingPathComponent("\(request.cacheFilename).metadata")

        try? FileManager.default.removeItem(at: cacheURL)
        try? FileManager.default.removeItem(at: metadataURL)

        print("🗑️ Cleared cache for \(request.cacheFilename)")
    }

    /// Clears all cached data
    static func clearAllCache() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        print("🗑️ Cleared all cache")
    }

    /// Loads JSON from remote URL with caching and local fallback
    /// - Parameter request: The RemoteConfigRequest defining the resource to load
    /// - Returns: Decoded object or nil if all sources fail
    static func load<Request: RemoteConfigRequest>(_ request: Request) async -> Request.ResponseModel? {
        let metadata = loadMetadata(for: request.cacheFilename)

        // Check if cache exists and is still valid
        if let metadata = metadata, !metadata.isExpired {
            // Cache is valid - use it and update in background
            if let cached = loadFromCache(request) {
                let timeRemaining = metadata.expiresAt.timeIntervalSinceNow
                print("✅ Loaded \(request.cacheFilename) from cache (expires in \(Int(timeRemaining))s)")

                // Fetch updated version in background
                Task {
                    await fetchAndCache(request)
                }

                return cached
            }
        } else if metadata != nil {
            print("⚠️ Cache for \(request.cacheFilename) has expired, fetching fresh data...")
        }

        // Cache is expired or doesn't exist - fetch from remote
        if let remote = await fetchAndCache(request) {
            print("✅ Loaded \(request.cacheFilename) from remote")
            return remote
        }

        // Try stale cache as fallback (better than nothing)
        if let cached = loadFromCache(request) {
            print("⚠️ Using stale cache for \(request.cacheFilename) (remote fetch failed)")
            return cached
        }

        // Fall back to bundled JSON
        if let bundled = loadFromBundle(request) {
            print("⚠️ Loaded \(request.cacheFilename) from bundle (fallback)")
            return bundled
        }

        print("❌ Failed to load \(request.cacheFilename) from all sources")
        return nil
    }

    // MARK: - Private Helpers

    /// Fetches JSON from remote URL and caches it
    private static func fetchAndCache<Request: RemoteConfigRequest>(_ request: Request) async -> Request.ResponseModel? {
        guard let url = URL(string: "\(request.baseURL)\(request.endpoint)") else {
            print("❌ Invalid remote URL for \(request.cacheFilename)")
            return nil
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ Remote fetch failed for \(request.cacheFilename) - invalid response")
                return nil
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let decoded = try decoder.decode(Request.ResponseModel.self, from: data)

            // Cache the data
            saveToCache(data, filename: request.cacheFilename)

            return decoded
        } catch {
            print("❌ Remote fetch failed for \(request.cacheFilename): \(error)")
            return nil
        }
    }

    /// Loads JSON from local cache
    private static func loadFromCache<Request: RemoteConfigRequest>(_ request: Request) -> Request.ResponseModel? {
        let cacheURL = cacheDirectory.appendingPathComponent(request.cacheFilename)

        guard FileManager.default.fileExists(atPath: cacheURL.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: cacheURL)

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            return try decoder.decode(Request.ResponseModel.self, from: data)
        } catch {
            print("❌ Cache load failed for \(request.cacheFilename): \(error)")
            return nil
        }
    }

    /// Saves data to local cache with metadata
    private static func saveToCache(_ data: Data, filename: String) {
        let cacheURL = cacheDirectory.appendingPathComponent(filename)

        do {
            try data.write(to: cacheURL, options: .atomic)

            // Save metadata
            let now = Date()
            let metadata = CacheMetadata(
                filename: filename,
                cachedAt: now,
                expiresAt: now.addingTimeInterval(cacheExpirationInterval)
            )
            saveMetadata(metadata)

            let expiresInMinutes = Int(cacheExpirationInterval / 60)
            print("✅ Cached \(filename) (expires in \(expiresInMinutes) minutes)")
        } catch {
            print("❌ Failed to cache \(filename): \(error)")
        }
    }

    /// Loads metadata for a cached file
    private static func loadMetadata(for filename: String) -> CacheMetadata? {
        let metadataURL = cacheDirectory.appendingPathComponent("\(filename).metadata")

        guard FileManager.default.fileExists(atPath: metadataURL.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: metadataURL)
            return try JSONDecoder().decode(CacheMetadata.self, from: data)
        } catch {
            print("❌ Failed to load metadata for \(filename): \(error)")
            return nil
        }
    }

    /// Saves metadata for a cached file
    private static func saveMetadata(_ metadata: CacheMetadata) {
        let metadataURL = cacheDirectory.appendingPathComponent("\(metadata.filename).metadata")

        do {
            let data = try JSONEncoder().encode(metadata)
            try data.write(to: metadataURL, options: .atomic)
        } catch {
            print("❌ Failed to save metadata for \(metadata.filename): \(error)")
        }
    }

    /// Loads JSON from app bundle (fallback)
    private static func loadFromBundle<Request: RemoteConfigRequest>(_ request: Request) -> Request.ResponseModel? {
        return JSONLoader.load(Request.ResponseModel.self, filename: request.bundleFilename)
    }
}
