import Flock
import Shout

class Base: Environment {
	func configure() {
		Config.projectName = "Switter"
		Config.executableName = "Run"
		Config.repoURL = "ssh://git@gitlab.int.daftcode.pl:2200/mdabrowski/switter.git"

		Config.serverFramework = VaporFramework()
		Config.processController = Supervisord()
	}
}
