
if let pin1 = SBDigitalGPIO(id: "gpio77", direction: .IN){

	print(pin1.getValue())
} else {
	print("Error init pin")
}

if let apin1 = SBAnalog(id: "AIN1") {
	print(apin1.getValue())
} else {
	print("Error init pin")
}
