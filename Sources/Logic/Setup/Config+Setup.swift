import FluentProvider
import Models
import MySQLProvider
import SwiftyBeaverProvider

extension Config {
    public func setup() throws {
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
		try setupCommands()
        try setupPreparations()
    }
    

    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
		try addProvider(MySQLProvider.Provider.self)
		try addProvider(SwiftyBeaverProvider.Provider.self)
		try addProvider(Models.Provider.self)
    }

	private func setupCommands() throws {
		addConfigurable(command: Seeds.init, name: "switter:seed")
	}

    private func setupPreparations() throws {
    }
}
