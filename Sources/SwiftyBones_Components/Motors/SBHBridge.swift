//
//  SBHBridge
//  SwiftyBones Component Library
//
//  Created by Jon Hoffman on 6/4/16.
//


/**
 This type represents a generic H-Bridge.  The SBHBridge type is a value type
 Initialize:
 let rightMotor = try SBHBridge(gpioForward: SBDigitalGPIO(header: .P9, pin: 11,direction: .OUT), gpioReverse: SBDigitalGPIO(header: .P9, pin: 13, direction: .OUT), gpioEnable: SBDigitalGPIO(header: .P9, pin: 15, direction: .OUT), componentName: "Right Track")
 or
 let rightMotor = try gpioForward(forwardHeader: .P9, forwardPin: 11, reverseHeader: .P9, reversePin: 13, enableHeader: .P9, enablePin: 15, componentName: "Right Track")
 methods:
 enableMotor(enable: Int) -> Bool:       Enables or disables the motor (1=enable, 0=disable)
 goForward():                           Turns the motor in the forward direction
 goReverse():                           Turns the motor in the reverse direction
 stop():                                Stops the motor
 */
struct SBHBridge: SBComponentOutProtocol {
    let componentName: String
    let gpioForward: SBDigitalGPIO?
    let gpioReverse: SBDigitalGPIO?
    let gpioEnable: SBDigitalGPIO
    
    /**
     Initlizes the SBHBridge type using three SBDigitalGPIO instances and a name.
     - Parameter gpioForward:  An instances of a SBDigitalGPIO type
     - Parameter gpioReverse:  An instances of a SBDigitalGPIO type
     - Parameter gpioEnable:  An instances of a SBDigitalGPIO type
     - Parameter componentName: A name for this instance that identifies it like "Left Motor" or "Right Motor"
     - Throws: ComponentErrors.InvalidGPIOType if the gpio parameter is not an instance of the SBPWM type
     */
    init(gpioForward: SBDigitalGPIO?,gpioReverse: SBDigitalGPIO?, gpioEnable: SBDigitalGPIO?, componentName: String) throws {
        if let gpioForward = gpioForward, let gpioReverse = gpioReverse, let gpioEnable = gpioEnable {
            self.gpioForward = gpioForward
            self.gpioReverse = gpioReverse
            self.gpioEnable = gpioEnable
            self.componentName = componentName
        } else {
            throw ComponentErrors.InvalidGPIOType("\(componentName): Expecting SBPWM Type")
        }
    }
    
    
    /**
     Initlizes the SBHBridge type using the pins defined by the header and pin parameters for the motor speed.  Each of the connections (reverse, forard and enabled) are defined.  The component name defines a name for the motor.  This initializer sets the directional pin to nil
     - Parameter forwardHeader:  The header of the forward pin
     - Parameter forwardPin:  The pin that the motor is connected to
     - Parameter reverseHeader:  The header of the reverse pin
     - Parameter reversePin:  The pin that the motor is connected to
     - Parameter enableHeader:  The header of the enabled pin
     - Parameter enablePin:  The pin that the motor is connected to
     - Parameter componentName: A name for this instance that identifies it like "Left Motor" or "Right Motor"
     - Throws: ComponentErrors.InvalidGPIOType if the gpio parameter is not an instance of the SBPWM type
     */
    init(forwardHeader: BBExpansionHeader, forwardPin: Int,
         reverseHeader: BBExpansionHeader, reversePin: Int,
         enableHeader: BBExpansionHeader, enablePin: Int,
         componentName: String) throws {
        if let gpioForward = SBDigitalGPIO(header: forwardHeader, pin: forwardPin, direction: .OUT),
            let gpioReverse = SBDigitalGPIO(header: reverseHeader, pin: reversePin, direction: .OUT),
            let gpioEnable = SBDigitalGPIO(header: enableHeader, pin: enablePin, direction: .OUT)
        {
            self.gpioForward = gpioForward
            self.gpioReverse = gpioReverse
            self.gpioEnable = gpioEnable
            self.componentName = componentName
        } else {
            throw ComponentErrors.GPIOCanNotBeNil
        }
    }
    
    
    /**
     Sets the raw value to the enable pin.  The value should be between 0 and 1
     - Parameter value: This is the value to set.  It should be between 0 and 1
     - returns: true if the value was written successfully
     */
    func setRawValue(value: Int) -> Bool {
        guard value >= 0 && value <= 1 else {
            return false
        }
        let newValue = (value == 1) ? DigitalGPIOValue.HIGH : DigitalGPIOValue.LOW
        if !gpioEnable.setValue(value: newValue) {
            return false
        }
        return true
    }
    
    
    /**
     This function will enable or disable the motor.
     - Parameter enable:  A value of true enables the motor and a value of false disables the motor
     - returns: true if the value was writeen successfully
     */
    func enableMotor(enable: Bool) -> Bool {
        let newValue = (enable) ? DigitalGPIOValue.HIGH : DigitalGPIOValue.LOW
        if !gpioEnable.setValue(value: newValue) {
            return false
        }
        return true
    }
    
    /**
     This function will cause the motor to spin in the forward direction
    */
    func goForward() -> Bool {
        if let gpioForward = self.gpioForward, let gpioReverse = self.gpioReverse {
            _ = gpioForward.setValue(value: DigitalGPIOValue.HIGH)
            _ = gpioReverse.setValue(value: DigitalGPIOValue.LOW)
            return true
        }
        return false
    }
    
    /**
     This function will cause the motor to spin in the reverse direction
     */
    func goReverse() -> Bool {
        if let gpioForward = self.gpioForward,let gpioReverse = self.gpioReverse {
            _ = gpioForward.setValue(value: DigitalGPIOValue.LOW)
            _ = gpioReverse.setValue(value: DigitalGPIOValue.HIGH)
            return true
        }
        return false
    }
    
    /**
     This function will cause the motor to stop
     */
    func stop() -> Bool {
        if let gpioForward = self.gpioForward, let gpioReverse = self.gpioReverse {
            _ = gpioForward.setValue(value: DigitalGPIOValue.LOW)
            _ = gpioReverse.setValue(value: DigitalGPIOValue.LOW)
            return true
        }
        return false
    }
    
}
