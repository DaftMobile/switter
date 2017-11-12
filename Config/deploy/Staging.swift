import Flock
import Shout

class Staging: Environment {
	func configure() {
		Config.SSHAuthMethod = Keychain.mdab121

		Config.deployDirectory = "/home/deploy"
		Config.repoBranch = "master"
		Flock.serve(address: Server.Address(ip: "91.185.189.8", port: 2200), user: "deploy", roles: [.app, .db, .web], authMethod: Keychain.mdab121)
	}
}
