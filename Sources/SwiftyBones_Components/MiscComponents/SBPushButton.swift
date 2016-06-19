//
//  SBPushButton.swift
//  SwiftyBones Component Library
//
//  Created by Jon Hoffman on 5/7/16.
//

/**
 This type represents the basic push button connected to a Digital GPIO pin.  The SBButton type is a value type
 Initialize:
      let startButton = try SBButton(header: .P9, pin: 11, componentName: "Start Button")
 or
      let startButton = try SBButton(gpio: SBDigitalGPIO(id: "gpio30", direction: .IN), componentName: "Start Button")
 Methods:
      isButtonPressed() -> Bool?:  Reads the current state of the button.
 */
struct SBButton: SBComponentInProtocol {
    let componentName: String
    let gpio: SBDigitalGPIO
    
    /**
     Initlizes the SBButton type using a SBDigitalGPIO type and a name.
     - Parameter gpio:  An instances of a SBDigitalGPIO type
     - Parameter componentName: A name for this instance that identifies it like "Power on button" or "Horn"
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
     Initlizes the SBButton type using the pin defined by the header and pin parameters for the Button.  The component name defines a name for the Button.
     - Parameter header:  The header of the pin that the Button is connected too
     - Parameter pin:  The pin that the Button is connected too
     - Parameter componentName: A name for this instance that identifies it like "Power on button" or "Horn"
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
     Determines if the button was pressed or not
     Returns: a true value if the button is being pressed or false if it isn't.  Will return nil if there was an error reading the button.
    */
    func isButtonPressed() -> Bool? {
        if let value = getRawValue() {
            return (value == 0) ? false : true
        } else {
            return nil
        }
    }
}