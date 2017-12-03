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

	private func seedSamplePokemon() throws {
		try Pokemon(name: "Bulbasaur", number: 1, color: 8570017).save()
		try Pokemon(name: "Charmander", number: 4, color: 15313528).save()
	}

	private func discoverBothPokemon() throws {

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

	func testSinglePokemonValidRoute() throws {
		try seedAndDiscover()
		try drop
			.testResponse(to: .get, at: "api/pokemon/4", headers: validHeaders)
			.assertStatus(is: .ok)
			.assertJSON("name", equals: "Charmander")
			.assertJSON("number", equals: 4)
			.assertJSON("color", equals: 15313528)
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
}

// MARK: Manifest

extension RouteTests {
    static let allTests = [
        ("testHello", testHello),
        ("testNoJokesgives500", testNoJokesgives500),
		("testValidJoke", testValidJoke),
		("testSinglePokemonValidRoute", testSinglePokemonValidRoute),
		("testSinglePokemonInvalidRoute", testSinglePokemonInvalidRoute),
		("testSinglePokemonValidRouteByName", testSinglePokemonValidRouteByName),
		("testSinglePokemonValidRouteByNameLowercased", testSinglePokemonValidRouteByNameLowercased),
		("testSinglePokemonInvalidRouteByName", testSinglePokemonInvalidRouteByName),
		("testSinglePokemonInvalidRouteByNameIncomplete", testSinglePokemonInvalidRouteByNameIncomplete)
    ]
}
