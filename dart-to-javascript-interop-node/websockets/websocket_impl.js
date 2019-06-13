const IsoWebSocket = require('isomorphic-ws');

class WebSocketServer {
  constructor(port, onConnection) {
    this.binding = new IsoWebSocket.Server({ port: port });
    this.binding.on('connection', function (socket, request) {
      onConnection(
        new WebSocket(socket),
        {
          'address': request.connection.remoteAddress,
          'port': request.connection.remotePort,
        }
      );
    });
  }

  close() {
    this.binding.close();
  }
}

class WebSocketClient {
  constructor(host, port, onConnected) {
    this.socket = new WebSocket(`ws://${host}:${port}`);
    this.socket.on('open', onConnected(new WebSocket(this.socket)));
  }

  close() {
    this.socket.close();
  }
}

class WebSocket {
  constructor(socket) {
    this.socket = socket;
  }

  send(data) {
    this.socket.send(data);
  }

  listen(onMessage) {
    this.socket.on('message', function message(data) {
      onMessage(data);
    });
  }

  close() {
    this.socket.close();
  }
}

module.exports = {
  WebSocketServer,
  WebSocketClient,
  WebSocket
};
