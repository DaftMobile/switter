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

### Pokemon Index

- `GET /api/pokemon`

_Required authentication: Basic_

Example valid response:
**200**
```json
[
  {
    "color": 8570017,
    "name": "Bulbasaur",
    "number": 1
  },
  {
    "color": 8961217,
    "name": "Ivysaur",
    "number": 2
  }
]
```

### Pokemon GET by Number

- `GET /api/pokemon/:number`

_Required authentication: Basic_

Example valid response (`/api/pokemon/1`):
**200**
```json
{
  "name": "Bulbasaur",
  "number": 1,
  "color": 8570017
}
```

### Pokemon GET by Name

- `GET /api/pokemon/:name`

_Required authentication: Basic_

Example valid response (`/api/pokemon/bulbasaur`):
**200**
```json
{
  "name": "Bulbasaur",
  "number": 1,
  "color": 8570017
}
```

### Pokemon Thumbnail

- `GET /api/pokemon/:number/thumbnail`

_Required authentication: Basic_

Returns a thumbnail png image representing the requested Pokemon (size `124x114 px`)


### Pokemon Image

- `GET /api/pokemon/:number/image`

_Required authentication: Basic_

Returns a full png image representing the requested Pokemon

