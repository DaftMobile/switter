import Vapor
import Models
import FluentProvider

final class JokeController {

	private let console: LogProtocol

	init(config: Config) throws {
		console = try config.resolveLog()
	}

	func joke(request: Request) throws -> ResponseRepresentable {
		guard let jokeWithSmallestToldCount = try Joke.makeQuery().sort(Joke.Keys.toldCount, Sort.Direction.ascending).first() else {
			console.error("No Jokes found!")
			throw Abort(.internalServerError, reason: "No jokes found on the server")
		}
		let toldCount = jokeWithSmallestToldCount.toldCount
		let possibleJokesQuery = try Joke.makeQuery().filter(Joke.Keys.toldCount, toldCount)
		let elementIndex = try Int.random(min: 0, max: possibleJokesQuery.count() - 1)
		let joke = try possibleJokesQuery.all()[elementIndex]
		joke.toldCount += 1
		try joke.save()
		console.info("Joke: \(joke.content)")
		return try joke.makeJSON()
	}
}
