import Vapor
import FluentProvider
import Foundation
import HTTP

public final class User: Model {

	public let storage: Storage = Storage()
	public var name: String

	public init(name: String) {
		self.name = name
	}

	public convenience init() {
		self.init(name: "John Appleseed")
	}

	public init(row: Row) throws {
		self.name = try row.get("name")
	}

	public func makeRow() throws -> Row {
		var row = Row()
		try row.set("name", name)
		return row
	}
}

extension User: SoftDeletable { }

extension User {
	public var device: Children<User, Device> {
		return children()
	}
}

extension User {
	public var pokemon: Siblings<User, Pokemon, Catch> {
		return siblings()
	}

	public func owns(_ pokemon: Pokemon) throws -> Bool {
		return try self.pokemon.isAttached(pokemon)
	}

	public func markCatch(pokemon: Pokemon) throws {
		try self.pokemon.add(pokemon)
	}
}

extension User: Preparation {
	public static func prepare(_ database: Database) throws {
		try database.create(self) { users in
			users.id()
			users.string("name")
		}
	}

	public static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}
