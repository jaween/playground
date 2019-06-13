function dartMainRunner(main, args) {
  self.myFunction = require('./myfunctionlib');
  self.MyLib = require('./mylib');
  main(args);
}
