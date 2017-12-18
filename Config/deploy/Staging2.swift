import Flock
import Shout

class Staging2: Environment {
	func configure() {
		Config.SSHAuthMethod = Keychain.daft

		Config.deployDirectory = "/home/deploy_mobile"
		Config.repoBranch = "master"
		Flock.serve(address: Server.Address(user: "mdabrowski", ip: "daftmobile-stg.int.daftcode.local", port: 2200), user: "deploy_mobile", roles: [.app, .db, .web], authMethod: Keychain.daft)
	}
}
