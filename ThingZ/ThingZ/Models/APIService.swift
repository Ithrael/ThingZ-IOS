import Foundation

// MARK: - API配置
struct APIConfig {
    static let devBaseURL = "https://api.anyongtech.cn"
    static let prodBaseURL = "https://api.anyongtech.cn"

    // 根据需要切换环境
    static var baseURL: String {
        #if DEBUG
        return devBaseURL
        #else
        return prodBaseURL
        #endif
    }

    static let timeout: TimeInterval = 30.0
}

// MARK: - HTTP方法
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - API错误
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case serverError(Int, String)
    case decodingError(Error)
    case unauthorized
    case forbidden
    case notFound

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的API地址"
        case .invalidResponse:
            return "服务器响应异常"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "服务器错误 (\(code)): \(message)"
        case .decodingError:
            return "数据解析失败"
        case .unauthorized:
            return "未授权，请重新登录"
        case .forbidden:
            return "权限不足"
        case .notFound:
            return "资源不存在"
        }
    }
}

// MARK: - API响应模型
struct APIResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T?
    let timestamp: Int64?
}

// 空响应
struct EmptyResponse: Codable {}

// MARK: - API服务基类
class APIService {
    static let shared = APIService()

    private init() {}

    // MARK: - 通用请求方法
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        body: Encodable? = nil,
        requiresAuth: Bool = false
    ) async throws -> APIResponse<T> {
        guard let url = URL(string: "\(APIConfig.baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("*/*", forHTTPHeaderField: "Accept")
        urlRequest.timeoutInterval = APIConfig.timeout

        // 添加认证Token
        if requiresAuth {
            guard let token = AuthManager.shared.authToken else {
                throw APIError.unauthorized
            }
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // 处理查询参数
        if let parameters = parameters, method == .GET {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            if let urlWithParams = components?.url {
                urlRequest.url = urlWithParams
            }
        }

        // 处理请求体
        if let body = body {
            do {
                urlRequest.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw APIError.networkError(error)
            }
        }

        // 发送请求
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            // 处理HTTP状态码
            switch httpResponse.statusCode {
            case 200...299:
                // 成功响应
                do {
                    let apiResponse = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                    return apiResponse
                } catch {
                    throw APIError.decodingError(error)
                }
            case 401:
                // Token过期，需要重新登录
                if requiresAuth {
                    DispatchQueue.main.async {
                        AuthManager.shared.logout()
                    }
                }
                throw APIError.unauthorized
            case 403:
                throw APIError.forbidden
            case 404:
                throw APIError.notFound
            default:
                // 尝试解析错误消息
                if let errorResponse = try? JSONDecoder().decode(APIResponse<EmptyResponse>.self, from: data) {
                    throw APIError.serverError(errorResponse.code, errorResponse.message)
                } else {
                    throw APIError.serverError(httpResponse.statusCode, "未知错误")
                }
            }

        } catch let error as APIError {
            throw error
        } catch let urlError as URLError {
            switch urlError.code {
            case .timedOut:
                throw APIError.networkError(NSError(domain: "APIError", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "请求超时，请检查网络连接"
                ]))
            case .notConnectedToInternet:
                throw APIError.networkError(NSError(domain: "APIError", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "网络连接失败，请检查网络设置"
                ]))
            default:
                throw APIError.networkError(urlError)
            }
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - 文件上传
    func uploadFile(
        endpoint: String,
        fileData: Data,
        fileName: String,
        mimeType: String = "image/jpeg",
        fieldName: String = "file"
    ) async throws -> APIResponse<FileUploadResponse> {
        guard let url = URL(string: "\(APIConfig.baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        guard let token = AuthManager.shared.authToken else {
            throw APIError.unauthorized
        }

        let boundary = UUID().uuidString
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = 60.0 // 文件上传超时时间更长

        // 构建multipart body
        var body = Data()

        // 添加文件数据
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)

        // 结束标记
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        urlRequest.httpBody = body

        // 发送请求
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let apiResponse = try JSONDecoder().decode(APIResponse<FileUploadResponse>.self, from: data)
                return apiResponse
            } else {
                if let errorResponse = try? JSONDecoder().decode(APIResponse<EmptyResponse>.self, from: data) {
                    throw APIError.serverError(errorResponse.code, errorResponse.message)
                } else {
                    throw APIError.serverError(httpResponse.statusCode, "文件上传失败")
                }
            }
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - 文件上传响应
struct FileUploadResponse: Codable {
    let url: String
    let filename: String
    let size: Int?
    let mimeType: String?
}
