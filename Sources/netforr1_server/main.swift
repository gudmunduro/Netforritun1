import Foundation
import Socket

var socket = try Socket.create()
try socket.listen(on: 1103)

print("waiting for connection")
let connection = try socket.acceptClientConnection()
                
print("Accepted connection from: \(connection.remoteHostname) on port \(connection.remotePort)")
print("Socket Signature: \(String(describing: connection.signature?.description))")

while true {
    print("filename: ", separator: "")
    guard let filename = readLine() else {
        print("Invalid filename")
        continue
    }
    
    let fileDirectory = (filename.hasPrefix("/")) ? URL(string: "file:///") : URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let fileLocation = URL(fileURLWithPath: filename, relativeTo: fileDirectory)
    
    guard let fileData = try? Data(contentsOf: fileLocation) else {
        print("Failed to read file!")
        continue
    }

    do {
        try connection.write(from: "sending")
        try connection.write(from: fileData)
    } catch {
        print("Failed to send")
        print(error)
    }
}