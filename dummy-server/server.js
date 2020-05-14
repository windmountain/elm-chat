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

const wsServer = new WebSocketServer({
  httpServer: server,
  autoAcceptConnections: false
});

wsServer.on("request", function(request) {
  console.log("incoming request");

  const connection = request.accept(null, request.origin);
  setInterval(function() {
    if (connection.connected) {
      const message = function(date) {
        return JSON.stringify({
          created_at: date.toISOString(),
          body: "This is a test"
        });
      };
      console.log("Sending message");
      connection.sendUTF(message(new Date()));
    }
  }, 9000);
  connection.on("message", function(message) {
    console.log("Received Message:", message.utf8Data);
    connection.sendUTF("Hi this is WebSocket server!");
  });
  connection.on("close", function(reasonCode, description) {
    console.log("Client has disconnected.");
  });
});
