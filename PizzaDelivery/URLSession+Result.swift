import Foundation

typealias HTTPStatusCode = Int

extension URLSession {

  func yow_dataTask(with url: URL, completion: @escaping (Result<(Data, URLResponse), NetworkingError>) -> ()) -> URLSessionDataTask {
    return dataTask(with: url) { data, response, error in
      switch (data, response, error) {
      case (.some(let data), .some(let response), .none):
        completion(Result(value: (data, response)))
      case (.none, .none, .some(let error)):
        completion(Result(error: .wrapped(error)))
      case (_, _, _):
        completion(Result(error: .inconsistentResponse))
      }
    }
  }

  func yow_dataTask(with url: URL, completion: @escaping (Result<(Data, HTTPStatusCode), NetworkingError>) -> ()) -> URLSessionDataTask {
    return yow_dataTask(with: url) { (result: Result<(Data, URLResponse), NetworkingError>) -> () in
      completion(
        result.flatMap { data, response in
          guard let httpResponse = response as? HTTPURLResponse else {
            return Result(error: .notHTTPResponse)
          }

          return Result(value: (data, httpResponse.statusCode))
        }
      )
    }
  }

  func yow_dataTask(with url: URL, completion: @escaping (Result<Data, NetworkingError>) -> ()) -> URLSessionDataTask {
    return yow_dataTask(with: url) { (result: Result<(Data, HTTPStatusCode), NetworkingError>) -> () in
      completion(
        result.flatMap { data, statusCode in
          if statusCode >= 400 {
            return Result(error: .httpError(statusCode))
          } else {
            return Result(value: data)
          }
        }
      )
    }
  }
}

enum NetworkingError: Error {
  case notHTTPResponse
  case httpError(HTTPStatusCode)
  case wrapped(Error)
  case inconsistentResponse
}
