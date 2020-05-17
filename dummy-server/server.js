// Node.js WebSocket server script
const http = require("http");
const handler = require("serve-handler");
const WebSocketServer = require("websocket").server;
const port = 9898;

const server = http.createServer(function(req, res) {
  return handler(req, res, {
    public: "./public"
  });
});
server.listen(port);
console.log("server listening on port " + port.toString());

let messages = [];

const wsServer = new WebSocketServer({
  httpServer: server,
  autoAcceptConnections: false
});

wsServer.on("request", function(request) {
  console.log("incoming request");

  const connection = request.accept(null, request.origin);
  const bodies = [
    "I just send random canned messages.",
    "I send messages at random intervals.",
    "You can message me but I'm not really listening."
  ];
  const pickRandom = function(list) {
    return list[Math.floor(Math.random() * list.length)];
  };
  const send = function(body) {
    if (connection.connected) {
      const message = function(date) {
        return JSON.stringify({
          created_at: date.toISOString(),
          body: body || pickRandom(bodies)
        });
      };
      console.log("Sending message");
      connection.sendUTF(message(new Date()));
    }
  };
  const sendAndDelay = function() {
    setTimeout(function() {
      send();
      sendAndDelay();
    }, Math.random() * 10000);
  };
  send("You are connected to a dummy chat server.");
  sendAndDelay();
  connection.on("message", function(message) {
    console.log("Received Message:", message.utf8Data);
    messages = messages.concat(message);
    connection.sendUTF(
      JSON.stringify({
        created_at: new Date().toISOString(),
        body: message.utf8Data
      })
    );
  });
  connection.on("close", function(reasonCode, description) {
    console.log("Client has disconnected.");
  });
});
