import Glibc

var motion = SBDigitalGPIO(id: "gpio60", direction: .IN)
while(true) {
    if let value = motion?.getValue() {
        let status = (value == .HIGH) ? "Motion Detected" : "No Motion"
        print(status)
    }
    usleep(100000)

}