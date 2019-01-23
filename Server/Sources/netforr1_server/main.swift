import Foundation
import Socket
import Files

var socket = try Socket.create()
try socket.listen(on: 1103)

print("waiting for connection")
let connection = try socket.acceptClientConnection()
                
print("Connected to \(connection.remoteHostname)")

let directory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath + "/files/")

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
            case let cmd where cmd.hasPrefix("search"):
                let searchStr = String(cmd[cmd.index(cmd.startIndex, offsetBy: 7)...])
                let fileList = try Folder(path: "files").files.filter({ $0.name.hasPrefix(searchStr) })
                var result = ""
                for file in fileList {
                    result += file.name + "\n"
                }
                try connection.write(from: result)
            case let cmd where cmd.hasPrefix("download") || cmd.hasPrefix("dl"):
                print("Sending file")

                guard let filenameArgRange = cmd.range(of: " ") else {
                    throw CommandError.argumentError
                }

                let filename = String(cmd[cmd.index(cmd.startIndex, offsetBy: 3)...])
                print(filename)
                let fileList = try Folder(path: "files").files.filter({ $0.name == filename })
                guard fileList.count > 0 else {
                    print("File not found")
                    try connection.write(from: "File not found")
                    continue mainLoop
                }
                let file = fileList[0]

                try connection.write(from: file.read())

            default:
                try connection.write(from: "Invalid command")
                print("Invalid command")
        }
    } catch {
        print("Failed to run command")
        print(error)
        continue
    }
}