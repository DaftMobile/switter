import Flock

Flock.configure(base: Base(), environments: [Staging(), Staging2()])

Flock.use(.deploy)
Flock.use(.linkSecrets)
Flock.use(.orka)
Flock.use(.swiftenv)
Flock.use(.server)

Flock.run()
