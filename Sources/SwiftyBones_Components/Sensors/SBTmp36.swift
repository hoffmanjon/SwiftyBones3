//
//  SBTmp36.swift
//  SwiftyBones Component Library
//
//  Created by Jon Hoffman on 5/7/16.
//


/**
 This type represents the TMP36 Temperature Sensor.  The SBTmp36 type is a value type
 Initialize:
     let temperature = try SBTmp36(header: .P9, pin: 40, componentName: "Internal Temp")
 or
     let temperature = try SBTmp36(gpio: SBAnalog(header: .P9, pin: 40), componentName: "Internal Temp")
 Methods:
     getMilliVolts() -> Double?:      Returns the Millivolts registered by the Sensor
     getTempCelsius() -> Double?:     Returns the temperature in Celsius
     getTempFahrenheit() -> Double?:  Returns the temperature in Fahrenheit
 */
struct SBTmp36: SBComponentInProtocol {
    let componentName: String
    let gpio: SBAnalog
    
    /**
     Initlizes the SBTmp36 type using a SBAnalog type and a name.
     - Parameter gpio:  An instances of a SBAnalog type
     - Parameter componentName: A name for this instance that identifies it like "Outside Temperature sensor" or "Robot Internal temp"
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
     Initlizes the SBTmp36 type using the pin defined by the header and pin parameters for the temperature sensor.  The component name defines a name for the sensor.
     - Parameter header:  The header of the pin that the sensor is connected too
     - Parameter pin:  The pin that the sensor is connected too
     - Parameter componentName: A name for this instance that identifies it like "Outside Temperature sensor" or "Robot Internal temp"
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
            return (Double(rawValue) / 4096.0) * 1800.0
        } else {
            return nil
        }
    }
    
    /**
     Calculates the Celsius temperature
     Returns:  The temperature in Celsius
     */
    func getTempCelsius() -> Double? {
        if let milliVolts = getMilliVolts() {
         return (milliVolts - 500.0) / 10.0
        } else {
            return nil
        }
    }
    
    
    /**
     Calculates the Fahrenheit temperature
     Returns:  The temperature in Fahrenheit
     */
    func getTempFahrenheit() -> Double? {
        if let celsius = getTempCelsius() {
            return (celsius * 9.0 / 5.0) + 32.0
        } else {
            return nil
        }
    }

    
}