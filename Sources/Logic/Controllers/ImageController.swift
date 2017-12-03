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

	private func id(for pokemon: Pokemon, thumbnail: Bool, grey: Bool) -> String {
		return "\(pokemon.number)\(thumbnail ? "_thumb" : "")\(grey ? "_grey" : "_color")"
	}

	private func imagePath(for pokemon: Pokemon, thumbnail: Bool, grey: Bool) -> String {
		let folder = grey ? "Grey" : "Color"
		let folder2 = thumbnail ? "Small" : "Big"
		let fileSuffix = thumbnail ? "_small" : ""
		return resourcesDir + "Images/Pokemons/\(folder)/\(folder2)/\(pokemon.number)\(fileSuffix).png"
	}

	private func image(for pokemon: Pokemon, thumbnail: Bool, grey: Bool) throws -> Bytes {
		let id = self.id(for: pokemon, thumbnail: thumbnail, grey: grey)
		if let image = images[id] { return image }
		try loadPhoto(for: pokemon, thumbnail: thumbnail, grey: grey)
		return try image(for: pokemon, thumbnail: thumbnail, grey: grey)
	}

	private func loadPhoto(for pokemon: Pokemon, thumbnail: Bool, grey: Bool) throws {
		let path = imagePath(for: pokemon, thumbnail: thumbnail, grey: grey)
		let photo = try loader.read(at: path)
		images[id(for: pokemon, thumbnail: thumbnail, grey: grey)] = photo
	}

	private func response(user: User, pokemon: Pokemon, thumbnail: Bool) throws -> ResponseRepresentable {
		let grey = try !user.owns(pokemon)
		let photoData = try image(for: pokemon, thumbnail: thumbnail, grey: grey)
		let headers = [HeaderKey.contentType: "image/png"]
		return Response(status: .ok, headers: headers, body: .data(photoData))
	}

	func image(request: Request) throws -> ResponseRepresentable {
		guard let user = try request.user() else { throw Abort.unauthorized }
		return try response(user: user, pokemon: try request.parameters.next(Pokemon.self), thumbnail: false)
	}

	func thumbnail(request: Request) throws -> ResponseRepresentable {
		guard let user = try request.user() else { throw Abort.unauthorized }
		return try response(user: user, pokemon: try request.parameters.next(Pokemon.self), thumbnail: true)
	}
}
