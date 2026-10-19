import Foundation

/// Changes the real Pi would need before a live connection can do the matching job.
/// StreetPi does not apply these.
public enum PiSideAsk {
    public static let queryLogging = """
    Turn query logging back on if you want a live query log, a live log, top lists, \
    and a real 24-hour chart. StreetPi will not change this. Memory-only retention \
    (database.maxDBdays=0) would spare the SD card.
    """

    public static let localNames = """
    Saving local names (dns.hosts and dns.cnameRecords) needs webserver.api.app_sudo=true \
    or the real admin password. The app password with app_sudo=false can read them and \
    cannot write them. StreetPi will not change that setting.
    """
}
