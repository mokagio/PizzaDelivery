enum PizzaDeliveryError: Error {

  enum NetworkingError: Error {
    case notHTTPResponse
    case httpError(HTTPStatusCode)
    case inconsistentResponse
  }

  enum JSONSerializationError: Error {
    case failed(Error)
    case unexpectedType
  }

  enum JSONParserError: Error {
    case unexpectedJSONType
    case missingKey(String)
    case failedArrayParsing([Error])
  }

  case networking(NetworkingError)
  case jsonDeserialization(JSONSerializationError)
  case parsing(JSONParserError)
  case wrapped(Error)
}
