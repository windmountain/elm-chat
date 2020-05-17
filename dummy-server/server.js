// Node.js WebSocket server script
const http = require("http");
const WebSocketServer = require("websocket").server;
const static = require("node-static");
const port = 9898;

const server = http.createServer(function(req, res) {
  file.serve(req, res);
});
server.listen(port);
console.log("server listening on port " + port.toString());

const file = new static.Server("./public");

let messages = [];

const wsServer = new WebSocketServer({
  httpServer: server,
  autoAcceptConnections: false
});

wsServer.on("request", function(request) {
  console.log("incoming request");

  const connection = request.accept(null, request.origin);
  const bodies = [
    "Haha",
    "I'm just sending dummy messages",
    "I'm not really listening"
  ];
  const body = function(bodies) {
    return bodies[Math.floor(Math.random() * bodies.length)];
  };

  const send = function() {
    if (connection.connected) {
      const message = function(date) {
        return JSON.stringify({
          created_at: date.toISOString(),
          body: body(bodies)
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
