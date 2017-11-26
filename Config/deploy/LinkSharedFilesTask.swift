import Flock

public extension TaskSource {
    static let linkSecrets = TaskSource(tasks: [
        LinkSharedFilesTask(),
        LinkSecretsTask(),
        LinkJsonsTask(),
        LinkImagesTask()
    ])
}

private let linkShared = "link_shared"

extension Paths {
    public static var sharedDirectory: String {
        return "\(projectDirectory)/shared"
    }

    public static var secretsDirectory: String {
        return "\(sharedDirectory)/secrets"
    }

    public static var jsonsDirectory: String {
        return "\(sharedDirectory)/Jsons"
    }

    public static var imagesDirectory: String {
        return "\(sharedDirectory)/Images"
    }
}

class LinkSharedFilesTask: Task {
    let name = linkShared
    let hookTimes: [HookTime] = [.after("deploy:git")]

    func run(on server: Server) throws {
        try invoke("link_shared:secrets", on: server)
        try invoke("link_shared:jsons", on: server)
        try invoke("link_shared:images", on: server)
    }
}

class LinkSecretsTask: Task {

    let name = "secrets"
    let namespace = linkShared

    func run(on server: Server) throws {
        let destinationDirectory = "\(Paths.nextDirectory)/Config/secrets"
        try server.execute("ln -sfn \(Paths.secretsDirectory) \(destinationDirectory)")
    }
}

class LinkJsonsTask: Task {

    let name = "jsons"
    let namespace = linkShared

    func run(on server: Server) throws {
        let destinationDirectory = "\(Paths.nextDirectory)/Resources"
        try server.execute("mkdir -p \(Paths.nextDirectory)/Resources")
        try server.execute("ln -sfn \(Paths.jsonsDirectory) \(destinationDirectory)")
    }
}

class LinkImagesTask: Task {

    let name = "images"
    let namespace = linkShared

    func run(on server: Server) throws {
        let destinationDirectory = "\(Paths.nextDirectory)/Resources"
        try server.execute("mkdir -p \(Paths.nextDirectory)/Resources")
        try server.execute("ln -sfn \(Paths.imagesDirectory) \(destinationDirectory)")
    }
}

