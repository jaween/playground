const WebSocket = require('ws');

const binding = new WebSocket.Server({ port: 8081 });
console.log('Waiting...');
binding.on('connection', function (socket, request) {
  const address = request.connection.remoteAddress;
  const port = request.connection.remotePort;
  const family = request.connection.remoteFamily;
  console.log(`Bound socket ${address}(${family}):${port}`);
  socket.on('message', message => {
    console.log(`Received mesage => ${message}`);
  });

  socket.send('Yo!');
  setTimeout(function () {
    socket.send('Another message!');
  }, 1000);
});
