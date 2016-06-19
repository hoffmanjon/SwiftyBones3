#if arch(arm) && os(Linux)
    import Glibc
#else
    import Darwin
#endif

if let motor1 = SBPWM(header: .P8, pin: 13) {
	_ = motor1.setValue(newValue:0)
	_ = motor1.setEnable(enable: true)
	for index in stride(from: 10000, to: 0, by: -1000) {
		print(index)
		_ = motor1.setEnable(enable: false)
		_ = motor1.setValue(newValue: index)
		_ = motor1.setEnable(enable: true)
		usleep(5000000)
	}
	_ = motor1.setEnable(enable: false)
} else {
	print("Error init")
}

