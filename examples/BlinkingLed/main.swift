import Glibc

if let led = SBDigitalGPIO(id: "gpio30", direction: .OUT){
        while(true) {
                if let oldValue = led.getValue() {
                        print("Changing")
                        var newValue = (oldValue == DigitalGPIOValue.HIGH) ? DigitalGPIOValue.LOW : DigitalGPIOValue.HIGH
                        _ = led.setValue(value:newValue)
                        usleep(150000)
                }
        }
} else {
        print("Error init pin")
}
