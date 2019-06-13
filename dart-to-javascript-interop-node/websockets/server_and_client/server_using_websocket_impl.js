const webSocketImpl = require('../websocket_impl');
const WebSocketServer = webSocketImpl.WebSocketServer;

var server = new WebSocketServer(8081, function (socket, client) {
  console.log(`new connection on ${client.address}`);

  socket.listen(function (data) {
    console.log(data);
  });

  socket.send('hello from server');
  socket.close();
});
