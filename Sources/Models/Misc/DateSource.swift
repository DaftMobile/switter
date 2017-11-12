import Foundation

public protocol DateSourcing {
	func now() -> Date
	func today() -> Date
}

public final class DateSource: DateSourcing {

	public func now() -> Date {
		return Date()
	}

	public init() { }
}

extension DateSourcing {
	public func today() -> Date {
		return DateConversion.day(from: now())
	}
}

public final class DateConversion {

	private static let calendar = Calendar.current

	public static func day(from date: Date) -> Date {
		let components = calendar.dateComponents([.day, .month, .era, .year, .timeZone], from: date)
		guard let day = calendar.date(from: components) else {
			return date
		}
		return day
	}

	public static func isWeekend(on date: Date) -> Bool {
		return calendar.isDateInWeekend(date)
	}
}

public extension Date {
	public func day() -> Date {
		return DateConversion.day(from: self)
	}

	public func isWeekend() -> Bool {
		return DateConversion.isWeekend(on: self)
	}
}
