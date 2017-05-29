
public protocol APIRequestParameter {
    
    func requestParameter() -> Any
}

public struct APIRequestParameterArray: APIRequestParameter {
    
    public var values: [APIRequestParameter] = []
    
    public init(_ values: [APIRequestParameter]) {
        self.values = values
    }
    
    public func requestParameter() -> Any {
        return self.values.map { $0.requestParameter() }
    }
}

public protocol APIRequestParameterNull: APIRequestParameter {
    
    static func nullParameter() -> APIRequestParameterNull
}

extension APIRequestParameterNull {
    
    static func nullParameter() -> Any {
        return Self.nullParameter()
    }
}

public struct APIRequestParameterDictionary<Null: APIRequestParameterNull>: APIRequestParameter {
    
    public enum ReadingNullRule {
        
        case ignoreNull
        
        case respectNull
    }
    
    public var value: [String: APIRequestParameter?]
    
    public let readingOption: ReadingNullRule
    
    public init(_ value: [String: APIRequestParameter?], option: ReadingNullRule = .ignoreNull) {
        self.value = value
        self.readingOption = option
    }
    
    public func requestParameter() -> Any {
        var dictionary: [String: Any] = [:]
        for (k, v) in value {
            switch self.readingOption {
            case .ignoreNull:
                if let parameter = v?.requestParameter() {
                    dictionary[k] = parameter
                }
            case .respectNull:
                dictionary[k] = v?.requestParameter() ?? Null.nullParameter()
            }
        }
        return dictionary as Any
    }
}

extension APIRequestParameterDictionary: ExpressibleByDictionaryLiteral {
    
    public typealias Key = String
    
    public typealias Value = APIRequestParameter?
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(
            elements.reduce([Key: Value](minimumCapacity: elements.count)) { (dictionary: [Key: Value], element:(key: Key, value: Value)) -> [Key: Value] in
                var d = dictionary
                d[element.key] = element.value
                return d
        })
    }
}
