import Foundation
import Socket
import Files

enum ServerMode {
    case menu
    case fileserver
    case hangman
}

public class Server {

    let socket: Socket
    let connection: Socket
    let fileServer: FileServer
    var mode: ServerMode

    init?()
    {
        do {
            print("Waiting for connection")
            self.socket = try Socket.create()
            try socket.listen(on: 1103)
            self.connection = try socket.acceptClientConnection()
            print("connected")
            self.fileServer = FileServer(connection: connection)
            self.mode = .menu
        } catch {
            print(error)
            return nil
        }
    }

    func runMenu()
    {
        do {
            try connection.write(from: "Main menu \n")
            try connection.write(from: "1: File Server \n")
            try connection.write(from: "2: Hangman \n")
            guard let command = try connection.readString() else {
                try connection.write(from: "Invalid command")
                return
            }
            switch command {
                case "file":
                    mode = .fileserver
                case "hangman":
                    mode = .hangman
                default:
                    try connection.write(from: "Invalid command \n")
            }
        } catch {
            print("Failed to run menu")
            print(error)
        }
    }

    func mainLoop()
    {
        switch mode {
            case .menu: 
                runMenu()
            case .fileserver:
                fileServer.mainLoop()
            case .hangman:
                break
            default:
                break
        }
    }

}

public class FileServer {

    let directory: URL
    let fileHandler: FileHandler
    let connection: Socket

    init(connection: Socket)
    {
        self.directory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath + "/files/")
        self.fileHandler = FileHandler(directory: self.directory)
        self.connection = connection
    }

    func mainLoop()
    {
        do {
            guard let command = try connection.readString() else {
                try connection.write(from: "Invalid command")
                return
            }
            try runCmd(command: command)
        } catch {
            print("Failed to run command")
            print(error)
        }
    }

    func runCmd(command: String) throws
    {
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
                    return
                }
                let file = fileList[0]

                try connection.write(from: file.read())

            default:
                try connection.write(from: "Invalid command")
                print("Invalid command")
        }
    }
}

public class Hangman {

}


guard let server = Server() else {
    print("Failed to start server")
    exit(1)
}
while true {
    server.mainLoop()
}
