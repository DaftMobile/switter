import Vapor
import HTTP

public final class FileUrlCreator: ConfigInitializable {
	private enum FileType: String {
		case gif
		case png
		case jpg
	}

	private let resourcesDir: String

	public init(config: Config) {
		self.resourcesDir = config.resourcesDir
	}

	public init(resourcesDir: String) {
		self.resourcesDir = resourcesDir
	}

	private func path(name: String, directory: String) -> String {
		return resourcesDir + "Uploads" + "/" + directory + "/" + name
	}

	private func directory(fileType: FileType) -> String {
		switch fileType {
		case .gif:
			return "Gifs"
		case .png:
			return "Photos"
		case .jpg:
			return "Images"
		}
	}

	private func photoName(for id: String, type: FileType) -> String {
		return "photo-\(id).\(type.rawValue)"
	}

	public func pathForFile(with id: String, type: String) throws -> String {
		guard let fileType = FileType(rawValue: type) else {
			throw Abort(.badRequest, reason: "Invalid file type")
		}
		let directory = self.directory(fileType: fileType)
		let name = photoName(for: id, type: fileType)
		return path(name: name, directory: directory)
	}

	public func mediaType(type: String) throws -> String {
		switch FileType(rawValue: type)  {
		case .none:
			throw Abort(.badRequest, reason: "Media type for invalid file type?")
		case .some(.gif):
			return "image/gif"
		case .some(.png):
			return "image/png"
		case .some(.jpg):
			return "image/jpeg"
		}
	}
}
