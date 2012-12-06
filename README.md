# GreyGoo MUD

An asynchronous, MongoDB-backed web MUD with a self-discoverable RESTish API

## Introduction

GreyGoo is a MUD that can be played by anything that speaks HTTP and a simple schema for describing parameters. Even if they don't know what a MUD is.

Here's an example JSON response:

`curl -b cookies -i 'http://localhost:9299/player/player-50c11573b4a3497ea8000008' -H 'Accept: application/json'`

```
{
  "messages": [

  ],
  "name": "New player",
  "id": "player-50c11573b4a3497ea8000008",
  "href": "http://localhost:9299/player/player-50c11573b4a3497ea8000008",
  "current room": "http://localhost:9299/room/room-50c1145fb4a3497ea8000001"
}
```

and example from an OPTIONS request:

`curl -b cookies -i 'http://localhost:9299/room' -H 'Accept: application/json' -X OPTIONS`

```
[
  {
    "href": "/room",
    "method": "POST",
    "description": "Create a new room",
    "parameters": {
      "name": {
        "type": "String",
        "description": "The name of the room to create"
      },
      "description": {
        "type": "String",
        "description": "A description of the room"
      }
    },
    "arity": 0,
    "class_name": "GreyGoo::Room",
    "action": "create"
  }
]
```

## TODO

* Player registration
* Persistent sessions and authentication
* Root options (like a portal thing)
* Combat
* Example agents

