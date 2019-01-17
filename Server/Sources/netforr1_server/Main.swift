import Foundation
import Socket

var socket = try Socket.create()
try socket.listen(on: 1103)

print("waiting for connection")
let connection = try socket.acceptClientConnection()
                
print("Connected to \(connection.remoteHostname)")

let directory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

let fileHandler = FileHandler(directory: directory)

mainLoop: while true {
    guard let command = try connection.readString() else {
        continue
    }
    
    do {
        switch command {
            case "list files", "lf":
                print("Listing files")

                let fileList = fileHandler.fileList
                try connection.write(from: fileList)
                
            case let cmd where cmd.hasPrefix("download") || cmd.hasPrefix("dl"):
                print("Sending file")

                guard let filenameArgRange = cmd.range(of: " ") else {
                    throw CommandError.argumentError
                }

                let filenameArgStartIndex = cmd.distance(from: cmd.startIndex, to: filenameArgRange.lowerBound)

                let filename = String(cmd[filenameArgRange.lowerBound...])
                guard let fileData = try? fileHandler.fileData(filename: filename)! else {
                    throw CommandError.fileDataFailedToLoad
                }

                try connection.write(from: fileData)

            default:
                print("Invalid command")
        }
    } catch {
        print("Failed to run command")
        print(error)
    }
}