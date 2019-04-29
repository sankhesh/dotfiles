#!/bin/bash

# definition of MAC addresses
sthir=54:bf:64:a1:4f:f8
sanganak=macaddr
macbook=48:d7:05:ce:a7:97
# macbook=32:00:10:65:a0:00

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  wol="wol"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  wol="wakeonlan"
# elif [[ "$OSTYPE" == "cygwin" ]]; then
#         # POSIX compatibility layer and Linux environment emulation for Windows
# elif [[ "$OSTYPE" == "msys" ]]; then
#         # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
# elif [[ "$OSTYPE" == "win32" ]]; then
#         # I'm not sure this can happen.
# elif [[ "$OSTYPE" == "freebsd"* ]]; then
#         # ...
# else
        # Unknown.
fi

echo "Which PC to wake?"
echo "s) sthir"
echo "n) sanganak"
echo "m) macbook"
echo "q) quit"
read input1
case $input1 in
  s)
    eval $wol $sthir
    ;;
  n)
    eval $wol $sanganak
    ;;
  m)
    eval $wol $macbook
    ;;
  Q|q)
    break
    ;;
esac
