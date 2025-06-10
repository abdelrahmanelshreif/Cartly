import Alamofire
import Foundation

extension HTTPMethod {
    init(rawValue: Method) {
        switch rawValue {
        case .GET: self = .get
        case .POST: self = .post
        case .PUT: self = .put
        case .DELETE: self = .delete
        }
    }
}
