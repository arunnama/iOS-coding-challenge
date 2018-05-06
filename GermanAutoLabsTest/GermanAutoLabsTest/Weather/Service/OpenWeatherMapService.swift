//
// Created by Jake Lin on 9/2/15.
// Copyright (c) 2015 Jake Lin. All rights reserved.
//

import Foundation
import CoreLocation

import SwiftyJSON

struct OpenWeatherMapService: WeatherServiceProtocol {
  fileprivate let urlPath = "http://api.openweathermap.org/data/2.5/forecast"


  func retrieveWeatherInfo(_ location: CLLocation, completionHandler: @escaping WeatherCompletionHandler) {
    let sessionConfig = URLSessionConfiguration.default
    let session = URLSession(configuration: sessionConfig)

    guard let url = generateRequestURL(location) else {
      let error = SWError(errorCode: .urlError)
      completionHandler(nil, error)
      return
    }

    print(url)
    let task = session.dataTask(with: url) { (data, response, error) in
      // Check network error
      guard error == nil else {
        let error = SWError(errorCode: .networkRequestFailed)
        completionHandler(nil, error)
        return
      }
      
      // Check JSON serialization error
      guard let data = data else {
        let error = SWError(errorCode: .jsonSerializationFailed)
        completionHandler(nil, error)
        return
      }

      guard let json = try? JSON(data: data) else {
        let error = SWError(errorCode: .jsonParsingFailed)
        completionHandler(nil, error)
        return
      }

      // Get temperature, location and icon and check parsing error
      guard let tempDegrees = json["list"][0]["main"]["temp"].double,
        let country = json["city"]["country"].string,
        let city = json["city"]["name"].string,
        let weatherCondition = json["list"][0]["weather"][0]["id"].int,
        let iconString = json["list"][0]["weather"][0]["icon"].string else {
          let error = SWError(errorCode: .jsonParsingFailed)
          completionHandler(nil, error)
          return
      }

      var weatherBuilder = WeatherBuilder()
      let temperature = Temperature(country: country, openWeatherMapDegrees:tempDegrees)
      weatherBuilder.temperature = temperature.degrees
      weatherBuilder.location = city

      let weatherIcon = WeatherIcon(condition: weatherCondition, iconString: iconString)
      weatherBuilder.iconText = weatherIcon.iconText


      completionHandler(weatherBuilder.build(), nil)
    }

    task.resume()
  }

  fileprivate func generateRequestURL(_ location: CLLocation) -> URL? {
    guard var components = URLComponents(string:urlPath) else {
      return nil
    }
    let appId = "dce815adba127e294e8a173c2168581d"
    let latitude = String(location.coordinate.latitude)
    let longitude = String(location.coordinate.longitude)

    components.queryItems = [URLQueryItem(name:"lat", value:latitude),
                             URLQueryItem(name:"lon", value:longitude),
                             URLQueryItem(name:"appid", value:appId)]

    return components.url
  }
}
