import Foundation

// MARK: - HTTP Enums
enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum HttpError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case invalidStatusCode(Int)
    case decodingError(Error)
    case encodingError(Error)
}

// MARK: - HTTP Protocol
protocol HttpServiceProtocol {
    func request<T: Decodable>(
        url: URL,
        method: HttpMethod,
        body: Encodable?,
        headers: [String: String]?
    ) async throws -> T
    
    func request(
        url: URL,
        method: HttpMethod,
        body: Encodable?,
        headers: [String: String]?
    ) async throws -> Data
}

// MARK: - HTTP Service
final class HttpService: HttpServiceProtocol {
    static let shared = HttpService()
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }
    
    // Generic request with response type
    func request<T: Decodable>(
        url: URL,
        method: HttpMethod = .get,
        body: Encodable? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        let data = try await performRequest(url: url, method: method, body: body, headers: headers)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw HttpError.decodingError(error)
        }
    }
    
    // Raw data request
    func request(
        url: URL,
        method: HttpMethod = .get,
        body: Encodable? = nil,
        headers: [String: String]? = nil
    ) async throws -> Data {
        try await performRequest(url: url, method: method, body: body, headers: headers)
    }
    
    // Helper method for performing the actual request
    private func performRequest(
        url: URL,
        method: HttpMethod,
        body: Encodable?,
        headers: [String: String]?
    ) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add body for non-GET requests
        if let body = body, method != .get {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw HttpError.encodingError(error)
            }
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HttpError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw HttpError.invalidStatusCode(httpResponse.statusCode)
            }
            
            return data
        } catch let error as HttpError {
            throw error
        } catch {
            throw HttpError.networkError(error)
        }
    }
}

// MARK: - Convenience Methods
extension HttpService {
    func get<T: Decodable>(url: URL, headers: [String: String]? = nil) async throws -> T {
        try await request(url: url, method: .get, body: nil as String?, headers: headers)
    }
    
    func post<T: Decodable>(url: URL, body: Encodable, headers: [String: String]? = nil) async throws -> T {
        try await request(url: url, method: .post, body: body, headers: headers)
    }
    
    func put<T: Decodable>(url: URL, body: Encodable, headers: [String: String]? = nil) async throws -> T {
        try await request(url: url, method: .put, body: body, headers: headers)
    }
    
    func delete<T: Decodable>(url: URL, headers: [String: String]? = nil) async throws -> T {
        try await request(url: url, method: .delete, body: nil as String?, headers: headers)
    }
    
    func patch<T: Decodable>(url: URL, body: Encodable, headers: [String: String]? = nil) async throws -> T {
        try await request(url: url, method: .patch, body: body, headers: headers)
    }
} 