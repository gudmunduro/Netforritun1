import Foundation
import Socket
import Files

public class FileHandler {

    let directory: URL

    var fileList: String {
        get {
            var result = ""

            do {
                for file in try Folder(path: "./files/").files {
                    print(file.name)
                    result += file.name + "\r\n"
                }
            }
            catch {
                print("Failed to list files!")
                print(error)
            }
            /*let enumerator = FileManager.default.enumerator(atPath: directory.absoluteString + "/files")
            print(directory.absoluteString)
            print(enumerator!)
            let filePaths = enumerator?.allObjects as! [String]

            print(filePaths)

            for filePath in filePaths {
                result += filePath + "\r\n"
            }*/
            return result
        }
    }

    init(directory: URL)
    {
        self.directory = directory
    }

    func fileData(filename: String) throws -> Data? {
        let fileLocation = URL(fileURLWithPath: filename, relativeTo: directory)
        return try? Data(contentsOf: fileLocation)
    }

}