import "./main.css";
import { Elm } from "./Main.elm";
import * as serviceWorker from "./serviceWorker";

const app = Elm.Main.init({
  node: document.getElementById("root")
});

const socket = new WebSocket("ws://localhost:9898");

window.app = app;
app.ports.sendMessage.subscribe(function(message) {
  console.log("sending: ", message);
  socket.send(message);
});

socket.addEventListener("message", function(event) {
  console.log("receiving", event.data);
  app.ports.messageReceiver.send(JSON.parse(event.data));
});

app.ports.sendScrollCommand.subscribe(function(command) {
  const el = document.getElementById("scrollable-1");
  el.scrollTop = el.scrollTopMax;
});

setInterval(function() {
  const el = document.getElementById("scrollable-1");
  app.ports.scrollbottomReceiver.send({
    yowza: el.scrollTopMax - el.scrollTop
  });
}, 100);

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
