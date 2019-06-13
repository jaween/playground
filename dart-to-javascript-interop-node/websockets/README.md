# Dart to JavaScript Interop Node WebSockets

Dart script which is compiled to JavaScript to run a WebSocket server (on Node), or a WebSocket client (on Node or in the browser).

Dart talks to JavaScript using the Dart JavaScript interop package `package:js`.
There are declarations on the Dart side in `websocket_impl.dart` which are implemented on the JavaScript side in `websocket_impl.js`. 


## Running

 1. `npm install` (Retrieves Node dependencies)
 2. `pub get` (Retrieves Dart dependencies)
 3. `npm start` (Compiles Dart to JavaScript, prepends Node preamble and runner, runs the server)
