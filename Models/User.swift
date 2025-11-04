import Foundation

struct User: Codable, Identifiable {
    let id: String
    let uid: String?
    let email: String?
    let name: String
    let provider: AuthProvider
    let imageUrl: String?
    let createdAt: Date

    enum AuthProvider: String, Codable {
        case google
        case apple
        case guest
    }
}

extension User {
    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private enum CodingKeys: String, CodingKey {
        case id
        case uid
        case email
        case name
        case provider
        case imageUrl
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let decodedId = try container.decodeIfPresent(String.self, forKey: .id)
        let decodedUid = try container.decodeIfPresent(String.self, forKey: .uid)

        guard let primaryId = decodedId ?? decodedUid else {
            throw DecodingError.keyNotFound(
                CodingKeys.id,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "User identifier not found for keys 'id' or 'uid'"
                )
            )
        }

        id = primaryId
        uid = decodedUid ?? decodedId
        email = try container.decodeIfPresent(String.self, forKey: .email)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "User"
        provider = try container.decodeIfPresent(AuthProvider.self, forKey: .provider) ?? .guest

        if let imageString = try container.decodeIfPresent(String.self, forKey: .imageUrl) {
            imageUrl = imageString
        } else {
            imageUrl = nil
        }

        if let createdString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            createdAt = User.isoFormatter.date(from: createdString) ?? Date()
        } else if let timestamp = try container.decodeIfPresent(Date.self, forKey: .createdAt) {
            createdAt = timestamp
        } else {
            createdAt = Date()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(uid, forKey: .uid)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encode(name, forKey: .name)
        try container.encode(provider, forKey: .provider)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        let dateString = User.isoFormatter.string(from: createdAt)
        try container.encode(dateString, forKey: .createdAt)
    }
}
