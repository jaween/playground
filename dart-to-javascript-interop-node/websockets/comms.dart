abstract class CommsServer {
  CommsServer(int port, void onConnection(Socket socket, ClientInfo client));
  void close();
}

abstract class CommsClient {
  CommsClient(String host, int port, void onConnected(Socket socket));
  void close();
}

abstract class Socket {
  void send(data);
  void listen(void onMessage(data));
  void close();
}

abstract class ClientInfo {
  String get address;
  int get port;
}
