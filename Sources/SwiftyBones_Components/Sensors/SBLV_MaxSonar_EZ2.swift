//
//  SBLV_MaxSonar_EZ2.swift
//  SwiftyBones Component Library
//
//  Created by Jon Hoffman on 5/7/16.
//


/**
 This type represents the LV-MaxSonar-EZ2 Range Finder Sensor. The SBLV_MaxSonar_EZ2 type is a value type
 Initialize:
     let forwardRangeFinder = try SBLV_MaxSonar_EZ2(header: .P9, pin: 40, componentName: "Forward Range Finder")
 or
     let forwardRangeFinder = try SBLV_MaxSonar_EZ2(gpio: SBAnalog(header: .P9, pin: 40), componentName: "Forward Range Finder")
 Methods:
     getMilliVolts() -> Double?:  Returns the Millivolts registered by the Sensor
     getRange() -> Double?     :  Returns the inches to the nearest obstacle detected by the sensor
 */
struct SBLV_MaxSonar_EZ2: SBComponentInProtocol {
    let componentName: String
    let gpio: SBAnalog
    
    /**
     Initlizes the SBLV_MaxSonar_EZ2 type using a SBAnalog type and a name.
     - Parameter gpio:  An instances of a SBAnalog type
     - Parameter componentName: A name for this instance that identifies it like "Center Range" or "Forward Range"
     - Throws: ComponentErrors.InvalidGPIOType if the gpio parameter is not an instance of the SBAnalog type
     */
    init(gpio: GPIO?,componentName: String) throws {
        guard gpio != nil else {
            throw ComponentErrors.GPIOCanNotBeNil
        }
        if let testGpio = gpio as? SBAnalog {
            self.gpio = testGpio
            self.componentName = componentName
        } else {
            throw ComponentErrors.InvalidGPIOType("/(componentName): Expecting SBAnalog Type")
        }
    }
    
    /**
     Initlizes the SBLV_MaxSonar_EZ2 type using the pin defined by the header and pin parameters for the range finder sensor.  The component name defines a name for the sensor.
     - Parameter header:  The header of the pin that the sensor is connected too
     - Parameter pin:  The pin that the sensor is connected too
     - Parameter componentName: A name for this instance that identifies it ike "Center Range" or "Forward Range"
     - Throws: ComponentErrors.InvalidGPIOType if the gpio parameter is not an instance of the SBAnalog type
     */
    init(header: BBExpansionHeader, pin: Int, componentName: String) throws {
        if let gpio = SBAnalog(header: header, pin: pin) {
            self.gpio = gpio
            self.componentName = componentName
        } else {
            throw ComponentErrors.GPIOCanNotBeNil
        }
    }
    
    /**
     The method retrieves the value of the analog pin that the sensor is connected too
     Returns: The raw value of the pin
     */
    func getRawValue() -> Int? {
        if let value = gpio.getValue() {
            return value
        } else {
            return nil
        }
    }
    
    /**
     Calculates the Millivolts from the Analog pin
     Returns:  The Millivolts on the Analog pin
     */
    func getMilliVolts() -> Double? {
        if let rawValue = getRawValue() {
            return (Double(rawValue) / 4096.0) * 1.800
        } else {
            return nil
        }
    }
    
    /**
     Calculates the range to the nearset object
     Returns:  The range in inches
     */
    func getRange() -> Double? {
        if let milliVolts = getMilliVolts() {
            return milliVolts/0.002148
        } else {
            return nil
        }
    }
    
}
