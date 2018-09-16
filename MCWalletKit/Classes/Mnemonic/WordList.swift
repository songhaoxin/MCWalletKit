public enum WordList {
    case english
    case chinese
    case japanese
    
    public var words: [String] {
        switch self {
        case .english:
            return englishWords
        case .chinese:
            return chineseWords
        case .japanese:
            return japaneseWords
        }
    }
}
