#!/bin/sh

if [ ! $CI ]; then
  export PATH=$PATH:/opt/homebrew/bin
  clang-format -i -style=file `find ./vu-meter-core/Sources ./vu-meter-core/Tests -type f \( -name *.h -o -name *.cpp -o -name *.hpp -o -name *.m -o -name *.mm \)`
fi
