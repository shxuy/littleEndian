# littleEndian

The purpose of creating the repository is to prove that x86 CPUs are little-Endian.
There are three methods:

1. **using pure C language**  
Environment: Mac OS Sierra 10.12.1  
IDE: Xcode 8.3.3  
File: pureC.c  

2. **using both C Language and assembly language**  
Environment: Windows 10 64-bit 1511 
IDE: Visual Studio Community 2015  
File: CwithAsm.c  

3. **using pure assembly language**  
Environment: Mac OS Sierra 10.12.1  
Compiler: nasm 2.13.01  
Linker: ld in LLVM 8.1.0  
File: littleEndian.s  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;compile.sh (optional)  
The version of nasm installed by Apple Inc. is 0.98.40 on Mac OS Sierra(10.12.1) while the latest version of nasm is 2.13.01 on Jul.8th, 2017. The nasm brought by Apple Inc. are not able to compile 64-bit file so it lags behind the current environment. I'm afraid that nasm 0.98.40 is still useful to Mac OS and replacing nasm 0.98.40 by 2.13.01 may lead to unknown error, so I prefer putting the latest nasm in the same path of asm file and using "./nasm" instead of "nasm".  
Firstly, you should put the latest nasm and littleEndian.s in the same file, like /Users.  
Secondly, use commands:  
```bash
./nasm -f macho64 -o _temp.o littleEndian.s
ld -e _main -o littleEndian _temp.o
```. 
Or you can put the latest nasm, littleEndian.s and compile.sh in the same file, then execute compile.sh, like this
```bash
./compile.sh
```. 
