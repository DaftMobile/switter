import Foundation
import Vapor

public class FileSourceFake: FileProtocol {

	public var readCalled: Bool = false

	public func read(at path: String) throws -> Bytes {
		readCalled = true
		return path.data(using: .utf8)?.makeBytes() ?? []
	}

	public func write(_ bytes: Bytes, to path: String) throws {
		throw Abort(.internalServerError)
	}

	public func delete(at path: String) throws {
		throw Abort(.internalServerError)
	}
}
