import Vapor
import FluentProvider

public final class Device: Model {

	public let storage: Storage = Storage()

	public var uuid: String
	public var userId: Identifier?

	public init(uuid: String) {
		self.uuid = uuid
	}

	public required init(row: Row) throws {
		uuid = try row.get("uuid")
		userId = try row.get("user_id")
	}

	public func makeRow() throws -> Row {
		var row = Row()
		try row.set("uuid", uuid)
		try row.set("user_id", userId)
		return row
	}
}

extension Device: Preparation {
	public static func prepare(_ database: Database) throws {
		try database.create(self) { devices in
			devices.id()
			devices.string("uuid", optional: false, unique: true)
			devices.parent(User.self, optional: true)
		}
	}

	public static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}

extension Device {
	public func user() throws -> Parent<Device, User> {
		return parent(id: userId)
	}
}

extension Device {
	public class func findOrCreate(uuid: String) throws -> Device {
		if let found = try Device.makeQuery().filter("uuid", uuid).first() {
			return found
		}
		let new = Device(uuid: uuid)
		try new.save()
		return try findOrCreate(uuid: uuid)
	}
}
