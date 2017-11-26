import Vapor
import Models
import HTTP
import FluentProvider

final class ImageController: ConfigInitializable {

	private var images: [String: Bytes] = [:]
	private let loader = DataFile()
	private let resourcesDir: String

	init(config: Config) throws {
		resourcesDir = config.resourcesDir
	}

	private func id(for pokemon: Pokemon, thumbnail: Bool) -> String {
		return "\(pokemon.number)\(thumbnail ? "_thumb" : "")"
	}

	private func imagePath(for pokemon: Pokemon, thumbnail: Bool) -> String {
		let folder = thumbnail ? "Small" : "Big"
		let fileSuffix = thumbnail ? "_small" : ""
		return resourcesDir + "Images/Pokemons/\(folder)/\(pokemon.number)\(fileSuffix).png"
	}

	private func image(for pokemon: Pokemon, thumbnail: Bool) throws -> Bytes {
		let id = self.id(for: pokemon, thumbnail: thumbnail)
		if let image = images[id] { return image }
		try loadPhoto(for: pokemon, thumbnail: thumbnail)
		return try image(for: pokemon, thumbnail: thumbnail)
	}

	private func loadPhoto(for pokemon: Pokemon, thumbnail: Bool) throws {
		let path = imagePath(for: pokemon, thumbnail: thumbnail)
		let photo = try loader.read(at: path)
		images[id(for: pokemon, thumbnail: thumbnail)] = photo
	}


	private func response(pokemon: Pokemon, thumbnail: Bool) throws -> ResponseRepresentable {
		let photoData = try image(for: pokemon, thumbnail: thumbnail)
		let headers = [HeaderKey.contentType: "image/png"]
		return Response(status: .ok, headers: headers, body: .data(photoData))
	}

	func image(request: Request) throws -> ResponseRepresentable {
		return try response(pokemon: try request.parameters.next(Pokemon.self), thumbnail: false)
	}

	func thumbnail(request: Request) throws -> ResponseRepresentable {
		return try response(pokemon: try request.parameters.next(Pokemon.self), thumbnail: true)
	}
}
