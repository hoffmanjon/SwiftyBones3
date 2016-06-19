//
//  SBGenericMotor.swift
//  SwiftyBones Component Library
//
//  Created by Jon Hoffman on 5/7/16.
//


/**
 This type represents a generic motor connected to a PWM port.  The SBGenericMotor type is a value type
 Initialize:
     let rightMotor = try SBGenericMotor(gpio: SBPWM(header: .P8, pin: 13), componentName: "Right Track")
 or
     let rightMotor = try SBGenericMotor(gpio: SBPWM(header: .P8, pin: 13),directionalGpio: SBDigitalGPIO(id: "gpio30", direction: .OUT), componentName: "Right Track")
 or
     let rightMotor = try SBGenericMotor(headerSpeed: .P8, pinSpeed: 13, componentName: "Right Track")
 or
     let rightMotor = try SBGenericMotor(headerSpeed: .P8, pinSpeed: 13, headerDirection: .P8, pinDirection: 14, componentName: "Right Track")
 methods:
     setSpeed(value: Int) -> Bool:           Sets the speed of the moter from 0 to 100 percent
     enableMotor(enable: Bool) -> Bool:      Enables or disables the motor
     func setDirection(value: Int) -> Bool:  Sets the direction of the motor for motor controllers that have that option
 */
struct SBGenericMotor: SBComponentOutProtocol {
    let componentName: String
    let gpio: SBPWM
    let directionalGpio: SBDigitalGPIO?
    
    /**
     Initlizes the SBGenericMotor type using a SBPWM type for the motor speed and a name.  This initializer sets the directional pin to nil
     - Parameter gpio:  An instances of a SBPWM type
     - Parameter componentName: A name for this instance that identifies it like "Left Motor" or "Right Motor"
     - Throws: ComponentErrors.InvalidGPIOType if the gpio parameter is not an instance of the SBPWM type
     */
    init(gpio: GPIO?,componentName: String) throws {
        guard gpio != nil else {
            throw ComponentErrors.GPIOCanNotBeNil
        }
        if let testGpio = gpio as? SBPWM {
            self.gpio = testGpio
            self.componentName = componentName
            self.directionalGpio = nil
        } else {
            throw ComponentErrors.InvalidGPIOType("\(componentName): Expecting SBPWM Type")
        }
    }
    
    /**
     Initlizes the SBGenericMotor type using a SBPWM type for the motor speed and a SBDigitalGPIO type for the direction of the motor and a name.
     - Parameter gpio:  An instances of a SBPWM type
     - Parameter componentName: A name for this instance that identifies it like "Left Motor" or "Right Motor"
     - Throws: ComponentErrors.InvalidGPIOType if the gpio parameter is not an instance of the SBPWM type
     */
    init(gpio: GPIO?, directionalGPIO: GPIO?,componentName: String) throws {
        guard gpio != nil && directionalGPIO != nil else {
            throw ComponentErrors.GPIOCanNotBeNil
        }
        if let testGpio = gpio as? SBPWM, testDirectionalGPIO = directionalGPIO as? SBDigitalGPIO {
            self.gpio = testGpio
            self.componentName = componentName
            self.directionalGpio = testDirectionalGPIO
        } else {
            throw ComponentErrors.InvalidGPIOType("\(componentName): Expecting SBPWM Type")
        }
    }
    
    /**
     Initlizes the SBGenericMotor type using the pin defined by the header and pin parameters for the motor speed.  The component name defines a name for the motor.  This initializer sets the directional pin to nil
     - Parameter header:  The header of the pin that the motor is connected too
     - Parameter pin:  The pin that the motor is connected too
     - Parameter componentName: A name for this instance that identifies it like "Left Motor" or "Right Motor"
     - Throws: ComponentErrors.InvalidGPIOType if the gpio parameter is not an instance of the SBPWM type
     */
    init(header: BBExpansionHeader, pin: Int, componentName: String) throws {
        if let gpio = SBPWM(header: header, pin: pin) {
            self.gpio = gpio
            self.componentName = componentName
            self.directionalGpio = nil
        } else {
            throw ComponentErrors.GPIOCanNotBeNil
        }
    }
    
    /**
     Initlizes the SBGenericMotor type using pin defined by the headerSpeed and pinSpeed parameters for the motor speed and the pins defined by the headerDirection and pinDirection for the directional pin.  The component name defines a name for the motor.  This initializer sets the directional pin to nil
     - Parameter headerSpeed:  The header of the pin that the motor is connected too
     - Parameter pinSpeed:  The pin that the motor is connected too
     - Parameter headerDirection:  The header of the pin that the directional pin for the motor is connected to
     - Parameter pinDirection:  The pin that the directional pin is connected too
     - Parameter componentName: A name for this instance that identifies it like "Left Motor" or "Right Motor"
     - Throws: ComponentErrors.InvalidGPIOType if the gpio parameter is not an instance of the SBPWM type
     */
    init(headerSpeed: BBExpansionHeader, pinSpeed: Int, headerDirection: BBExpansionHeader, pinDirection: Int, componentName: String) throws {
        if let gpio = SBPWM(header: headerSpeed, pin: pinSpeed), direction = SBDigitalGPIO(header: headerDirection, pin: pinDirection, direction: .OUT) {
            self.gpio = gpio
            self.componentName = componentName
            self.directionalGpio = direction
        } else {
            throw ComponentErrors.GPIOCanNotBeNil
        }
    }

    
    /**
     Sets the raw value to the PWM pin.  The value should be between 0 and 100 where 100 is full speed and 0 is stop
     - Parameter value: This is the value to set.  It should be between 0 and 100
     - returns: true if the value was written successfully
     */
    func setRawValue(value: Int) -> Bool {
        guard value >= 0 && value <= 100 else {
            return false
        }
        if enableMotor(enable: false) {
            let newValue = value * 100  //the period is 10000 therefore the duty_cycle actually ranges from 0 to 10000
            if !gpio.setValue(newValue: newValue) {
             return false
            }
            if enableMotor(enable: true) {
                return true
            }
        }
        return false
    }
    
    /**
     This function will set the speed of the motor.  The value should be between 0 and 100 where 100 is full speed and 0 is stop
     - Parameter value: This is the value to set.  It should be between 0 and 100
     - returns: true if the value was written successfully
    */
    func setSpeed(value: Int) -> Bool {
        return setRawValue(value: value)
    }
    
    /**
    This function will enable or disable the motor.
     - Parameter enable:  A value of true enables the motor and a value of false disables the motor
     - returns: true if the value was writeen successfully
    */
    func enableMotor(enable: Bool) -> Bool {
        if !gpio.setEnable(enable: enable) {
            return false
        }
        return true
    }
    
    /**
     This function will set the directional pin.
     - Parameter value: This is the value to set for the directional pin.  The value can be either 0 or 1
     - returns: true if the value was writeen successfully
    */
    func setDirection(value: Int) -> Bool {
        guard directionalGpio != nil else {
             return false
        }
        guard value >= 0 && value <= 1 else {
            return false
        }
        let newValue = (value == 1) ? DigitalGPIOValue.HIGH : DigitalGPIOValue.LOW
        if  enableMotor(enable: false) {
            let changeDirection = directionalGpio!.setValue(value: newValue)
            let eMotor = enableMotor(enable: true)
            if (changeDirection && eMotor) {
                return true
            }
        }
        return false
        
    
    }
    
}
