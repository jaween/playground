function dartMainRunner(main, args) {
  self.websocket_impl = require('./websocket_impl.js');
  self.WebSocketServer = self.websocket_impl.WebSocketServer;
  self.WebSocketClient = self.websocket_impl.WebSocketClient;
  self.Socket = self.websocket_impl.Socket;
  main(args);
}
