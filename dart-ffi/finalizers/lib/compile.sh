echo "Compiling objects"
g++ -std=c++11 -fPIC -I/home/jaween/Downloads/dart-sdk-master/runtime/ -DDART_SHARED_LIB -c example.cc /home/jaween/Downloads/dart-sdk-master/runtime/include/dart_api_dl.c

echo "Linking dynamic library"
gcc -shared -Wl,-soname,libmylib.so -o libmylib.so example.o dart_api_dl.o

echo "Cleaning up"
rm *.o
