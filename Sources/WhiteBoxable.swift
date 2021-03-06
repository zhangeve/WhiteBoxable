import Foundation

public protocol WhiteBoxable {
    
    var outputLength: Int { get }
    var name: String { get }
    func value(_ input: UInt8) -> [UInt8]
}

public func cfunc<T: WhiteBoxable>(_ whitebox: T) -> String {
    let name = whitebox.name
    var result = "static void \(name)(uint8_t input, uint8_t* output) {\n"
    result.append("\(cVariable(name:"data", whitebox: whitebox))\n")
    result.append("\tmemcpy(output, data + input * \(whitebox.outputLength), \(whitebox.outputLength));")
    result.append("\n}")
    return result
}

public func cVariable< T: WhiteBoxable>(name n: String? = nil,whitebox: T) -> String {
    let name: String = n == nil ? whitebox.name : n!
    var result = "uint8_t \(name)[]={\n"
    for index in 0...UInt8.max {
        result = result + "/* \(String(format: "0x%02x", index)) */\t"
        let input = index
        let array = whitebox.value(input).map{String(format:"0x%02x", $0)}
        let string = array.reduce("") {
            "\($0)\($1), "
        }
        result = result + string + "\n"
    }
    result = result + "};"
    return result
}

