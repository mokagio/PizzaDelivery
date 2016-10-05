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
    case missingKey(String)
    case arrayParsingFailed([Error])
    case notJSONDictionary
  }

  enum PizzaServiceError: Error {
    case inconsistentResponse
    case missingContent
  }

  case networking(NetworkingError)
  case jsonDeserialization(JSONSerializationError)
  case jsonParsing(JSONParserError)
  case pizzaService(PizzaServiceError)
  case wrapped(Error)
}
