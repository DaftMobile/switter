[![iOS 4 Beginners](https://user-images.githubusercontent.com/1230922/31862042-c045dba0-b737-11e7-98bf-e816ad04ad73.png)](https://github.com/DaftMobile/ios4beginners_2017)

![License: MIT](http://img.shields.io/badge/license-MIT-brightgreen.svg)
![Platform: Vapor](http://img.shields.io/badge/platform-Vapor-brightgreen.svg)
![Swift: 3.1](http://img.shields.io/badge/swift-3.1-brightgreen.svg)

# Switter API

**URL = https://switter.int.daftcode.pl/**

## Authorization

- Basic - `x-device-uuid` header

#### Authorization errors

- Basic - **Error Code 400** - You will receive it when:
  - `x-device-uuid` header is missing

## API

### Hello

- `GET /api/hello`

_Required authentication: None_

Example valid response:
**200**
```
Hello world!
```

### Joke

- `GET /api/joke`

_Required authentication: Basic_

Example valid response:
**200**
```json
{
  "content": "This is a joke"
}
```

