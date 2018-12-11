import Flock

public extension TaskSource {
   static let orka = TaskSource(tasks: [
       OrkaTask(),
       RemoveOldReleasesTask()
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
   }
}

class RemoveOldReleasesTask: Task {
   let name = "remove_old"
   let namespace = "deploy"

   func find(currentPath: String) -> String {
      return "find \(Paths.releasesDirectory) -maxdepth 1 -type d ! -path \(Paths.releasesDirectory) ! -path \(currentPath)"
   }

   func remove(directory: String) -> String {
      return "rm -rf \(directory)"
   }

   func run(on server: Server) throws {
      let currentPath = try server.capture("readlink \(Paths.currentDirectory)").trimmingCharacters(in: .whitespacesAndNewlines)
      let pathsToDelete = try server
         .capture(find(currentPath: currentPath))
         .components(separatedBy: .newlines)
         .filter { !$0.isEmpty }
         .filter { $0.hasPrefix(Paths.releasesDirectory) }
      for path in pathsToDelete {
         try server.execute(remove(directory: path))
      }
   }
}
