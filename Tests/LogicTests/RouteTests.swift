import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import Models
@testable import Logic

/// This file shows an example of testing 
/// routes through the Droplet.

class RouteTests: TestCase {
    let drop = try! Droplet.testable()

	override func tearDown() {
		super.tearDown()
		for c in try! Catch.all() { try! c.delete() }
		for d in try! Device.all() { try! d.delete() }
		for u in try! User.all() { try! u.delete() }
		for p in try! Pokemon.all() { try! p.delete() }
		for j in try! Joke.all() { try! j.delete() }
	}

    func testHello() throws {
        try drop
            .testResponse(to: .get, at: "api/hello")
            .assertStatus(is: .ok)
            .assertBody(equals: "Hello world!")
    }

	var validHeaders: [HeaderKey: String] {
		return ["x-device-uuid": "123-123"]
	}

	var differentHeaders: [HeaderKey: String] {
		return ["x-device-uuid": "123-1234"]
	}

    func testNoJokesgives500() throws {
        try drop
			.testResponse(to: .get, at: "api/joke", headers: validHeaders)
			.assertStatus(is: .internalServerError)
    }

	private func createSampleJoke() throws {
		try Joke.init(content: "Funny").save()
	}

	func testValidJoke() throws {
		try createSampleJoke()
		XCTAssertEqual(try Joke.count(), 1)
		XCTAssertEqual(try Joke.all().first?.toldCount, 0)
		try drop
			.testResponse(to: .get, at: "api/joke", headers: validHeaders)
			.assertStatus(is: .ok)
			.assertJSON("content", equals: "Funny")
		XCTAssertEqual(try Joke.all().first?.toldCount, 1)
	}

	func testApiAddsDeviceAndUserToTheDatabase() throws {
		try createSampleJoke()
		try drop
			.testResponse(to: .get, at: "api/joke", headers: validHeaders)
		XCTAssertEqual(try Device.count(), 1)
		XCTAssertEqual(try User.count(), 1)
		XCTAssertNotNil(try User.all().first?.device.all().first)
	}

	private func createSampleDevice() throws -> Device {
		try drop.testResponse(to: .get, at: "api/joke", headers: validHeaders)
		return try Device.all().first!
	}

	private func createSampleUser() throws -> User {
		return try createSampleDevice().user().get()!
	}

	private func seedSamplePokemon() throws {
		try Pokemon(name: "Bulbasaur", number: 1, color: 8570017).save()
		try Pokemon(name: "Charmander", number: 4, color: 15313528).save()
	}

	private func discoverBothPokemon() throws {
		let user = try createSampleUser()
		for pokemon in try Pokemon.all() {
			try user.markCatch(pokemon: pokemon)
		}
	}

	private func discoverBulbasaur() throws {
		let user = try createSampleUser()
		guard let bulbasaur = try Pokemon.makeQuery().filter("name", "Bulbasaur").first() else { throw Abort.serverError }
		try user.markCatch(pokemon: bulbasaur)
	}

	private func image(from: Droplet, index: Int, thumb: Bool, discovered: Bool) throws -> Bytes {
		let path = drop.config.resourcesDir.appending("Images/Pokemons/\(discovered ? "Color" : "Grey")/\(thumb ? "Small" : "Big")/\(index)\(thumb ? "_small": "").png")
		return try FileSourceFake().read(at: path)
	}

	private func seedAndDiscover() throws {
		try seedSamplePokemon()
		try discoverBothPokemon()
	}

	func testPokemonAllGet() throws {
		try seedAndDiscover()
		try drop
			.testResponse(to: .get, at: "api/pokemon", headers: validHeaders)
			.assertStatus(is: .ok)
			.assertJSON("", passes: { json -> Bool in
				return json.array?.count == 2
					&& json.array?.first?["name"]?.string == "Bulbasaur"
					&& json.array?.first?["number"]?.int == 1
			})
	}

	func testPokemonAllGetWhenOnlyBulbasaurIsCaught() throws {
		try seedSamplePokemon()
		try discoverBulbasaur()
		try drop
			.testResponse(to: .get, at: "api/pokemon", headers: validHeaders)
			.assertStatus(is: .ok)
			.assertJSON("", passes: { json -> Bool in
				return json.array?.count == 2
					&& json.array?.first?["name"]?.string == "Bulbasaur"
					&& json.array?.first?["color"]?.int == 8570017
					&& json.array?.first?["number"]?.int == 1
					&& json.array?.last?["name"]?.string == Pokemon.undiscoveredName
					&& json.array?.last?["color"]?.int == Pokemon.undiscoveredColor
					&& json.array?.last?["number"]?.int == 4
			})
	}

	func testSinglePokemonValidRoute() throws {
		try seedAndDiscover()
		try drop
			.testResponse(to: .get, at: "api/pokemon/4", headers: validHeaders)
			.assertStatus(is: .ok)
			.assertJSON("name", equals: "Charmander")
			.assertJSON("number", equals: 4)
			.assertJSON("color", equals: 15313528)
	}

	func testSinglePokemonValidRouteWithoutDiscovery() throws {
		try seedSamplePokemon()
		try drop
			.testResponse(to: .get, at: "api/pokemon/4", headers: validHeaders)
			.assertStatus(is: .ok)
			.assertJSON("name", equals: Pokemon.undiscoveredName)
			.assertJSON("number", equals: 4)
			.assertJSON("color", equals: Pokemon.undiscoveredColor)
		try drop
			.testResponse(to: .post, at: "api/pokemon/4/catch", headers: validHeaders)
			.assertStatus(is: .ok)
			.assertJSON("name", equals: "Charmander")
			.assertJSON("number", equals: 4)
			.assertJSON("color", equals: 15313528)
		try drop
			.testResponse(to: .get, at: "api/pokemon/4", headers: validHeaders)
			.assertStatus(is: .ok)
			.assertJSON("name", equals: "Charmander")
			.assertJSON("number", equals: 4)
			.assertJSON("color", equals: 15313528)

		try drop
			.testResponse(to: .get, at: "api/pokemon/4", headers: differentHeaders)
			.assertStatus(is: .ok)
			.assertJSON("name", equals: Pokemon.undiscoveredName)
			.assertJSON("number", equals: 4)
			.assertJSON("color", equals: Pokemon.undiscoveredColor)
	}

	func testThumbnailWithDiscovery() throws {
		try seedAndDiscover()
		let body = try drop
			.testResponse(to: .get, at: "api/pokemon/4/thumbnail", headers: validHeaders)
			.assertStatus(is: .ok)
			.testBody()
		XCTAssertEqual(body, try image(from: drop, index: 4, thumb: true, discovered: true))
	}

	func testThumbnailWithoutDiscovery() throws {
		try seedSamplePokemon()
		let body = try drop
			.testResponse(to: .get, at: "api/pokemon/4/thumbnail", headers: validHeaders)
			.assertStatus(is: .ok)
			.testBody()
		XCTAssertEqual(body, try image(from: drop, index: 4, thumb: true, discovered: false))
	}

	func testFullImageWithDiscovery() throws {
		try seedAndDiscover()
		let body = try drop
			.testResponse(to: .get, at: "api/pokemon/4/image", headers: validHeaders)
			.assertStatus(is: .ok)
			.testBody()
		XCTAssertEqual(body, try image(from: drop, index: 4, thumb: false, discovered: true))
	}

	func testFullImageWithoutDiscovery() throws {
		try seedSamplePokemon()
		let body = try drop
			.testResponse(to: .get, at: "api/pokemon/4/image", headers: validHeaders)
			.assertStatus(is: .ok)
			.testBody()
		XCTAssertEqual(body, try image(from: drop, index: 4, thumb: false, discovered: false))
	}

	func testSinglePokemonInvalidRoute() throws {
		try seedAndDiscover()
		try drop
			.testResponse(to: .get, at: "api/pokemon/5", headers: validHeaders)
			.assertStatus(is: .notFound)
	}

	func testSinglePokemonValidRouteByName() throws {
		try seedAndDiscover()
		try drop
			.testResponse(to: .get, at: "api/pokemon/Charmander", headers: validHeaders)
			.assertStatus(is: .ok)
			.assertJSON("name", equals: "Charmander")
			.assertJSON("number", equals: 4)
			.assertJSON("color", equals: 15313528)
	}

	func testSinglePokemonValidRouteByNameLowercased() throws {
		try seedAndDiscover()
		try drop
			.testResponse(to: .get, at: "api/pokemon/charmander", headers: validHeaders)
			.assertStatus(is: .ok)
			.assertJSON("name", equals: "Charmander")
			.assertJSON("number", equals: 4)
			.assertJSON("color", equals: 15313528)
	}

	func testSinglePokemonInvalidRouteByName() throws {
		try seedAndDiscover()
		try drop
			.testResponse(to: .get, at: "api/pokemon/charmandera", headers: validHeaders)
			.assertStatus(is: .notFound)
	}

	func testSinglePokemonInvalidRouteByNameIncomplete() throws {
		try seedAndDiscover()
		try drop
			.testResponse(to: .get, at: "api/pokemon/charm", headers: validHeaders)
			.assertStatus(is: .notFound)
	}

	func testAllPokemonEndpointWhenPokemonAreNotDiscoveredByThisDevice() throws {
		try seedSamplePokemon()
		try drop
			.testResponse(to: .get, at: "api/pokemon", headers: validHeaders)
			.assertStatus(is: .ok)
			.assertJSON("", passes: { json -> Bool in
				return json.array?.count == 2
					&& json.array?.first?["name"]?.string == "Unknown"
					&& json.array?.first?["number"]?.int == 1
					&& json.array?.last?["name"]?.string == "Unknown"
					&& json.array?.last?["number"]?.int == 4
			})
	}

	func testUnauthorizedUserCanPeekPokemonByName() throws {
		try seedSamplePokemon()
		try drop
			.testResponse(to: .get, at: "api/pokemon/charmander/peek", headers: validHeaders)
			.assertStatus(is: .ok)
			.assertJSON("name", equals: "Charmander")
			.assertJSON("number", equals: 4)
			.assertJSON("color", equals: 15313528)
	}

	func testUnauthorizedUserCanPeekPokemonByNumber() throws {
		try seedSamplePokemon()
		try drop
			.testResponse(to: .get, at: "api/pokemon/4/peek", headers: validHeaders)
			.assertStatus(is: .ok)
			.assertJSON("name", equals: "Charmander")
			.assertJSON("number", equals: 4)
			.assertJSON("color", equals: 15313528)
	}
}

// MARK: Manifest

extension RouteTests {
	static let allTests = [
		("testHello", testHello),
		("testNoJokesgives500", testNoJokesgives500),
		("testValidJoke", testValidJoke),
		("testApiAddsDeviceAndUserToTheDatabase", testApiAddsDeviceAndUserToTheDatabase),
		("testPokemonAllGet", testPokemonAllGet),
		("testPokemonAllGetWhenOnlyBulbasaurIsCaught", testPokemonAllGetWhenOnlyBulbasaurIsCaught),
		("testSinglePokemonValidRoute", testSinglePokemonValidRoute),
		("testSinglePokemonValidRouteWithoutDiscovery", testSinglePokemonValidRouteWithoutDiscovery),
		("testThumbnailWithDiscovery", testThumbnailWithDiscovery),
		("testThumbnailWithoutDiscovery", testThumbnailWithoutDiscovery),
		("testFullImageWithDiscovery", testFullImageWithDiscovery),
		("testFullImageWithoutDiscovery", testFullImageWithoutDiscovery),
		("testSinglePokemonInvalidRoute", testSinglePokemonInvalidRoute),
		("testSinglePokemonValidRouteByName", testSinglePokemonValidRouteByName),
		("testSinglePokemonValidRouteByNameLowercased", testSinglePokemonValidRouteByNameLowercased),
		("testSinglePokemonInvalidRouteByName", testSinglePokemonInvalidRouteByName),
		("testSinglePokemonInvalidRouteByNameIncomplete", testSinglePokemonInvalidRouteByNameIncomplete),
		("testAllPokemonEndpointWhenPokemonAreNotDiscoveredByThisDevice", testAllPokemonEndpointWhenPokemonAreNotDiscoveredByThisDevice),
		("testUnauthorizedUserCanPeekPokemonByName", testUnauthorizedUserCanPeekPokemonByName),
		("testUnauthorizedUserCanPeekPokemonByNumber", testUnauthorizedUserCanPeekPokemonByNumber)
	]
}
