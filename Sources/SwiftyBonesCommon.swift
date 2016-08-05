//
//  SwiftyBonesCommons.swift
//
//  Created by Jon Hoffman on 5/1/16.
//


#if arch(arm) && os(Linux)
    import Glibc
#else
    import Darwin
#endif

/**
 Defines the Beaglebone Expansion headers.  The value can be either P8 or P9
 */
enum BBExpansionHeader: String {
    case P8 = "P8"
    case P9 = "P9"
}

/**
 Defines a type to be used when defining the pins.  
 the first value is the header (P8 or P9) and the second value is the pin number
 */
typealias BBExpansionPin = (header: BBExpansionHeader, pin: Int)

/**
 Protocol that all types designed to access the GPIO pins should conform too
 */
protocol GPIO {
    func initPin() -> Bool
    func isPinActive() -> Bool
}

/**
 Extension to the GPIO Protocol to add common functionality like reading and writing files.
 */
extension GPIO {
    
    /**
     Converts a String to a Byte Array
     - Parameter  string:  The string to Converts
     - Returns: a byte array that represents the string
     */
    func bytesFromString(string: String) -> [UInt8] {
        return Array(string.utf8)
    }
    
    /**
     Converts a Byte Array to a String
     - Parameter bytes:  An UnsafeMutablePointer<UInt8> that points to the byte Array
     - Parameter count:  The number of bytes to convert to the String
     - Returns: A String that represents the byte array
    */
    func stringFromBytes(bytes: UnsafeMutablePointer<UInt8>, count: Int) -> String {
        var retString = ""
        for index in 0..<count {
            if bytes[index] > 47 && bytes[index] < 58 {
                retString += String(Character(UnicodeScalar(bytes[index])))
            }
        }
        return retString
    }
    
    /**
     Reads a String from a file.  
     - Parameter path:  Is the full path to the file.  Note that we cannot use wildcards in the path
     - Returns:  An optional type that will be the string containing the contents of the file or nil
    */
    func readStringFromFile(path: String) -> String? {
        let fp = fopen(path, "r")
        guard fp != nil else {
            return nil
        }
        var oString = ""
        let bufSize = 8
   //     let buffer: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer.alloc(bufSize)
	let buffer = [CChar](repeating: 0, count: bufSize)
        defer {
            fclose(fp)
        }
        
        repeat {
	    let buf = UnsafeMutablePointer<CChar>.allocate(capacity: bufSize)
            //let count: Int = fread(UnsafeMutablePointer(buffer), 1, bufSize, fp)
            let count: Int = fread(buf, 1, bufSize, fp)
            guard ferror(fp) == 0 else {
                break
            }
            if count > 0 {
		buf[count-1] = 0
		oString += String.init(cString: buf) 
            }
        } while feof(fp) == 0
        return oString
    }
    
    /**
     Writes a string to a file
     - Parameter stringToWrite:  The string contains the contents to Writes
     - Parameter path:  The path to the file.  Note that we cannot use wildcards in the path
    */
    func writeStringToFile(stringToWrite: String, path: String) -> Bool {
        let fp = fopen(path, "w")
        if fp == nil {
            return false
        }
        defer {
            fclose(fp)
        }
        let bytes = bytesFromString(string: stringToWrite)
        let count = fwrite(bytes, 1, bytes.count, fp)
        return count == stringToWrite.utf8.count
    }
}

