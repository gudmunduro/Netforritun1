import Foundation
import Socket

public class FileHandler {

    let directory: URL

    var fileList: String {
        get {
            var result = ""

            let enumerator = FileManager.default.enumerator(atPath: directory.absoluteString)
            let filePaths = enumerator?.allObjects as! [String]

            for filePath in filePaths {
                result += filePath + "\r\n"
            }
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