import Vapor
import Models
import FluentProvider

final class PokemonController {

	private let console: LogProtocol

	init(config: Config) throws {
		console = try config.resolveLog()
	}

	func list(request: Request) throws -> ResponseRepresentable {
		guard let user = try request.user() else { throw Abort.unauthorized }
		let allPokemon = try Pokemon.all().sorted { $0.0.number < $0.1.number }
		return try allPokemon.map {
			try $0.makeJSON(for: user)
		}.makeJSON()
	}

	func info(request: Request) throws -> ResponseRepresentable {
		guard let user = try request.user() else { throw Abort.unauthorized }
		return try request.parameters.next(Pokemon.self).makeJSON(for: user)
	}

	func openInfo(request: Request) throws -> ResponseRepresentable {
		return try request.parameters.next(Pokemon.self).makeOpenJSON()
	}

	func catchPokemon(request: Request) throws -> ResponseRepresentable {
		guard let user = try request.user() else { throw Abort.unauthorized }
		let pokemon = try request.parameters.next(Pokemon.self)
		if try user.owns(pokemon) == false { try user.markCatch(pokemon: pokemon) }
		return try pokemon.makeJSON(for: user)
	}
}
