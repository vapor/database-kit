import Foundation

protocol DatabaseConfigRepresentable {
    var username: String? { get}
    var password: String? { get}
    var hostname: String? { get}
    var port: Int? { get}
    var scheme: String? { get }
    var database: String? { get }
}


extension URL: DatabaseConfigRepresentable {
    var database: String? {
        return path
    }

    var hostname: String? {
        return host
    }

    var username: String? {
        return user
    }
}

extension String: DatabaseConfigRepresentable {
    var user: String? {
        return url?.user
    }

    var password: String? {
        return url?.password
    }

    var port: Int? {
        return url?.port
    }

    var scheme: String? {
        return url?.scheme
    }

    var url: URL? {
        return URL(string: self)
    }

    var hostname: String? {
        return url?.host
    }

    var database: String? {
        return url?.database
    }

    var username: String? {
        return url?.user
    }
}
