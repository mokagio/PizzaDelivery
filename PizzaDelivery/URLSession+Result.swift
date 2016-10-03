import Foundation

typealias HTTPStatusCode = Int

extension URLSession {

  func yow_dataTask(with url: URL, completion: @escaping (Result<(Data, URLResponse), PizzaDeliveryError>) -> ()) -> URLSessionDataTask {
    return dataTask(with: url) { data, response, error in
      switch (data, response, error) {
      case (.some(let data), .some(let response), .none):
        completion(Result(value: (data, response)))
      case (.none, .none, .some(let error)):
        completion(Result(error: .wrapped(error)))
      case (_, _, _):
        completion(Result(error: .networking(.inconsistentResponse)))
      }
    }
  }

  func yow_dataTask(with url: URL, completion: @escaping (Result<(Data, HTTPStatusCode), PizzaDeliveryError>) -> ()) -> URLSessionDataTask {
    return yow_dataTask(with: url) { (result: Result<(Data, URLResponse), PizzaDeliveryError>) -> () in
      completion(
        result.flatMap { (data, response) -> Result<(Data, HTTPStatusCode), PizzaDeliveryError> in
          guard let httpResponse = response as? HTTPURLResponse else {
            return Result(error: .networking(.notHTTPResponse))
          }

          return Result(value: (data, httpResponse.statusCode))
        }
      )
    }
  }

  func yow_dataTask(with url: URL, completion: @escaping (Result<Data, PizzaDeliveryError>) -> ()) -> URLSessionDataTask {
    return yow_dataTask(with: url) { (result: Result<(Data, HTTPStatusCode), PizzaDeliveryError>) -> () in
      completion(
        result.flatMap { (data, statusCode) -> Result<Data, PizzaDeliveryError> in
          if statusCode >= 400 {
            return Result(error: .networking(.httpError(statusCode)))
          } else {
            return Result(value: data)
          }
        }
      )
    }
  }
}
