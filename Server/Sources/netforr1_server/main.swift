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
    let hangman: Hangman
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
            self.hangman = Hangman(connection: connection)
            self.mode = .menu
        } catch {
            print(error)
            return nil
        }
    }

    func runMenu()
    {
        do {
            try connection.write(from: "Main menu \n 1: File Server \n 2: Hangman \n")
            guard let command = try connection.readString() else {
                try connection.write(from: "Invalid command")
                return
            }
            switch command {
                case "file":
                    mode = .fileserver
                    try connection.write(from: "Switched to file server")
                case "hangman":
                    mode = .hangman
                    try connection.write(from: "Switched to hangman")
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
        do {
            switch mode {
                case .menu: 
                    runMenu()
                case .fileserver:
                    fileServer.mainLoop()
                case .hangman:
                    try hangman.mainLoop()
                default:
                    break
            }
        } catch {
            print("ERROR")
            print(error)
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

    var word: String
    var guessedPart: String
    var wrongPoints: Int
    let connection: Socket

    init(connection: Socket)
    {
        self.connection = connection
        self.word = ""
        self.guessedPart = ""
        self.wrongPoints = 0
        selectRandomWord()
    }

    func mainLoop() throws
    {
        do {
            guard let char = try connection.readString() else {
                try connection.write(from: "Invalid input")
                return
            }
            print("Recieved char \(char)")
            try guess(char: char)
        } catch {
            try connection.write(from: "Invalid input (2)")

            print("Failed to check input")
            print(error)
        }
    }

    func selectRandomWord()
    {
        do {
            let hangmanWordsData = try Folder(path: "files").files.filter({ $0.name == "hangmanWords" })[0].readAsString()
            let words = hangmanWordsData.components(separatedBy: "\n")
            self.word = words[Int.random(in: 0..<words.count)]
            self.wrongPoints = 0
            self.guessedPart = ""
            self.word.forEach { _ in self.guessedPart += "*" }
        } catch {
            print("Failed to read file")
            print(error)
        }
    }

    func guess(char: String) throws
    {
        guard char.length == 1 else {
            try connection.write(from: "Invalid character")
            return
        }
        print("Length is 1")
        if let index = word.index(of: Character(char)) {
            print("Got index")
            guessedPart.replace(at: Int(word.distance(from: word.startIndex, to: index)), with: char)
            try connection.write(from: "Correct \n \(self.guessedPart)")
            print("Success")
        } else {
            print("Failed to get index")
            self.wrongPoints += 1
            try connection.write(from: "Incorrect, minus points: \(self.wrongPoints) \((self.wrongPoints == 5) ? "Game over" : "")")
        }
    }

}


guard let server = Server() else {
    print("Failed to start server")
    exit(1)
}
while true {
    server.mainLoop()
}
