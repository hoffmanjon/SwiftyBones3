//
//  SwiftyBonesDigitalGPIO.swift
//
//  Created by Jon Hoffman on 5/1/16.
//


#if arch(arm) && os(Linux)
    import Glibc
#else
    import Darwin
#endif

/**
 The list of available GPIO.
 */
var DigitalGPIOPins:[String: BBExpansionPin] = [
    "gpio38": (header:.P8, pin:3),
    "gpio39": (header:.P8, pin:4),
    "gpio34": (header:.P8, pin:5),
    "gpio35": (header:.P8, pin:6),
    "gpio66": (header:.P8, pin:7),
    "gpio67": (header:.P8, pin:8),
    "gpio69": (header:.P8, pin:9),
    "gpio68": (header:.P8, pin:10),
    "gpio45": (header:.P8, pin:11),
    "gpio44": (header:.P8, pin:12),
    "gpio23": (header:.P8, pin:13),
    "gpio26": (header:.P8, pin:14),
    "gpio47": (header:.P8, pin:15),
    "gpio46": (header:.P8, pin:16),
    "gpio27": (header:.P8, pin:17),
    "gpio65": (header:.P8, pin:18),
    "gpio22": (header:.P8, pin:19),
    "gpio63": (header:.P8, pin:20),
    "gpio62": (header:.P8, pin:21),
    "gpio37": (header:.P8, pin:22),
    "gpio36": (header:.P8, pin:23),
    "gpio33": (header:.P8, pin:24),
    "gpio32": (header:.P8, pin:25),
    "gpio61": (header:.P8, pin:26),
    "gpio86": (header:.P8, pin:27),
    "gpio88": (header:.P8, pin:28),
    "gpio87": (header:.P8, pin:29),
    "gpio89": (header:.P8, pin:30),
    "gpio10": (header:.P8, pin:31),
    "gpio11": (header:.P8, pin:32),
    "gpio9": (header:.P8, pin:33),
    "gpio81": (header:.P8, pin:34),
    "gpio8": (header:.P8, pin:35),
    "gpio80": (header:.P8, pin:36),
    "gpio78": (header:.P8, pin:37),
    "gpio79": (header:.P8, pin:38),
    "gpio76": (header:.P8, pin:39),
    "gpio77": (header:.P8, pin:40),
    "gpio74": (header:.P8, pin:41),
    "gpio75": (header:.P8, pin:42),
    "gpio72": (header:.P8, pin:43),
    "gpio73": (header:.P8, pin:44),
    "gpio70": (header:.P8, pin:45),
    "gpio71": (header:.P8, pin:46),
    "gpio30": (header:.P9, pin:11),
    "gpio60": (header:.P9, pin:12),
    "gpio31": (header:.P9, pin:13),
    "gpio50": (header:.P9, pin:14),
    "gpio48": (header:.P9, pin:15),
    "gpio51": (header:.P9, pin:16),
    "gpio5": (header:.P9, pin:17),
    "gpio4": (header:.P9, pin:18),
    "gpio3": (header:.P9, pin:21),
    "gpio2": (header:.P9, pin:22),
    "gpio49": (header:.P9, pin:23),
    "gpio15": (header:.P9, pin:24),
    "gpio117": (header:.P9, pin:25),
    "gpio14": (header:.P9, pin:26),
    "gpio115": (header:.P9, pin:27),
    "gpio113": (header:.P9, pin:28),
    "gpio111": (header:.P9, pin:29),
    "gpio112": (header:.P9, pin:30),
    "gpio110": (header:.P9, pin:31),
    "gpio20": (header:.P9, pin:41),
    "gpio7": (header:.P9, pin:42)
]

/**
 Direction that pin can be configured for
 */
enum DigitalGPIODirection: String {
    case IN="in"
    case OUT="out"
}

/**
 The value of the digitial GPIO pins
 */
enum DigitalGPIOValue: String {
    case HIGH="1"
    case LOW="0"
}

/**
 Type that represents a GPIO pin on the Beaglebone Black
 */
struct SBDigitalGPIO: GPIO {
    
    /**
     Variables and paths needed
     */
    private static let GPIO_BASE_PATH = "/sys/class/gpio/"
    private static let GPIO_EXPORT_PATH = GPIO_BASE_PATH + "export"
    private static let GPIO_DIRECTION_FILE = "/direction"
    private static let GPIO_VALUE_FILE = "/value"
    
    private var header: BBExpansionHeader
    private var pin: Int
    private var id: String
    private var direction: DigitalGPIODirection
    
    /**
     Failable initiator which will fail if an invalid ID is entered
     - Parameter id:  The ID of the pin.  The ID starts with gpio and then contains the gpio number
     - Parameter direction:  The direction to configure the pin for
     */
    init?(id: String, direction: DigitalGPIODirection) {
        if let val = DigitalGPIOPins[id] {
            self.id = id
            self.header = val.header
            self.pin = val.pin
            self.direction = direction
            if !initPin() {
                return nil
            }
        } else {
            return nil
        }
    }
    
    /**
     Failable initiator which will fail if either the header or pin number is invalid
     - Parameter header:  This is the header which will be either .P8 or .P9
     - pin:  the pin number
     - Parameter direction:  The direction to configure the pin for
     */
    init?(header: BBExpansionHeader, pin: Int, direction: DigitalGPIODirection) {
        for (key, expansionPin) in DigitalGPIOPins where expansionPin.header == header && expansionPin.pin == pin {
            self.header = header
            self.pin = pin
            self.id = key
            self.direction = direction
            if !initPin() {
                return nil
            }
                return
        }
        return nil

    }
    
    /**
     This method configures the pin for Digital I/O
     - Returns:  true if the pin was successfully configured for digitial I/O
     */
    func initPin() -> Bool {
	let startIndex = id.index(id.startIndex, offsetBy:4)
	let range = startIndex..<id.endIndex
	let gpioId = id[range]
        let gpioSuccess = writeStringToFile(stringToWrite: gpioId, path: SBDigitalGPIO.GPIO_EXPORT_PATH)
        let directionSuccess = writeStringToFile(stringToWrite:direction.rawValue, path: getDirectionPath())
        if !gpioSuccess || !directionSuccess {
            return false
        }
        return true
    }
    
    /**
     This function checks to see if the pin is configured for Digital I/O
     - Returns: true if the pin is already configured otherwise false
     */
    func isPinActive() -> Bool {
        if let _ = getValue() {
            return true
        } else {
            return false
        }
    }

    /**
     Gets the present value from the pin
     - Returns:  returns the value for the pin eith .HIGH or .LOW
     */
    func getValue() -> DigitalGPIOValue? {
        if let valueStr = readStringFromFile(path: getValuePath()) {
            return valueStr == DigitalGPIOValue.HIGH.rawValue ? DigitalGPIOValue.HIGH : DigitalGPIOValue.LOW
        } else {
            return nil
        }
    }
    
    /**
     Sets the value for the pin
     - Parameter value:  The value for the pin either .HIGH or .LOW
    */
    func setValue(value: DigitalGPIOValue) -> Bool {
        return writeStringToFile(stringToWrite: value.rawValue, path: getValuePath())
    }
    
    /**
     Determines the path to the file for this particular digital pin direction file
     - Returns:  Path to file
     */
    private func getDirectionPath() -> String {
        return SBDigitalGPIO.GPIO_BASE_PATH + id + SBDigitalGPIO.GPIO_DIRECTION_FILE
    }
    
    /**
     Determines the path to the file for this particular digital pin
     - Returns:  Path to file
     */
    private func getValuePath() -> String {
        return SBDigitalGPIO.GPIO_BASE_PATH + id + SBDigitalGPIO.GPIO_VALUE_FILE
    }
}

