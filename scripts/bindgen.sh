cd native

cbindgen --output out/dartimg.h -l c

cd ..

dart run ffigen --config ffigen.yaml
