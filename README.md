# Elm Chat

A Slack-like web UI for chat.

## Details

Apart from becoming a serviceable chat application of some kind, another goal of this project is to see how much fussing it really takes to do the finicky JS/CSS bits correctly in Elm and Elm-UI. Examples:

* New messages arrive at bottom of scrollable feed. Scrolling up allows the user to read past messages at their own pace. Scrolling to the bottom resumes new messages pushing up the others.

* `[Enter]` key to send a message, `[Shift + Enter]` to make a line break in the draft message.

One other interesting thing to note is that the Elm community is deferring a WebSocket effect manager. The standard way to connect to a WebSocket is through Elm's ports system, which is what has been done here. Illustrated:

```
+---------+                  +--------------------+               +-------------+
| ELM APP | <-> ELM PORTS -> | JS INIT/WS WRAPPER | <-> WS:// <-> | CHAT SERVER |
+---------+                  *--------------------+               +-------------+
```

## Dummy chat server

There's a dummy chat server in /dummy-server. `cd dummy-server && npm install && npm start` to get it going.

## Practical README stuff

Elm Chat is an application bootstrapped with [Create Elm App](https://github.com/halfzebra/create-elm-app).

The [guide](https://github.com/halfzebra/create-elm-app/blob/master/template/README.md) for Create Elm App is fantastic. Refer to it for instructions on building, running tests, development environment how-tos, PWA stuff, and deployment.
