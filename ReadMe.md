<div align="center">
<img src="https://user-images.githubusercontent.com/5374404/32806538-c17c139a-c984-11e7-97d0-89d7ee541b17.png" height="200" width="200"/>   
<h1>Swift-Weather</h1>
<h3>An iOS weather app built in Swift.</h3>
</div>
<div align="center">

<img src="https://img.shields.io/badge/OS-iOS%2011-brightgreen.svg">
<img src="https://img.shields.io/badge/language-Swift%204-brightgreen.svg">
<img src="https://img.shields.io/github/license/jsh8w/Swift-Weather.svg?style=flat">

</div>

<br>
## Introduction
Swift-Weather is an iOS weather app powered by [Dark Sky](https://darksky.net/dev). The app provides current conditions, minute-by-minute rainfall predictions for the next hour and hour-by-hour forecasts for the next week. Originally written in Swift 2, the project has been updated for Swift 4.

## Screenshots
<br>

![Weather-Screenshots-1](https://user-images.githubusercontent.com/5374404/32807429-b3cae278-c987-11e7-8a5e-163fc732ab54.png)

![Weather-Screenshots-2](https://user-images.githubusercontent.com/5374404/32808163-0aaaf9dc-c98a-11e7-8a9d-a13e455d1886.png)


## Features

* Dark Sky API integration.
* Google Places Autocomplete API integration.
* JSON Parsing.
* Custom UI Drawing and Animations.
* Today Extension (Notification Center Widget).
* Embedded Framework usage for code shared between app and widget.
* Core Data.
* Core Location.
* Unit Tests.
* [FontAwesome](http://fontawesome.io) and [Weather Icons](http://erikflowers.github.io/weather-icons/) usage.

## Requirements
* iOS 10+
* Xcode 9
* Swift 4

## Project Setup

1. Clone this repository.

```
$ git clone https://github.com/jsh8w/Swift-Weather.git
```

2. The project contains a `podfile` listing the Pods used in the app. Simply  navigate to the project directory and run the following from Terminal:

```bash
$ pod install
```

3. Open **Weather.xcworkspace**
4. Head to [Dark Sky](https://darksky.net/dev), sign-up and get an API key.
5. Head to the [Google Places API](https://developers.google.com/places/ios-api/), sign-up and get an API key.
6. Open **Constants.swift** under **WeatherKit** replace the strings with your API keys.

```
public static let darkSkyAPIKey = "ENTER_YOUR_DARK_SKY_KEY"
public static let googleAPIKey = "ENTER_YOUR_GOOGLE_PLACES_KEY"
```

7. Build the project and either run in a simulator or device.

## Developer Notes

This project is an old app that used to be on the App Store. I have decided to make it open-source. The majority of custom views are drawn out and manipulated programmatically - this has made certain logic long and complex. In hindsight, it would have been better to have further utilised storyboards and xibs to handle this custom view drawing. This is a potential improvement to the project.

Have any suggestions for improvements to the app? Please create an issue or pull request.

## License
This project is licensed under the MIT License, see the [License.md](https://opensource.org/licenses/MIT) for more details.

## Acknowledgements
* The app's weather data is provided by [Dark Sky](https://darksky.net/dev).
* The weather icons are provided by [Weather Icons](http://erikflowers.github.io/weather-icons/).
* The location autocomplete data is provided by [Google Places](https://developers.google.com/places/ios-api/).
