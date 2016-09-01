![SwiftyBones](https://github.com/hoffmanjon/SwiftyBones/raw/master/images/logo.png)

A Swift3 library for interacting with the GPIO, PWM and Analog pins on the BeagleBone Black. You can find the swift 2 version here <a href=https://github.com/hoffmanjon/SwiftyBones>https://github.com/hoffmanjon/SwiftyBones</a> 

SwiftyBones is used to program <a href="https://github.com/hoffmanjon/SwiftyBones_BuddyBot">BuddyBot</a> which is the first robot programming in the Swift programming language.  Note that BuddyBot has not been updated for Swift3 yet but that is on my list.

## Summary

The idea for SwiftyBones came from the very good <a href="https://github.com/uraimo/SwiftyGPIO">SwiftyGPIO library.</a>  While the SwiftyGPIO library is a very good library for accessing the GPIO pins on the BeagleBone Black (and other boards like the Raspberry PI and C.H.I.P) it currently does not have the ability to access the analog or PWM pins which I need for a number of my projects.  My first thought was to add this functionality to the SwiftyGPIO library however I really wanted to focus on the BeagleBone Black which I use for my projects therefore I decided to write the SwiftyBones library.

SwiftyBones currently supports interacting with the digital GPIO, PWM (PWM2B,PWM2A,PWM1A,PWM1B,PWM0B,PWM0A,PWM0) and analog (AIN0 - AIN6) pins. 

SwiftyBones also has a new component library to make it easy to various components to your project.  Currently there are only six components but hopefully I will be able to add additional ones soon.  You can read about the component library in the <a href="https://github.com/hoffmanjon/SwiftyBones/wiki/SwiftyBones-Component-Library">wiki</a>

## Installation

The following steps will install Swift 3 on a the standard Debian 8.4 image.  NOTE:  This is for the 8/16/2016 build of Swift 3:
```
apt-get install libicu-dev
apt-get install clang-3.6
update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.6 100
update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.6 100

wget http://swift-arm.ddns.net/job/Swift-3.0-ARM-Incremental/105/artifact/swift-3.0-2016-08-16-BBB-ubuntu14.04.tar.gz

mkdir -p /opt/swift/swift-8-16-2016
cd /opt/swift/swift-8-16-2016
mv ~/swift-3.0-2016-08-16-BBB-ubuntu14.04.tar.gz ./
tar xvfz swift-3.0-2016-08-16-BBB-ubuntu14.04.tar.gz

ln -s /opt/swift/swift-8-16-2016/ /opt/swift/swift-current

Add to the end of /etc/profile:
PATH=$PATH:/opt/swift/swift-current/usr/bin/

```

The Package Manager is not available by default with Swift 3 on ARM therefore you will need to download the zip archive for SwiftyBones with the following command:  
```
wget https://github.com/hoffmanjon/SwiftyBones3/archive/master.zip
```

Once the archive is downloaded, you can unzip it using the following command:

```
unzip master.zip
```

Once the archive is unzipped you should see the following four directorie:
-  Sources:  The SwiftyBones source files
-  swiftybuild:  The swiftybuild script to help you compile your Swift projects
-  Examples:  Example projects to help you get started with SwiftyBones
-  Images:  Images needed for this README like the SwiftyBones logo

Lets take a look at what is each of these directories starting with the Sources directory.

###Sources Directory

The Sources directory contains the Swift source files that make up the SwiftyBones library.  Currently there are three files which are:
-  SwiftyBonesCommon.swift:  This file contains common code which is required for interacting with both analog and digital GPIOs.
-  SwiftyBonesDigitalGPIO.swift:  This file contains the necessary types for interacting with the digital GPIO pins on the Beaglebone Black. 
-  SwiftyBonesAnalog.swift:  This file contains the necessary types for interacting with the Analog IN pins on the Beaglebone Black.


To use SwiftyBones in your project you will need to include the SwiftyBonesCommon.swift file in the project.  You will also need to include the file that corresponds to the pins you need.  If your project uses digital GPIO then you will need to also include the SwiftyBonesDigitalGPIO.swift file.  If your project uses analog in (AIN) then you will need to also include the SwiftyBonesAnalog.swift file.  If your project uses both digital GPIO and analog in, you will want to include both of the files.

##swiftybuild Directory

The swiftybuild directory contains a single script file named swiftybuild.sh.  Since SwiftyBones is built in a modular way with multiple files, I realized that it would very quickly become annoying compiling my code like this:

```
swiftc -o myexec main.swift tempSensor.swift SwiftyBones/SwiftyBonesCommon.swift SwiftyBones/SwiftyBonesDigitalGPIO.swift
```
therefore I wrote a script that would search the current directory and all subdirectories for all files that have the .swift extension and then build a swift compiler command that would contain all of the files it found.  The script takes a single optional command line argument that would be the name of the executable file if everything successfully compiled.  You would use this script like this:
```
./swiftybuild.sh  
or
./swiftybuild.sh myexec
```

The output from the first command would be an executable file named _main_ if everything compiled successfully.  The second command would generate an executable named _myexec_ if everything compiled successfully.

##Examples Directory

The example directory contain three sample projects which are:
-  BlinkingLED:  A project that shows how to use SwiftyBonesDigitalGPIO.swift to blink an LED
-  MotionSensor:  A project that shows how to use SwiftyBonesDigitalGPIO.swift and the HC-SR502 sensor to create a motion detector
-  Temperature:  A project that shows how to use SwiftyBonesAnalog.swift and the tmp36 sensor to get the current temperature

Each of these projects contain a Fritzing diagram that shows how to connect the LED or Sensor to the BeagleBone Black and also an image that was exported from Fritzing. To compile the examples simply run swiftybuild.sh in the example's directory. 
Lets look at each of these projects and see how they function.

###BlinkingLED

Lets begin by looking at the Fritzing diagram for this project. </p>
<img src="https://github.com/hoffmanjon/SwiftyBones/raw/master/examples/BlinkingLed/diagrams/led_only.png" width="600"/>

As we can see from the diagram, we have a single LED and a 100 ohm resistor connected to our Beaglebone Black.  Once we have everything connected, we can compile the example code and run it.  The following code listing shows the code in our main.swift file for this example:

```
import Glibc

if let led = SBDigitalGPIO(id: "gpio30", direction: .OUT){
        while(true) {
                if let oldValue = led.getValue() {
                        print("Changing")
                        var newValue = (oldValue == DigitalGPIOValue.HIGH) ? DigitalGPIOValue.LOW : DigitalGPIOValue.HIGH
                        led.setValue(newValue)
                        usleep(150000)
                }
        }
} else {
        print("Error init pin")
}
```
In this example we start off by creating an instance of the _SBDigitalGPIO_ type (value type) using the **SBDigitalGPIO(id:direction:)** initializer.  The ID is a String type that starts with **gpio** (lowercase) followed by the GPIO number.  You can see the digital GPIOs listed on the <a href="http://beagleboard.org/Support/bone101">beagleboard.org</a> site.  
We use the **getValue()** method from the _SBDigitalGPIO_ type to read the value current value of GPIO30.  The method returns either **DigitalGPIOValue.HIGH** or **DigitalGPIOValue.LOW** signifying that the pin is either high or low.  
We then use the ternary operator to reverse the value (if the value is high we set newValue to low and if the value is low we set the newValue to high).  We use the **setValue()** method of the _SBDigitalGPIO_ type to apply the new value.  Finally we use the usleep() method to pause before looping back.  This causes the LED to blink.

###MotionSensor
Now lets look at the motion sensor example. The following is the Fritzing diagram that shows how to connect the HC-SR502 sensor to your Beaglebone black.</p>
<img src="https://github.com/hoffmanjon/SwiftyBones/blob/master/examples/MotionSensor/diagrams/motion_sensor_bb.png" width="600"/>
In this example we connect the center pin to GPIO60 (P9 pin 12).  The following code shows how we read the motion sensor using the _SBDigitalGPIO_ type.

```
import Glibc

var motion = SBDigitalGPIO(id: "gpio60", direction: .IN)
while(true) {
    if let value = motion?.getValue() {
        let status = (value == .HIGH) ? "Motion Detected" : "No Motion"
        print(status)
    }
    usleep(100000)

}
```
This code looks very similar to the the BlinkingLED example that we just showed.  The both use the _SBDigitalGPIO_ type however in this example we only read the digital GPIO pin and never write anything back to it.

###Temperature
Finally, lets see how we would use the analog pins to determine the current temperature.  The following diagram shows how to connect a tmp36 temperature sensor to your Beaglebone Black. </p>
<img src="https://github.com/hoffmanjon/SwiftyBones/blob/master/examples/Temperature/diagrams/temp_sensor_bb.png" width="600"/>
The center pin on the tmp36 sensor is connected to AIN1 (Header: P9, Pin 40).  The following code will use the _SBAnalog_ type to read the tmp36 sensor
```
import Glibc

if let tmp36 = SBAnalog(id: "AIN1") {
    while(true) {
        if let value = tmp36.getValue() {
            let milliVolts = (value / 4096.0) * 1800.0
            let celsius = (milliVolts - 500.0) / 10.0
            let fahrenheit = (celsius * 9.0 / 5.0) + 32.0
            
            print("milliVolts:  \(milliVolts)")
            print("celsius:  \(celsius)")
            print("Fahrenheit:  \(fahrenheit)")
            
            usleep(150000)
        }
    }
}
```
In this code we start off by creating an instance of the _SBAnalog_ type using the **SBAnalog(id:)** initializer.  We could also use the **SBAnalog(header:pin:)** initializer like this:
```
if let tmp36 = SBAnalog(header: .P9, pin: 40) {
	//code
}
```
We then use the **getValue()** method from the _SBAnalog_ type to retrieve the current value of the pin.  The rest of the code is just calculating the temperature.

##Using SwiftyBones
You will need to include the _SwiftyBonesCommon.swift_ file in any project that uses SwiftyBones.  The following sections explain how to access the digital GPIO, analog and PWM pins on the Beaglebone Black.
###Digital GPIO
To access the digital GPIO pins on the Beaglebone Black, you will need to include the _SwiftyBonesDitialGPIO.swift_ file in you project.  The digital GPIO pins can be accessed using the **DigitalGPIO** type in the _SwiftyBonesDigitalGPIO.swift_ file.  The following is an example of how to use the **DigitalGPIO** type
```
import Glibc

if let gpioPin = SBDigitalGPIO(id: "gpio30", direction: .OUT){
    if let value = gpioPin.getValue() {
        print(value)
    }
} else {
        print("Error init pin")
}
```
In the previous example we started off by creating an instance of the **SBDigitalGPIO** type that uses the GPIO_30 pin.  You can see the digital GPIO pins, with the names, listed on the <a href=http://beagleboard.org/Support/bone101>beagleboard.org</a> site.  We could also create the instance of the **SBDigitalGPIO** type by using the **SBDigitalGPIO(header:pin:direction:)** initializer like this:
```
if let led = SBDigitalGPIO(header: .P9, pin: 11, direction: .OUT) {
	//CODE
}
```
Here is the list of valid GPIO pins define within SwiftyBones:
```
    "gpio38": (header:.P8, pin:3),
    "gpio39": (header:.P8, pin:4),
    "gpio34": (header:.P8, pin:5),
    "gpio35": (header:.P8, pin:6),
    "gpio66": (header:.P8, pin:7),
    "gpio67": (header:.P8, pin:8),
    "gpio69": (header:.P8, pin:9),
    "gpio68": (header:.P8, pin:10),
    "gpio45": (header:.P8, pin:11),
    "gpio44": (header:.P8, pin:12),
    "gpio23": (header:.P8, pin:13),
    "gpio26": (header:.P8, pin:14),
    "gpio47": (header:.P8, pin:15),
    "gpio46": (header:.P8, pin:16),
    "gpio27": (header:.P8, pin:17),
    "gpio65": (header:.P8, pin:18),
    "gpio22": (header:.P8, pin:19),
    "gpio63": (header:.P8, pin:20),
    "gpio62": (header:.P8, pin:21),
    "gpio37": (header:.P8, pin:22),
    "gpio36": (header:.P8, pin:23),
    "gpio33": (header:.P8, pin:24),
    "gpio32": (header:.P8, pin:25),
    "gpio61": (header:.P8, pin:26),
    "gpio86": (header:.P8, pin:27),
    "gpio88": (header:.P8, pin:28),
    "gpio87": (header:.P8, pin:29),
    "gpio89": (header:.P8, pin:30),
    "gpio10": (header:.P8, pin:31),
    "gpio11": (header:.P8, pin:32),
    "gpio9": (header:.P8, pin:33),
    "gpio81": (header:.P8, pin:34),
    "gpio8": (header:.P8, pin:35),
    "gpio80": (header:.P8, pin:36),
    "gpio78": (header:.P8, pin:37),
    "gpio79": (header:.P8, pin:38),
    "gpio76": (header:.P8, pin:39),
    "gpio77": (header:.P8, pin:40),
    "gpio74": (header:.P8, pin:41),
    "gpio75": (header:.P8, pin:42),
    "gpio72": (header:.P8, pin:43),
    "gpio73": (header:.P8, pin:44),
    "gpio70": (header:.P8, pin:45),
    "gpio71": (header:.P8, pin:46),
    "gpio30": (header:.P9, pin:11),
    "gpio60": (header:.P9, pin:12),
    "gpio31": (header:.P9, pin:13),
    "gpio50": (header:.P9, pin:14),
    "gpio48": (header:.P9, pin:15),
    "gpio51": (header:.P9, pin:16),
    "gpio5": (header:.P9, pin:17),
    "gpio4": (header:.P9, pin:18),
    "gpio3": (header:.P9, pin:21),
    "gpio2": (header:.P9, pin:22),
    "gpio49": (header:.P9, pin:23),
    "gpio15": (header:.P9, pin:24),
    "gpio117": (header:.P9, pin:25),
    "gpio14": (header:.P9, pin:26),
    "gpio115": (header:.P9, pin:27),
    "gpio113": (header:.P9, pin:28),
    "gpio111": (header:.P9, pin:29),
    "gpio112": (header:.P9, pin:30),
    "gpio110": (header:.P9, pin:31),
    "gpio20": (header:.P9, pin:41),
    "gpio7": (header:.P9, pin:42)
```    
The **direction** parameter defines if we are going to read or write to the pin.  A **.IN** value means we are going to write a value to the GPIO and a **.OUT** value means we are going to read the value.  
We can then use the **getValue()** method to read the value of the GPIO or the **setValue()** method to write the value.  When we read or write the value for the GPIO the value is returned or written using the values defined in the **DigitalGPIOValue** enum which is .HIGH or .LOW.

###Analog IN
Ditital GPIO is very nice for simple on/off type of sensors like reading the status of a button or for turning a LED on or off but what if we have a sensor, like a temperature sensor, that returns a range.  That is where the analog pins come in.  The Analog IN pins will return a range from 0 to 1.8V (1.8 V is the max for the AIN pins) however the range from the pin itself will be from 0 to 4096.  See the Temperature example that comes with SwiftyBones as an example.  
To access the analog pins on the Beaglebone Black we use the **SBAnalog** type from the _SwiftyBonesAnalog.swift_ file.  Below is an example of how to use the **SBAnalog** type.

```
import Glibc

if let analogPin = SBAnalog(id: "AIN1") {
    if let value = analogPin.getValue() {
        let milliVolts = (value / 4096.0) * 1800.0
    }
}
```
In the previous example we started off by creating an instance of the **SBAnalog** type that uses the AIN1 pin.  You can see the Analog IN pins, with the names, listed on the <a href=http://beagleboard.org/Support/bone101>beagleboard.org</a> site.  We could also create the instance of the **SBAnalog** type by using the **SBAnalog(header:pin:)** initialzer like this:
```
if let analogPin = SBAnalog(header: .P9, pin: 40) {
	//CODE
}
```
Here is the list of valid Analog IN pins define within SwiftyBones:
```
    "AIN0": (header:.P9, pin:39),
    "AIN1": (header:.P9, pin:40),
    "AIN2": (header:.P9, pin:37),
    "AIN3": (header:.P9, pin:38),
    "AIN4": (header:.P9, pin:33),
    "AIN5": (header:.P9, pin:36),
    "AIN6": (header:.P9, pin:35)
```
We can then use the **getValue()** method to read the value of the Analog IN pin.

###PWM
You can read about PWM <a href="https://en.wikipedia.org/wiki/Pulse-width_modulation">here</a>.  It will give you a much better explanation then I could.
To access the PWM pins on the Beaglebone Black we use the **SBPWM** type from the _SwiftyBonesPWM.swift_ file.  Below is an example of how to use the **SBPWM** type:
```
import Glibc

if let pwm = SBPWM(header: .P8, pin: 13) {
	pwm.setEnable(false)
	pwm.setValue(5000)
	pwm.setEnable(true)
}
```
In the previous example we started off by creating an instance of the **SBPWM** type that uses the 40th pin on the P9 header.  You can see the PWM pins, with the names, listed on the <a href=http://beagleboard.org/Support/bone101>beagleboard.org</a> site.  We could also create the instance of the **SBPWM** type by using the **SBPWM(id:)** initialzer like this:
```
if let pwm = SBPWM(id:"PWM2B") {
	//CODE
}
```
Here is the list of valid PWM pins define within SwiftyBones:
```
    "PWM2B": (header:.P8, pin:13),
    "PWM2A": (header:.P8, pin:19),
    "PWM1A": (header:.P9, pin:14),
    "PWM1B": (header:.P9, pin:16),
    "PWM0B": (header:.P9, pin:21),
    "PWM0A": (header:.P9, pin:22),
    "PWM0": (header:.P9, pin:42)
```
We use the **setValue()** method to set the duty_cycle for the pin.  The period is defined internally at 10000 which is the max value for the duty_cycle.  We use the **setEnable()** method to enable or disable the pin.

##Swift Powered Robot
You can see the post that describes the first robot written with Swift and SwiftyBones here:  <a href="http://myroboticadventure.blogspot.com/2016/05/the-first-robot-programed-in-swift-with.html">http://myroboticadventure.blogspot.com/2016/05/the-first-robot-programed-in-swift-with.html</a>

##Final Thoughts
SwiftyBones is definitly a work in progress at this time.  I am hopefully I can figure out the PWM ports in the next couple of weeks because once my daughter gets out for summer break she wants to begin working on our robot and I will need the PWM ports for that. Once I get PWM working, I will begin to add other items to this library as well.  I also need to go though and put comments in my code.

Please feel free to leave me any suggestions that you may have and if you would like to contribute code to this project please feel free especially if you know how to get PWM working with the 4.1+ kernels.

Please drop me a note, with a link, if you are using SwiftyBones in one of your projects.  I love hearing about cool projects and I can post a link to your project here.

 
 
