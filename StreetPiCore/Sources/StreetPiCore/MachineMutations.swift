import Foundation

extension MachineDesk {
    public func applying(_ action: HouseholdAction) -> MachineDesk {
        var copy = self
        copy.applyServiceChange(action)
        copy.applyFileChange(action)
        return copy
    }

    private mutating func applyServiceChange(_ action: HouseholdAction) {
        switch action {
        case .stopMachineService(let name):
            retitle(name, in: \.services, detail: "Stopped")
        case .startMachineService(let name):
            retitle(name, in: \.services, detail: "Running")
        case .stopContainer(let name):
            retitle(name, in: \.containers, detail: "Stopped")
        case .startContainer(let name):
            retitle(name, in: \.containers, detail: "Running")
        case .killProcess(let name):
            processes.removeAll { $0.name == name }
        default:
            break
        }
    }

    private mutating func applyFileChange(_ action: HouseholdAction) {
        switch action {
        case .deleteFiles:
            if !files.isEmpty { files.removeFirst() }
        case .saveFile(let name):
            guard let index = files.firstIndex(where: { $0.name == name }) else { return }
            files[index].text += "Saved from the phone.\n"
        case .runBackup:
            backupSentence = "The weekly copy is running."
        case .setPin(let name, let on):
            guard let index = pins.firstIndex(where: { $0.name == name }) else { return }
            pins[index].on = on
        case .addCron(let name):
            schedule.append(NamedRow(id: name, name: name, detail: "Added on the phone"))
        case .removeCron(let name):
            schedule.removeAll { $0.name == name }
        case .installUpdates:
            updates = []
        default:
            break
        }
    }

    private mutating func retitle(_ name: String, in key: WritableKeyPath<MachineDesk, [NamedRow]>, detail: String) {
        guard let index = self[keyPath: key].firstIndex(where: { $0.name == name }) else { return }
        self[keyPath: key][index].detail = detail
    }
}

extension PiSideAsk {
    public static let sshUser = """
    Create a dedicated SSH user, for example streetpi, and put the phone's ed25519 public key \
    in that user's authorized_keys. Allow key login only. StreetPi will not create the user.
    """

    public static let hostPin = """
    Tell StreetPi the host key fingerprint so the phone can pin it. StreetPi will not talk to \
    a host it has not pinned.
    """

    public static let netdata = """
    Confirm Netdata answers on the LAN with no login at /api/v1/info, /api/v3/data, and \
    /api/v1/alarms, and how many days of history it keeps. StreetPi will not change Netdata.
    """

    public static let sudoers = """
    Give the dedicated user passwordless sudo only for an allowlist: systemctl start, stop, \
    and restart of named units, journalctl, docker ps, start, stop, restart, and logs, \
    kill of that user's own processes, systemctl reboot, systemctl poweroff, the existing \
    weekly copy script, and apt list plus apt upgrade. Do not add the user to the docker \
    group. Do not expose the Docker socket. StreetPi will not write sudoers.
    """

    public static let files = """
    Leave the SFTP subsystem on. The phone browses that user's home. StreetPi will not edit \
    system files.
    """

    public static let pins = """
    Add the dedicated user to the gpio group and confirm pinctrl is installed before pin \
    changes can work. StreetPi will not change groups.
    """

    public static let noAgent = """
    Do not install the Open Pi agent, raspiBackup, or a push relay. Alerts stay inside the app.
    """
}
