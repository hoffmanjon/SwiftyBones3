//
//  SwiftyBonesAnalog.swift
//
//  Created by Jon Hoffman on 5/1/16.
//

#if arch(arm) && os(Linux)
    import Glibc
#else
    import Darwin
#endif

/**
 This is the list of analog pins that we can use
 */
var AnalogPins:[String: BBExpansionPin] = [
    "AIN0": (header:.P9, pin:39),
    "AIN1": (header:.P9, pin:40),
    "AIN2": (header:.P9, pin:37),
    "AIN3": (header:.P9, pin:38),
    "AIN4": (header:.P9, pin:33),
    "AIN5": (header:.P9, pin:36),
    "AIN6": (header:.P9, pin:35)
]

/**
 We would use the SBAnalog type to access the analog pins on the BeagleBone Black
 */
struct SBAnalog: GPIO {
    
    /**
     Variables and paths needed
    */
    private static let ANALOG_BASE_PATH = "/sys/bus/iio/devices/iio:device0/"
    private static let ANALOG_VALUE_FILE_START = "/in_voltage"
    private static let ANALOG_VALUE_FILE_END = "_raw"
    private static let SLOTS_PATH = "/sys/devices/platform/bone_capemgr/slots"
    private static let ENABLE_ANALOG_IN_SLOTS = "BB-ADC"
    
    private var header: BBExpansionHeader
    private var pin: Int
    private var id: String
    
    /**
     Failable initiator which will fail if an invalid ID is entered
     - Parameter id:  The ID of the pin.  The ID starts with AIN and then contains a number 0 -> 7
    */
    init?(id: String) {
        if let val = AnalogPins[id] {
            self.id = id
            self.header = val.header
            self.pin = val.pin
            if !isPinActive() {
                _ = initPin()
            }

        } else {
            return nil
        }
    }
    
    /**
     Failable initiator which will fail if either the header or pin number is invalid
     - Parameter header:  This is the header which will be either .P8 or .P9
     - Parameter pin:  the pin number
     */
    init?(header: BBExpansionHeader, pin: Int) {
        for (key, expansionPin) in AnalogPins where expansionPin.header == header && expansionPin.pin == pin {
            self.header = header
            self.pin = pin
            self.id = key
            if !isPinActive() {
                if !initPin() {
                    return nil
                }
            }
            return
        }
        return nil
        
    }
    
    /**
     This method configures the pin for Analog IN
     - Returns:  true if the pin was successfully configured for analog in
    */
    func initPin() -> Bool {
        if !writeStringToFile(stringToWrite: SBAnalog.ENABLE_ANALOG_IN_SLOTS, path: SBAnalog.SLOTS_PATH) {
            return false
        }
        usleep(1000000)
        return true
    }
    
    /**
     This function checks to see if the pin is configured for Analog IN
     - Returns: true if the pin is already configured otherwise false
    */
    func isPinActive() -> Bool {
        if let _ = readStringFromFile(path: getValuePath()) {
            return true
        } else {
            return false
        }
    }
    
    /**
     Gets the present value from the pin
     - Returns:  returns the value for the pin
    */
    func getValue() -> Int? {
        if let value = readStringFromFile(path: getValuePath()), let intValue = Int(value) {
            return intValue
        }
        return nil
    }
    
    /**
     Determines the path to the file for this particular analog pin
     - Returns:  Path to file
    */
    private func getValuePath() -> String {
        return SBAnalog.ANALOG_BASE_PATH + SBAnalog.ANALOG_VALUE_FILE_START + getPinNumber() + SBAnalog.ANALOG_VALUE_FILE_END
    }
    
    /**
     Gets the Analog pin number (0 -> 6) from the ID
     - Returns: the analog pin number (0 -> 6)
    */
    private func getPinNumber() -> String {
    //    let range = id.startIndex.advancedBy(3)..<id.endIndex.advancedBy(0)
	let startIndex = id.index(id.startIndex, offsetBy: 3)
	let range = startIndex..<id.endIndex
        return id[range]
    }
    
}

