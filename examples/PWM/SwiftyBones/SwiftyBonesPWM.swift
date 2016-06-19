//
//  SwiftyBonesPWM.swift
//
//  Created by Jon Hoffman on 5/1/16.
//


#if arch(arm) && os(Linux)
    import Glibc
#else
    import Darwin
#endif

/**
 Defines a type to will be used to configure the PWM pins
 */
typealias BBPWMOCP = (dir: String, num: Int)

/**
 List of available PWM pins
 */
var PWMPins:[String: BBExpansionPin] = [
    "PWM2B": (header:.P8, pin:13),
    "PWM2A": (header:.P8, pin:19),
    "PWM1A": (header:.P9, pin:14),
    "PWM1B": (header:.P9, pin:16),
    "PWM0B": (header:.P9, pin:21),
    "PWM0A": (header:.P9, pin:22),
    "PWM0": (header:.P9, pin:42)
]

/**
 Information neede to configure the PWM pins
 */
var PWMOCP:[String: BBPWMOCP] = [
    "PWM2B": (dir:"48304000.epwmss/48304200.ehrpwm/pwm/", num:1),
    "PWM2A": (dir:"48304000.epwmss/48304200.ehrpwm/pwm/", num:0),
    "PWM1A": (dir:"48302000.epwmss/48302200.ehrpwm/pwm/", num:0),
    "PWM1B": (dir:"48302000.epwmss/48302200.ehrpwm/pwm/", num:1),
    "PWM0B": (dir:"48300000.epwmss/48300200.ehrpwm/pwm/", num:1),
    "PWM0A": (dir:"48300000.epwmss/48300200.ehrpwm/pwm/", num:0),
    "PWM0": (dir:"48300000.epwmss/48300100.ecap/pwm/", num:0)
]

/**
 Type that represents the Beaglebone Black PWM pins
 */
struct SBPWM: GPIO {
    /**
     Variables and paths needed
     */
    private static let PWM_BASE_OCP_PATH = "/sys/devices/platform/ocp/"
    private static let PWM_OCP_STATE_FILE = "state"
    private static let PWM_STATE = "pwm"
    private static let PWM_PERIOD_FILE_NAME = "period"
    private static let PWM_PERIOD = 10000
    private static let PWM_EXPORT_FILE_NAME = "export"
    private static let PWM_DUTY_CYCLE_FILE_NAME = "duty_cycle"
    private static let PWM_ENABLE_FILE_NAME = "enable"
    
    private var header: BBExpansionHeader
    private var pin: Int
    private var id: String
    
    /**
     Failable initiator which will fail if an invalid ID is entered.  Valid IDs are:
     PWM2B
     PWM2A
     PWM1A
     PWM1B
     PWM0B
     PWM0A
     PWM0
     - Parameter id:  The ID of the pin.  The ID starts with PWM and then the ID for the pin
     */
    init?(id: String) {
        if let val = PWMPins[id] {
            self.id = id
            self.header = val.header
            self.pin = val.pin
            if !isPinActive() {
                if !initPin() {
                    return nil
                }
            }
            
        } else {
            return nil
        }
    }
    
    /**
     Failable initiator which will fail if either the header or pin number is invalid
     Valid header/pin number combonations are:
     header:.P8, pin:13
     header:.P8, pin:19
     header:.P9, pin:14
     header:.P9, pin:16
     header:.P9, pin:21
     header:.P9, pin:22
     header:.P9, pin:42
     - Parameter header:  This is the header which will be either .P8 or .P9
     - pin:  the pin number
     */
    init?(header: BBExpansionHeader, pin: Int) {
        for (key, expansionPin) in PWMPins where expansionPin.header == header && expansionPin.pin == pin {
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
     This method configures the pin for PWM
     - Returns:  true if the pin was successfully configured for PWM
     */
    func initPin() -> Bool {
        _ = writeStringToFile(stringToWrite: SBPWM.PWM_STATE, path: getStatePath())
        if let val = PWMOCP[id], exportPath = getExportPath(), configPath = getConfigPath() {
            let exportSuccess = writeStringToFile(stringToWrite: String(val.num), path: exportPath)
            let periodSuccess = writeStringToFile(stringToWrite:String(SBPWM.PWM_PERIOD), path: configPath + "/" + SBPWM.PWM_PERIOD_FILE_NAME)
            if !exportSuccess || !periodSuccess {
                return false
            } else {
                usleep(1000000)
                return true
            }
        }
        return false
        
    }
    
    /**
     This function checks to see if the pin is configured for PWM
     - Returns: true if the pin is already configured otherwise false
     */
    func isPinActive() -> Bool {
        if let value = readStringFromFile(path: getStatePath()) {
            let retValue = (value == SBPWM.PWM_STATE) ? true : false
            return retValue
        } else {
            return false
        }
    }
    
    /**
     Determines the path to the file that contains the present state information
     - Returns:  Path to file
    */
    private func getStatePath() -> String {
        return SBPWM.PWM_BASE_OCP_PATH + "ocp:" + header.rawValue + "_" + String(pin) + "_pinmux/" + SBPWM.PWM_OCP_STATE_FILE
    }
    
    /**
     Determines the path to the export file
     - Returns:  Path to file
     */
    private func getExportPath() -> String? {
	if let ocpPath = getOcpPath() {
            return ocpPath + "/" + SBPWM.PWM_EXPORT_FILE_NAME
        }
        return nil

    }

    /**
     Determines the path to the OCP directory
     - Returns:  Path to file
     */
    private func getOcpPath() -> String? {
        if let val = PWMOCP[id] {
            let path = SBPWM.PWM_BASE_OCP_PATH + val.dir
            let dir = opendir(path)
            guard dir != nil else {
                return nil
            }
            var num = 0
            while dir != nil {
                if let listing = readdir(dir!) {
                    let file = listing.pointee.d_name 
                    if (file.0 != 46) {
                        num = file.7 - 48
                        break
                    }
		}
            }
            let mDirName = "pwmchip" + String(num)
            return SBPWM.PWM_BASE_OCP_PATH + val.dir + mDirName + "/"
        }
        return nil

    }
    
    /**
     Determines the path to the pins confiuration directory
     - Returns:  Path to file
     */
   private func getConfigPath() -> String? {
        if let val = PWMOCP[id], ocpPath = getOcpPath() {
            let retPath = ocpPath + "pwm" + String(val.num)
	    return retPath
        }
        return nil
    }

    /**
     Sets the duty cycle for the pin.  Don't forget to enable the pin if it is not enabled already
     - Parameter newValue:  The value for the duty cycle.  This can be from 0 -> 10000
     - Returns:  False if there was an issue writing the value
     */
    func setValue(newValue: Int) -> Bool {
        guard newValue <= SBPWM.PWM_PERIOD && newValue >= 0 else {
            return false
        }
        if let configPath = getConfigPath() {
            if !writeStringToFile(stringToWrite: String(newValue), path: configPath + "/" + SBPWM.PWM_DUTY_CYCLE_FILE_NAME) {
                return false
            }
            return true
        }
        return false
    }
    
    /**
     this method enables or disables the pin
     - Parameter enable:  a true value enables the pin and a false disables it
     - Returns:  False if there was an issue writing the value
    */
    func setEnable(enable: Bool) -> Bool {
        let value = (enable) ? "1" : "0"
        if let configPath = getConfigPath() {
            if !writeStringToFile(stringToWrite: value, path: configPath + "/" + SBPWM.PWM_ENABLE_FILE_NAME) {
                return false
            }
            return true
        }
        return false
    }
}

