import Vapor
import MeiliSearch

extension Vapor.Request {
    public var meilisearch: MeiliSearch {
        application.meilisearch.client
    }
}
