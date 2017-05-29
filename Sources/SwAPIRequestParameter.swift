/**
 *  SwAPIRequestParameter
 *
 *  Copyright (c) 2017 moaible. Licensed under the MIT license, as follows:
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */

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
            elements.reduce([Key: Value](minimumCapacity: elements.count)) {
                (dictionary: [Key: Value], element:(key: Key, value: Value)) -> [Key: Value] in
                var d = dictionary
                d[element.key] = element.value
                return d
        })
    }
}
