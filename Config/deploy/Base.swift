import Flock
import Shout

class Base: Environment {
	func configure() {
		Config.projectName = "Switter"
		Config.executableName = "Run"
		Config.repoURL = "git@github.com:DaftMobile/switter.git"

		Config.serverFramework = VaporFramework()
		Config.processController = Supervisord()
	}
}
