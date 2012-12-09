# GreyGoo MUD

An asynchronous, MongoDB-backed web MUD with a self-discoverable RESTish API

## Introduction

GreyGoo is a MUD that can be played by anything that speaks HTTP and a simple schema for describing parameters. Even if they don't know what a MUD is.

It's basically a place for robots to hang out

Some of its features include:

* Entities: room, player, object, message
* Dynamic creation of rooms, objects and exits
* HTML and JSON response types
* Asynchronous backend, so actions can have real time delays
* Appropriate use of HTTP verbs and status codes

## Installation

TODO. If you want to try in the meantime, `rackup` might be your best option. See the `Procfile` for an example command.

## Sample JSON responses

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

## INSPIRATION

Borrows heavily from `GitHub`'s API. I've tried to keep the URL structure consistent while not being overly verbose.

The idea of making 'the most accessible game for computer agents' appeals to me. The implementation is very lightweight and asynchronous throughout, so it should scale.

## TODO

I've barely started, so there's still a lot to do:

* Player registration: currently automatic  on going to `enter`
* Persistent sessions and authentication. Currently only uses cookies.
* Root options (like a portal thing)
* Combat. I hae some ideas for this.
* Example agents in various languages. The more the merrier!
* System alerts and notifications.

## AUTHOR

Mike Cartmell <http://www.mikec.me> 2012
