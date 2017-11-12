import Vapor
import FluentProvider
import HTTP

public final class Joke: Model {
    public let storage = Storage()
    
    // MARK: Properties and database keys
    
    /// The content of one Joke
    public var content: String
	public var toldCount: Int

    public struct Keys {
        public static let id = "id"
        public static let content = "content"
		public static let toldCount = "told_count"
    }

    /// Creates a new Joke
    public init(content: String) {
        self.content = content
		self.toldCount = 0
    }

    // MARK: Fluent Serialization

    /// Initializes the Post from the
    /// database row
    public init(row: Row) throws {
        content = try row.get(Joke.Keys.content)
		toldCount = try row.get(Joke.Keys.toldCount)
    }

    // Serializes the Post to the database
    public func makeRow() throws -> Row {
        var row = Row()
        try row.set(Joke.Keys.content, content)
		try row.set(Joke.Keys.toldCount, toldCount)
        return row
    }
}

// MARK: Fluent Preparation

extension Joke: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Jokes
    public static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
			builder.int(Joke.Keys.toldCount, optional: false, unique: false)
            builder.string(Joke.Keys.content)
        }
    }

    /// Undoes what was done in `prepare`
    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension Joke: JSONRepresentable {
    public func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Joke.Keys.content, content)
        return json
    }
}

// MARK: HTTP

// This allows Joke models to be returned
// directly in route closures
extension Joke: ResponseRepresentable { }
