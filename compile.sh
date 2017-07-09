# function: complie asm file by the latest nasm
# usage: ./complie.sh example.s
# output: example (a 64-bit executable file on Mac OS)
# author: Nick Yang(haitianyang@outlook.com)
# 2017/07/08
# illustration: The version of nasm installed by Apple Inc. is 0.98.40 on Mac OS Sierra(10.12.1) while the latest version of nasm is 2.13.01 on Jul.8th, 2017. The nasm brought by Apple Inc. are not able to compile 64-bit file so it lags behind the current environment. I'm afraid that nasm 0.98.40 is still useful to Mac OS and replacing nasm 0.98.40 by 2.13.01 may lead to unknown error, so I prefer putting the latest nasm in the same path of asm file and using "./nasm" instead of "nasm".
# Suppose there is a file name "myasm.asm" in "/Users" and I copy the nasm file in the same path. Then I should enter these two commands:
# $ ./nasm -f macho64 -o temp.o test.asm
# $ ld -e _main -o myasm temp.o
# , which is so troublesome. So this bash file appears.

#!/bin/bash
NASM=$(find . -type f -name "nasm")
if [ "$NASM" = "" ]
then
    echo "Can not find nasm in the working directory."
    echo "Please copy the latest version of nasm in $(pwd)."
    exit 1
fi
if [ $# = 0 ] # if there is no arguments, then the shell will find the first asm file in the working directory and compile it.
then
    FILE=$(find . -type f -name "*.asm" -o -name "*.s" | head -n 1)
    if [ "$FILE" != "" ]
    then
        NAME=$FILE
        NAME="${NAME%.*}"
        ./nasm -f macho64 -o _temp.o $FILE
        if [ $? != 0 ]
        then
            exit 6
        fi
        ld -e _main -o $NAME _temp.o
        if [ $? != 0 ]
        then
            exit 7
        fi
        rm _temp.o
        if [ $? != 0 ]
        then
            exit 8
        fi
        echo "$FILE has been complied."
    else
        echo "There is no asm file in the working directory($(pwd))"
        echo "Usage: $0 FILENAME"
        echo " e.g.: $0 example.s"
        exit 2
    fi
elif [ $# = 1 ]
then
    if [ ! -f "$1" ]
    then
        echo "$1 does not exist."
        echo "Usage: $0 FILENAME"
        echo " e.g.: $0 example.s"
        exit 3
    fi
    FILE=$1
    NAME=$1
    NAME="${NAME%.*}"
    EXTENSION=$1
    EXTENSION="${EXTENSION##*.}"
    if [ $EXTENSION = $FILE ]
        then
        echo "The asm file must have an extension or it will be covered by the executable file later."
        echo "Usage: $0 FILENAME"
        echo " e.g.: $0 example.s"
        exit 4
    fi
    ./nasm -f macho64 -o _temp.o $FILE
    if [ $? != 0 ]
    then
        exit 6
    fi
    ld -e _main -o $NAME _temp.o
    if [ $? != 0 ]
    then
        exit 7
    fi
        rm _temp.o
    if [ $? != 0 ]
    then
        exit 8
    fi
else
    echo "Too much arguments."
    echo "Usage: $0 FILENAME"
    echo " e.g.: $0 example.s"
    exit 5
fi
