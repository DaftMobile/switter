import Vapor

public final class Provider: Vapor.Provider {

	public static let repositoryName: String = "switter-model"

	public init(config: Config) throws { }

	public func boot(_ config: Config) throws {
		config.preparations.append(User.self)
		config.preparations.append(Device.self)
		config.preparations.append(Joke.self)
		config.preparations.append(Pokemon.self)
		config.preparations.append(Catch.self)
	}

	public func boot(_ droplet: Droplet) throws { }
	public func beforeRun(_ droplet: Droplet) throws { }
}
