import Flock

public extension TaskSource {
   static let orka = TaskSource(tasks: [
       OrkaTask()
   ])
}

class OrkaTask: Task {
   let name = "orka"
   let namespace = "vapor"

   var command: String {
      return Paths.executable + " --env=\(Config.environment) --workDir=\(Paths.currentDirectory) prepare --revert --all -y"
   }

   func run(on server: Server) throws {
      try invoke("vapor:stop", on: server)
      try server.execute(command)
      try invoke("vapor:start", on: server)
   }
}
