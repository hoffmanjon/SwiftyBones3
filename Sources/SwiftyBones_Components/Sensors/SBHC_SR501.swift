//
//  SBHC_SR501.swift
//  SwiftyBones Component Library
//
//  Created by Jon Hoffman on 5/7/16.
//


/**
 This type represents the HC-SR501 motion sensor connected to a Digital GPIO pin.  The HC-SR501 type is a value type
 Initialize:
     let motionSensor = try SBHC_SR501(header: .P9, pin: 11, componentName: "Front Sensor")
 or
     let motionSensor = try SBHC_SR501(gpio: SBDigitalGPIO(id: "gpio30", direction: .IN), componentName: "Front Sensor")
 Methods:
     isMotionDetected() -> Bool?:  Returns true if motion is detected
 */
struct SBHC_SR501: SBComponentInProtocol {
    let componentName: String
    let gpio: SBDigitalGPIO
    
    /**
     Initlizes the SBHC_SR501 type using a SBDigitalGPIO type and a name.
     - Parameter gpio:  An instances of a SBDigitalGPIO type
     - Parameter componentName: A name for this instance that identifies it like "Door Sensor" or "Bedroom Sensor"
     - Throws: ComponentErrors.InvalidGPIOType if the gpio parameter is not an instance of the SBDigitalGPIO type
     */
    init(gpio: GPIO?,componentName: String) throws {
        guard gpio != nil else {
            throw ComponentErrors.GPIOCanNotBeNil
        }
        if let testGpio = gpio as? SBDigitalGPIO {
            self.gpio = testGpio
            self.componentName = componentName
        } else {
            throw ComponentErrors.InvalidGPIOType("/(componentName): Expecting SBDigitalGPIO Type")
        }
    }
    
    /**
     Initlizes the SBHC_SR501 type using the pin defined by the header and pin parameters for the motion sensor.  The component name defines a name for the sensor.
     - Parameter header:  The header of the pin that the sensor is connected too
     - Parameter pin:  The pin that the sensor is connected too
     - Parameter componentName: A name for this instance that identifies it like "Door Sensor" or "Bedroom Sensor"
     - Throws: ComponentErrors.InvalidGPIOType if the gpio parameter is not an instance of the SBDigitalGPIO type
     */
    init(header: BBExpansionHeader, pin: Int, componentName: String) throws {
        if let gpio = SBDigitalGPIO(header: header, pin: pin, direction: .IN) {
            self.gpio = gpio
            self.componentName = componentName
        } else {
            throw ComponentErrors.GPIOCanNotBeNil
        }
    }

    
    
    /**
     The method retrieves the value of the GPIO pin that the button is connected to
     Returns: a 1 for HIGH or a 0 for LOW
     */
    func getRawValue() -> Int? {
        if let value = gpio.getValue() {
            return (value == DigitalGPIOValue.HIGH) ? 1 : 0
        } else {
            return nil
        }
    }
    
    /**
     Determines if motion is presently being detected
     Returns: a true value if motion is being detected
     */
    func isMotionDetected() -> Bool? {
        if let rawValue = getRawValue() {
            return ( rawValue == 0) ? false : true
        } else {
            return nil
        }
    }
}