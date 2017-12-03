import Vapor
import FluentProvider

public final class Catch: Model {

	public let storage: Storage = Storage()

	public var pokemonId: Identifier?
	public var userId: Identifier?

	public init(row: Row) throws {
		self.pokemonId = try row.get("pokemon_id")
		self.userId = try row.get("user_id")
	}

	public func makeRow() throws -> Row {
		var row = Row()
		try row.set("pokemon_id", pokemonId)
		try row.set("user_id", userId)
		return row
	}

	var user: Parent<Catch, User> {
		return parent(id: userId)
	}

	var pokemon: Parent<Catch, Pokemon> {
		return parent(id: pokemonId)
	}
}

extension Catch: PivotProtocol {
	public typealias Left = User
	public typealias Right = Pokemon

	public static var leftIdKey: String { return "user_id" }
	public static var rightIdKey: String { return "pokemon_id" }
}

extension Catch: Timestampable { }

extension Catch: Preparation {
	public static func prepare(_ database: Database) throws {
		try database.create(self) { catches in
			catches.id()
			catches.parent(User.self, optional: false)
			catches.parent(Pokemon.self, optional: false)
		}
	}

	public static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}
