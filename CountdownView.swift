import Foundation
import ScreenSaver

final class CountdownView: ScreenSaverView {

	// MARK: - Properties

	private let placeholderLabel: Label = {
		let view = Label()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.stringValue = "Open Screen Saver Options to set your date."
		view.textColor = .white
		view.isHidden = true
		return view
	}()



	private let hoursView: PlaceView = {
		let view = PlaceView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.detailTextLabel.stringValue = "HOURS"
		return view
	}()

	private let minutesView: PlaceView = {
		let view = PlaceView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.detailTextLabel.stringValue = "MINUTES"
		return view
	}()

	private let secondsView: PlaceView = {
		let view = PlaceView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.detailTextLabel.stringValue = "SECONDS"
		return view
	}()

	private let placesView: NSStackView = {
		let view = NSStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()

	private lazy var configurationWindowController: NSWindowController = {
		return ConfigurationWindowController()
	}()

	private var date: Date? {
		didSet {
			updateFonts()
		}
	}


	// MARK: - Initializers

	convenience init() {
		self.init(frame: .zero, isPreview: false)
	}

	override init!(frame: NSRect, isPreview: Bool) {
		super.init(frame: frame, isPreview: isPreview)
		initialize()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		initialize()
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	

	// MARK: - NSView

	override func draw(_ rect: NSRect) {
		NSColor.black.setFill()
		NSBezierPath.fill(bounds)
	}

	// If the screen saver changes size, update the font
    override func resize(withOldSuperviewSize oldSize: NSSize) {
        super.resize(withOldSuperviewSize: oldSize)
		updateFonts()
	}

    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        updateFonts()
    }


	// MARK: - ScreenSaverView

	override func animateOneFrame() {
		placeholderLabel.isHidden = date != nil
		placesView.isHidden = !placeholderLabel.isHidden

		guard let date = date else { return }

		let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: date)

        hoursView.textLabel.stringValue = components.hour.flatMap { String(format: "%02d", abs($0)) } ?? ""
        minutesView.textLabel.stringValue = components.minute.flatMap { String(format: "%02d", abs($0)) } ?? ""
        secondsView.textLabel.stringValue = components.second.flatMap { String(format: "%02d", abs($0)) } ?? ""
	}

    override var hasConfigureSheet: Bool {
        return true
    }

    override var configureSheet: NSWindow? {
        return configurationWindowController.window
    }


	// MARK: - Private

	/// Shared initializer
	private func initialize() {
		// Set animation time interval
		animationTimeInterval = 1 / 30

		// Recall preferences
		date = Preferences().date

		// Setup the views
		addSubview(placeholderLabel)

		placesView.addArrangedSubview(hoursView)
		placesView.addArrangedSubview(minutesView)
		placesView.addArrangedSubview(secondsView)
		addSubview(placesView)

		updateFonts()

		addConstraints([
            placeholderLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

			placesView.centerXAnchor.constraint(equalTo: centerXAnchor),
			placesView.centerYAnchor.constraint(equalTo: centerYAnchor)
		])

		// Listen for configuration changes
        
        //let now = Date() // Current Date/Time
        
            
            var dateComponents = DateComponents()
            dateComponents.setValue(1, for: .day); // +1 day
            
            let now = Date() // Current date
            let tomorrow = Calendar.current.date(byAdding: dateComponents, to: now)  // Add the DateComponents
            
            
            let today = Date()
            let formatter1 = DateFormatter()
            formatter1.dateStyle = .short
            print(formatter1.string(from: today))
            
            let myArray = (Array(formatter1.string(from: today)))
            
            let day = "\(myArray[0])\(myArray[1])"
            print(day)
            let month = "\(myArray[3])\(myArray[4])"
            print(month)
            let year = "\(myArray[6])\(myArray[7])\(myArray[8])\(myArray[9])"
            print(year)
        
        
        var myHour = 0
        var myMinute = 0
            
        if let weekday = getDayOfWeek("\(year)-\(month)-\(day)") {
            switch weekday {
                case 1:
                print("sunday")
                 myHour = 21
                 myMinute = 50
                case 2:
                print("monday")
                 myHour = 22
                 myMinute = 20
                case 3:
                print("tuesday")
                 myHour = 21
                 myMinute = 50
                case 4:
                print("wednesday")
                 myHour = 22
                 myMinute = 20
                case 5:
                print("thursday")
                 myHour = 21
                 myMinute = 50
                case 6:
                print("friday")
                 myHour = 21
                 myMinute = 50
                case 7:
                print("saturday")
                 myHour = 22
                 myMinute = 20
                default:
                print("other")
                let myHour = 21
                let myMinute = 50
                
            }
            
            
        } else {
            print("bad input")
        }
        

        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let someDateTime = formatter.date(from: "\(year)/\(month)/\(day) \(myHour):\(myMinute)")
        
        date = someDateTime

        

	}
    
    func getDayOfWeek(_ today:String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }

	/// Date changed


	/// Update the font for the current size
	private func updateFonts() {
		placesView.spacing = floor(bounds.width * 0.05)

        placeholderLabel.font = font(withSize: floor(bounds.width / 30), isMonospace: false)

		let places = [hoursView, minutesView, secondsView]
        let textFont = font(withSize: round(bounds.width / 8), weight: .ultraLight)
        let detailTextFont = font(withSize: floor(bounds.width / 38))

		for place in places {
			place.textLabel.font = textFont
			place.detailTextLabel.font = detailTextFont
		}
	}

	/// Get a font
    private func font(withSize fontSize: CGFloat, weight: NSFont.Weight = .thin, isMonospace monospace: Bool = true) -> NSFont {
        let font = NSFont.systemFont(ofSize: fontSize, weight: weight)

		let fontDescriptor: NSFontDescriptor
		if monospace {
            fontDescriptor = font.fontDescriptor.addingAttributes([
                .featureSettings: [
					[
                        NSFontDescriptor.FeatureKey.typeIdentifier: kNumberSpacingType,
                        NSFontDescriptor.FeatureKey.selectorIdentifier: kMonospacedNumbersSelector
					]
				]
			])
		} else {
			fontDescriptor = font.fontDescriptor
		}

		return NSFont(descriptor: fontDescriptor, size: max(4, fontSize))!
	}
}
