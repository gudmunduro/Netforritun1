
extension String {

    mutating func replace(at: Int, with: String) {
        var chars = Array(self)
        chars[at] = Character(with)
        self = String(chars)
    }

}


func input(_ text: String = "") -> String?
{
    print(text + ": ", separator: "")
    return readLine()
}