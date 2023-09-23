import Vapor
import MeiliSearch
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Application {
    public var meilisearch: MeiliSearchService {
        .init(application: self)
    }
    
    public struct MeiliSearchService {
        /// The `MeiliSearch` instance
        public var client: MeiliSearch {
            guard let client = self.storage.client else {
                fatalError("MeiliSearch has not been configured. Configure with app.meilisearch.configure(...)")
            }
            
            return client
        }
        
        public func configure(host: String, apiKey: String? = nil) throws {
            self.storage.client = try .init(
                host: host,
                apiKey: apiKey,
                session: MeiliSearchClientBridge(application: application)
            )
        }
        
        /// The central Vapor application
        private let application: Application
        
        internal init(application: Application) {
            self.application = application
        }
        
        final class Storage {
            var client: MeiliSearch?
            init() { }
        }
        
        private var storage: Storage {
            guard let storage = self.application.storage[Key.self] else {
                let storage = Storage()
                self.application.storage[Key.self] = storage
                return storage
            }
            
            return storage
        }
        
        private struct Key: StorageKey {
            typealias Value = Storage
        }
    }
}

struct MeiliSearchClientBridge: URLSessionProtocol {
    let application: Application
    
    func execute(with request: URLRequest, completionHandler: @escaping DataTask) -> URLSessionDataTaskProtocol {
        let clientRequest = ClientRequest(
            method: request.httpMethod.map { HTTPMethod(rawValue: $0) } ?? .GET,
            url: URI(string: request.url?.absoluteString ?? "/"),
            headers: .init(request.allHTTPHeaderFields?.map { $0 } ?? []),
            body: request.httpBody.map { ByteBuffer(data: $0) },
            timeout: nil
        )
        
        let future = application.client.send(clientRequest)
            .always { result in
                switch result {
                case .success(let response):
                    var headers: [String: String] = [:]
                    response.headers.forEach { (name: String, value: String) in
                        headers[name] = value
                    }
                    
                    let httpResponse = HTTPURLResponse(
                        url: request.url!,
                        statusCode: Int(response.status.code),
                        httpVersion: nil, // not used/needed
                        headerFields: headers // not used, but sending for future-proofness due to simplicity
                    )
                    
                    completionHandler(
                        response.body.map { Data(buffer: $0) },
                        httpResponse,
                        nil
                    )
                    
                case .failure(let error):
                    completionHandler(
                        nil,
                        nil,
                        error
                    )
                }
            }
            
        return FutureTask(future: future)
    }
    
    struct FutureTask: URLSessionDataTaskProtocol {
        let future: EventLoopFuture<ClientResponse>
        
        func resume() {
            // intentionally empty, futures will auto start
        }
    }
}
