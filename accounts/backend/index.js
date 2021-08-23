const admin = require('firebase-admin');
const express = require('express');

const app = express();
app.use(express.json());

app.get('/', function (req, res) {
  const name = process.env.NAME || 'no name';
  res.send('Hello world!');
});

app.post('/users/create', async function (req, res) {
  console.log(`request is ${req}`);
  console.log(`body is ${JSON.stringify(req.body)}`);
  const email = req.body.email;
  const password = req.body.password;
  if (email === null || password === null) {
    res.statusCode(400).json({ "error": "Missing email or password" });
    return;
  }

  try {
    const user = await auth.createUser({
      email: email,
      password: password,
    });
    res.send(user.uid);
  } catch (e) {
    console.log(`error ${e}`);
    res.status(500).send('failed');
  }
});

app.get('/users/:id', function (req, res) {
  const id = req.params.id;
  res.json({ "display_name": "Example", "posts": 7 });
});

const credentials = process.env.DEV_GOOGLE_APPLICATION_CREDENTIALS;
let firebase;
if (credentials) {
  const serviceAccount = require(credentials);
  firebase = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
} else {
  firebase = admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  })
}
const auth = firebase.auth();

const port = process.env.PORT || 8080;
app.listen(port, function () {
  console.log(`Listening on port ${port}`);
});

