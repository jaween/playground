var datagram = require('dgram');

class Udp {
  socket = datagram.createSocket('udp4');

  constructor() {
    console.log("I am javascript");
  }

  listen(port, onListening, onMessage, onError) {
    this.socket.bind(port);
    
    this.socket.on('message', function(msg, rinfo) {
      onMessage(msg, rinfo);
    });
    
    this.socket.on('error', function (err) {
      onError(err);
      socket.close();
    });

    this.socket.on('listening', () => {
      var address = this.socket.address();
      onListening(address.address, address.port);
    });
  }

  send(message, address, port) {
    this.socket.send(message, 0, message.length, port, address);
  }
  
  close() {
    this.server.close();
  }
}

module.exports = Udp;
