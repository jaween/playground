const WebSocket = require('ws');

const socket = new WebSocket('ws://localhost:8081');

socket.on('open', function open() {
  socket.send('hello from client');
});

socket.on('message', function incoming(data) {
  console.log(data);
});
