import Foundation

extension JSONSerialization {

  static func yow_jsonObject(with data: Data) -> Result<JSON, JSONSerializationError> {
    do {
      switch try JSONSerialization.jsonObject(with: data, options: []) {
      case let object as JSONObject:
        return Result(value: JSON.object(object))
      case let array as JSONArray:
        return Result(value: JSON.array(array))
      case _:
        return Result(error: .unexpectedType)
      }

    } catch {
      return Result(error: .failed(error))
    }
  }
}

enum JSONSerializationError: Error {
  case failed(Error)
  case unexpectedType
}
