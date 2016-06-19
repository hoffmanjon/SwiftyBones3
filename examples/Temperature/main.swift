import Glibc

if let tmp36 = SBAnalog(id: "AIN1") {
    while(true) {
        if let value = tmp36.getValue() {
            let milliVolts = (Double(value) / 4096.0) * 1800.0
            let celsius = (milliVolts - 500.0) / 10.0
            let fahrenheit = (celsius * 9.0 / 5.0) + 32.0
            
            print("milliVolts:  \(milliVolts)")
            print("celsius:  \(celsius)")
            print("Fahrenheit:  \(fahrenheit)")
            
            usleep(150000)
        }
    }
}

