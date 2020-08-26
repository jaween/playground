echo "Compiling object"
g++ -std=c++11 -fPIC -I/opt/flutter/bin/cache/dart-sdk/include -I/home/jaween/Downloads/dart-sdk-master/runtime/ -I/home/jaween/Downloads/dart-sdk-master/runtime/include -DDART_SHARED_LIB -c example.cc /home/jaween/Downloads/dart-sdk-master/runtime/include/dart_api_dl.c

echo "Creating dynamic library"
gcc -shared -Wl,-soname,libmylib.so -o libmylib.so example.o

echo "Cleaning up"
rm example.o
