import Foundation
import FluentProvider
import Vapor
import HTTP
import Console
import Models

public final class Seeds: Command, ConfigInitializable {

	public let id = "switter:seed"

	public let help: [String] = [
		"Seeds the database"
	]

	public let console: ConsoleProtocol
	public let resourcesDir: String
	private let environment: Environment

	public init(config: Config) throws {
		console = try config.resolveConsole()
		environment = config.environment
		resourcesDir = config.resourcesDir
	}

	public func run(arguments: [String]) throws {
		console.info("Started the seeder");
		let loader = DataFile()

		// MAKR: -- Jokes
		console.info("SEEDING JOKES")
		let jokes = try loader.read(at: resourcesDir + "Jsons/seeds/jokes.json")
		let jokesJson = try JSON(bytes: jokes)
		for jokeString in jokesJson.array! {
			guard let jokeString = jokeString.string else { throw Abort.serverError }
			let joke = Joke(content: jokeString)
			try joke.save()
		}

		// MARK: -- POKEMON
		console.info("SEEDING POKEMON")
		let pokemon = try loader.read(at: resourcesDir + "Jsons/seeds/pokemon_list.json")
		let pokemonJson = try JSON(bytes: pokemon)
		for pokemon in pokemonJson.array! {
			let name: String = try pokemon.get("name")
			let number: Int = try pokemon.get("number")
			let color: Int = try pokemon.get("color")
			try Pokemon(name: name, number: number, color: color).save()
		}

		console.info("DONE")
	}
}
