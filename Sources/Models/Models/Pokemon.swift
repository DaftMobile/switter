import Vapor
import FluentProvider
import HTTP

public final class Pokemon: Model {
	public let storage = Storage()

	// MARK: Properties and database keys

	/// The content of one Joke
	public var name: String
	public var number: Int
	public var colorNumber: Int
	public static let undiscoveredColor: Int = 7237230
	public static let undiscoveredName: String = "Unknown"

	public struct Keys {
		public static let id = "id"
		public static let name = "name"
		public static let number = "number"
		public static let colorNumber = "color"
	}

	public func makeRow() throws -> Row {
		var row = Row()
		try row.set(Keys.name, name)
		try row.set(Keys.number, number)
		try row.set(Keys.colorNumber, colorNumber)
		return row
	}

	public init(row: Row) throws {
		name = try row.get(Pokemon.Keys.name)
		number = try row.get(Pokemon.Keys.number)
		colorNumber = try row.get(Pokemon.Keys.colorNumber)
	}


	public init(name: String, number: Int, color: Int) {
		self.name = name
		self.number = number
		self.colorNumber = color
	}
}

extension Pokemon: Preparation {
	public static func prepare(_ database: Database) throws {
		try database.create(self) { builder in
			builder.id()
			builder.string(Pokemon.Keys.name, optional: false, unique: true)
			builder.int(Pokemon.Keys.number, optional: false, unique: true)
			builder.int(Pokemon.Keys.colorNumber)
		}
	}

	public static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}

extension Pokemon {
	public func makeJSON(for user: User) throws -> JSON {
		let name = try user.owns(self) ? self.name : Pokemon.undiscoveredName
		let color = try user.owns(self) ? self.colorNumber : Pokemon.undiscoveredColor
		return try pokemonJson(number: number, name: name, color: color)
	}

	public func makeOpenJSON() throws -> JSON {
		return try pokemonJson(number: number, name: name, color: colorNumber)
	}

	private func pokemonJson(number: Int, name: String, color: Int) throws -> JSON {
		var json = JSON()
		try json.set(Pokemon.Keys.number, number)
		try json.set(Pokemon.Keys.name, name)
		try json.set(Pokemon.Keys.colorNumber, color)
		return json
	}
}

extension Pokemon {
	var trainers: Siblings<Pokemon, User, Catch> {
		return siblings()
	}
}

extension Pokemon: Parameterizable {
	public static func make(for parameter: String) throws -> Pokemon {
		if let number = Int(parameter) {
			guard let pokemon = try makeQuery().filter(Keys.number, number).first() else { throw Abort.notFound }
			return pokemon
		}
		// Try seaching by name
		guard let pokemon = try makeQuery().filter(Keys.name, .custom("LIKE"), parameter).first() else { throw Abort.notFound }
		return pokemon
	}

	public static var uniqueSlug: String { return Pokemon.Keys.number }
}

