//
//  SBLed.swift
//  SwiftyBones Component Library
//
//  Created by Jon Hoffman on 5/7/16.
//

/**
 This type represents a LED connected to a Digital GPIO port.  The SBLed type is a value type.
 Initialize:
      let runningLed = try SBLed(header: .P9, pin: 11, componentName: "Running LED")
 or
      let runningLed = try SBLed(gpio: SBDigitalGPIO(id: "gpio30", direction: .OUT), componentName: "Running LED")
 Methods:
      turnLedOn() -> Bool:   Turns the LED on
      turnLedOff() -> Bool:  Turns the LED off
 */
struct SBLed: SBComponentOutProtocol {
    let componentName: String
    let gpio: SBDigitalGPIO
    
    /**
     Initlizes the SBLed type using a SBDigitalGPIO type and a name.
     - Parameter gpio:  An instances of a SBDigitalGPIO type
     - Parameter componentName: A name for this instance that identifies it like "Power on led" or "Error led"
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
            throw ComponentErrors.InvalidGPIOType("\(componentName): Expecting SBDigitalGPIO Type")
        }
    }
    
    /**
     Initlizes the SBLed type using the pin defined by the header and pin parameters for the LED.  The component name defines a name for the LED.
     - Parameter header:  The header of the pin that the LED is connected too
     - Parameter pin:  The pin that the LED is connected too
     - Parameter componentName: A name for this instance that identifies it like "Power on led" or "Error led"
     - Throws: ComponentErrors.InvalidGPIOType if the gpio parameter is not an instance of the SBDigitalGPIO type
     */
    init(header: BBExpansionHeader, pin: Int, componentName: String) throws {
        if let gpio = SBDigitalGPIO(header: header, pin: pin, direction: .OUT) {
            self.gpio = gpio
            self.componentName = componentName
        } else {
            throw ComponentErrors.GPIOCanNotBeNil
        }
    }

    
    /**
     Sets the raw value to the GPIO pin. 
     - Parameter value: This is the value to set.  It can be either 0 or 1
     - Returns: true if the value was successfully written
    */
    func setRawValue(value: Int) -> Bool {
        guard value >= 0 && value <= 1 else {
            return false
        }
        let newValue = (value == 1) ? DigitalGPIOValue.HIGH : DigitalGPIOValue.LOW
        if !gpio.setValue(value: newValue) {
            return false
        }
        return true
    }
    
    /**
     Turns the LED on by setting the GPIO pin high
     - Returns: true if the value was successfully written
     */
    func turnLedOn() -> Bool {
        return setRawValue(value: 1)
    }
    
    /**
     Turns the LED off by setting the GPIO pin low
     - Returns: true if the value was successfully written
     */
    func turnLedOff() -> Bool {
         return setRawValue(value: 0)
    }
}
