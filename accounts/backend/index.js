var express = require('express');
let app = express();

app.get('/', function (req, res) {
  const name = process.env.NAME || 'no name';
  res.send(`hello world!!! process ${process}`);
});


const port = process.env.PORT || 8080;
app.listen(port, function () {
  console.log(`hello, listening on port ${port}`);
});
