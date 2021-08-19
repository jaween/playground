var admin = require('firebase-admin');
var express = require('express');
let app = express();

app.get('/', function (req, res) {
  const name = process.env.NAME || 'no name';
  res.send(`Hello world!`);
});

app.post('/users/create', function (req, res) {
  auth.createUser({}).then(function (user) {
    res.send(`Created user ${user.uid}\n`)
  }).catch(function (e) {
    console.log(`error ${e}`);
    res.status(500).send('failed');
  });

});

const credentials = process.env.DEV_GOOGLE_APPLICATION_CREDENTIALS;
var firebase;
if (credentials) {
  var serviceAccount = require(credentials);
  firebase = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
} else {
  firebase = admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  })
}
let auth = firebase.auth();

const port = process.env.PORT || 8080;
app.listen(port, function () {
  console.log(`Listening on port ${port}`);
});

