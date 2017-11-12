import Vapor
import Models
import FluentProvider

final class JokeController {

	func joke(request: Request) throws -> ResponseRepresentable {
		guard let jokeWithSmallestToldCount = try Joke.makeQuery().sort(Joke.Keys.toldCount, Sort.Direction.ascending).first() else {
			throw Abort.serverError
		}
		let toldCount = jokeWithSmallestToldCount.toldCount
		let possibleJokesQuery = try Joke.makeQuery().filter(Joke.Keys.toldCount, toldCount)
		let elementIndex = try Int.random(min: 0, max: possibleJokesQuery.count() - 1)
		let joke = try possibleJokesQuery.all()[elementIndex]
		joke.toldCount += 1
		try joke.save()
		return try joke.makeJSON()
	}
}
