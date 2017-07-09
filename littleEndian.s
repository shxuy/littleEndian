;本程序证明需x86-64CPU采用小端模式。如果需要修改待显示的数字，直接修改标记number后的数字即可
;本程序在屏幕上显示的地址是堆栈地址，而非保存number的数据段地址
;根据x86-64寄存器使用惯例，rbx, rbp, r10, r12, r13, r14, r15由被调用者（子过程）负责保存，rax, rcx, rdx, rsi, rdi, rsp, r8, r9, r11由调用者（父过程）负责保存
;寄存器rax保存返回值，rdi, rsi, rdx, rcx, r8, r9分别保存第一个到第六个函数参量
SECTION .data

number: dq 0x0102030405060708 ;待显示的数字

hexHead: db "0x"
colon: db ": "
chline: db 0x0a ;换行符
msg0: db "The original 64-bit integer:", 0x0a
len0: EQU $-msg0
msg1: db "Values in the memory:", 0x0a
len1: EQU $-msg1

LongLong: dd 0x0, 0x0, 0x0, 0x0 ;数字转换为字符串时的临时内存区域，用于存放输入的数字（即子过程的参量）
HexString: dd 0x0, 0x0, 0x0, 0x0 ;数字转换为字符串时，用于存放输出的十六进制数字符串（不含字符串结尾‘\0’，且不含‘0x’开头）

HexCharChar: dd 0x0 ;一字节中储存的数字转换为字符串时，用于存放输出的两个十六进制数字符（不含字符串结尾‘\0’，且不含‘0x’开头）

SECTION .text
global _main

    ;将16位十六进制数字（64位二进制数字）转化为Acsii编码字符串（不含字符串结尾和‘0x’开头）
    ;输入：rdi(存放数值), rsi(值为0，则十六进制中A, B, C, D, E, F使用大写字母，否则使用小写字母a, b, c, d, e, f)
    ;输出：字符串保存在HexString，同时rax中保存 HexString 的地址
    ;因为本子过程使用了寄存器rsi和cx，所以调用本子过程前需要保存寄存器rsi和rcx（如果调用前寄存器rsi或rcx里的值有用的话）
    ;复制这个子过程的时候要记得带上.data段的 LongLong 和 HexString
longLongToChar:
    push rbp ;保护现场，分配栈帧，保存了rbp, rbx, r10
    mov rbp, rsp
    sub rsp, 16
    mov [rsp], rbx
    mov [rsp + 8], r10

    mov rbx, LongLong
    mov [rbx], rdi ;把寄存器rdi里的值存入LongLong
    mov rbp, HexString
    add rbp, 15 ;让寄存器rbp内的值指向字符串HexString的最后一位，也就是十六进制字符串中的个位数。

    mov r10, rsi ;rsi本身是子过程的第二个参数，标志十六进制数是否使用大写字母。然而下一句话要用到寄存器rsi，所以把rsi中的值转移到r10中。之后确定十六进制数使用大写字母还是小写字母的时候，使用r10中的值而非rsi中的值
    mov rsi, 0 ;与寄存器rbx配合的偏移量，用于一字节一字节地依次读取输入数据 LongLong 中的内容
    mov cx, 8 ;cx是计数寄存器，这句话说明Ls将循环8次（64位／每次取8位 = 8次）
Ls: mov al, [rbx + rsi] ;取 LongLong 中的某一字节
    mov ah, al ;把这一字节的值复制一份，al用于读取这一字节的低4位，ah用于读取这一字节的高4位
    and al, 00001111b ;用掩码取最低4位
    add al, 0x30 ;Ascii码里 0x30 是字符 ‘0’, 0x0 + 0x30 = 0x30，正好对应字符‘0’； 0x1 + 0x30 = 0x1，正好对应字符‘1’,以此类推，直到 0x9 + 0x30 = 0x39，正好对应字符‘9’
    cmp al, 0x39
    jna o1 ;如果这4位二进制的值在0 - 9之间，则加上0x30后在0x30 - 0x39之间，正好对应字符‘0’ - ‘9’,无需另行处理，所以跳过“add al, 0x7”
    add al, 0x7 ;如果这4位二进制的值在10D - 15D之间，则需在加上0x30的基础上再加0x7，转换为字符'A' - 'F'。以 10D 为例，0xA + 0x30 + 0x7 = 0x41, 对应Ascii码里的大写字符'A'。如果需要转换为小写字符‘a’ - 'f'，可以把这句话的0x7和下面第六行的0x7全部替换为0x27
    test r10, r10 ;如果r10为0，说明十六进制数采用大写字母（因为第二个参量已经从寄存器rsi转移至r10），无需再增加0x20使得字符变成小写字母
    jz o1
    add al, 0x20
o1: shr ah, 0x4 ;右移4位
    and ah, 00001111b ;用掩码取最低4位，和上句配合即取得这一字节的高4位
    add ah, 0x30
    cmp ah, 0x39
    jna o2
    add ah, 0x7
    test r10, r10
    jz o2
    add ah, 0x20
o2: mov byte [rbp], al ;因为x86-64 CPU 采用小端模式，即数据的低字节保存在内存的高地址，所以从左往右（从低地址往高地址）看，数据的第一个字节存放的是倒数第2位十六进制数和倒数第1位十六进制数，第二个字节存放的是倒数第4位十六进制数和倒数第3位十六进制数，以此类推。上面的代码把一个八位二进制数表示为两个十六进制字符，而这句话以后到“loop Ls”以前的代码的作用是储存这两个十六进制字符
    dec rbp
    mov byte [rbp], ah
    dec rbp
    inc rsi
    loop Ls

    mov rax, HexString ;rax中保存 HexString 的地址，作为返回值

    mov r10, [rsp + 8] ;还原现场
    mov rbx, [rsp]
    add rsp, 16
    pop rbp
    ret

;打印地址
;输入：rdi(一个64位二进制数作为地址值),rsi(值为0使得十六进制中A, B, C等用大写字母，非零值使得a, b, c等用小写字母)
;输出：在屏幕上打印地址，带“0x”前缀，但是不带换行符。
;调用者需要负责保存rax, rcx, rdx, rsi, rdi
printAddress:
    push rbp ;保护现场，分配栈帧，保存了rbp和rdi
    mov rbp, rsp
    sub rsp, 16
    mov [rsp], rdi
    mov [rsp + 8], rsi

    call print0x ;在屏幕上打印"0x"
    mov rdi, [rsp] ;还原rdi内的值，为调用longLongToChar做准备
    mov rsi, [rsp + 8] ;还原rsi内的值，为调用longLongToChar做准备
    call longLongToChar
    mov rax, 0x2000004
    mov rdi, 1
    mov rsi, HexString + 4 ;x86-64 CPU只有48根地址线，用48／4=12位十六进制数表示就足够了。所以地址用16位十六进制数字（64位二进制数字）表示的话，最高4位永远是0x0000,没有意义，所以干脆就不打印这4个零
    mov rdx, 12
    syscall

    add rsp, 16
    pop rbp
    ret

;将一字节中储存的数字转化为两个十六进制的Acsii编码字符（不含字符串结尾和‘0x’开头）
;输入：dl(存放数值), rsi(值为0，则十六进制中A, B, C, D, E, F使用大写字母，否则使用小写字母a, b, c, d, e, f)
;输出：字符串保存在HexCharChar，同时rax中保存 HexCharChar 的地址
;复制这个子过程的时候要记得带上.data段的 HexCharChar
ByteToChar:
    push rbp ;保护现场，分配栈帧，保存了rbp, rbx
    mov rbp, rsp

    mov rbp, HexCharChar ;让寄存器rbp内的值指向HexCharChar，为写入数据做准备

    mov dh, dl ;把这一字节的值复制一份，dl用于读取这一字节的低4位，dh用于读取这一字节的高4位
    and dl, 00001111b ;用掩码取最低4位
    add dl, 0x30
    cmp dl, 0x39
    jna h1
    add dl, 0x7
    test rsi, rsi
    jz h1
    add dl, 0x20
h1: shr dh, 0x4 ;右移4位
    and dh, 00001111b ;用掩码取最低4位，和上句配合即取得这一字节的高4位
    add dh, 0x30
    cmp dh, 0x39
    jna h2
    add dh, 0x7
    test rsi, rsi
    jz h2
    add dh, 0x20
h2: mov byte [rbp], dh
    mov byte [rbp + 1], dl

    mov rax, HexCharChar ;rax中保存 HexCharChar 的地址，作为返回值

    pop rbp
    ret

;立即输出一个换行符
;调用者需要负责保存rax, rdi, rsi, rdx
changeLine:
    mov rax, 0x2000004
    mov rdi, 1
    mov rsi, chline
    mov rdx, 1
    syscall
    ret

;立即输出"0x"
;调用者需要负责保存rax, rdi, rsi, rdx
print0x:
    mov rax, 0x2000004
    mov rdi, 1
    mov rsi, hexHead
    mov rdx, 2
    syscall
    ret

;立即输出": "
;调用者需要负责保存rax, rdi, rsi, rdx
printColon:
    mov rax, 0x2000004
    mov rdi, 1
    mov rsi, colon
    mov rdx, 2
    syscall
    ret

_main:

    push rbp ;把data段的number储存到栈中
    mov rbp, rsp
    sub rsp, 24 ;从栈顶低地址往栈底高地址看，依次存放number的值, rcx, rsi
    mov rax, [qword number]
    mov [rsp], rax

    mov rax, 0x2000004 ;在屏幕上打印"The original 64-bit integer:" + 换行
    mov rdi, 1
    mov rsi, msg0
    mov rdx, len0
    syscall

    ;在屏幕上打印“0x地址: 0x数字” + 换行
    mov rdi, rsp ;在屏幕上打印这个64-bit数的地址
    xor rsi, rsi ;把rsi设为0，使得打印十六进制地址时使用大写字母
    call printAddress
    call printColon ;在屏幕上打印": "
    call print0x ;在屏幕上打印这个64-bit数
    mov rdi, [rsp]
    xor rsi, rsi ;把rsi设为0，使得转换十六进制数时使用大写字母
    call longLongToChar
    mov rax, 0x2000004
    mov rdi, 1
    mov rsi, HexString
    mov rdx, 16
    syscall
    call changeLine ;换行

    call changeLine ;空一行

    mov rax, 0x2000004 ;在屏幕上打印"Values in the memory:" + 换行
    mov rdi, 1
    mov rsi, msg1
    mov rdx, len1
    syscall

    ;在屏幕上打印“0x地址: 0x数字” + 换行，一共 64位 / 每字节8位 = 8行
    mov cx, 8 ;cx是计数寄存器，这句话说明Lp将循环8次
    mov rbx, rsp ;储存基地址
    mov rsi, 0 ;指示地址偏移量，范围从0到7
Lp: mov [rsp + 8], rcx ;保存rcx的值，因为过会儿printAddress会改变rcx的值
    mov [rsp + 16], rsi ;保存rsi的值，因为过会儿printAddress, printColon, print0x, changeLine会改变rsi的值
    mov rdi, rbx
    add rdi, rsi
    xor rsi, rsi ;把rsi设为0，使得打印十六进制地址时使用大写字母
    call printAddress ;在屏幕上打印某一字节的地址
    call printColon ;在屏幕上打印": "
    call print0x ;在屏幕上打印这个字节中储存的值
    mov rsi, [rsp + 16] ;还原rsi的值
    mov dl, [rbx + rsi] ;只传一个字节中的值
    xor rsi, rsi ;把rsi设为0，使得转换十六进制数时使用大写字母
    call ByteToChar
    mov rax, 0x2000004
    mov rdi, 1
    mov rsi, HexCharChar
    mov rdx, 2
    syscall
    call changeLine ;换行
    mov rsi, [rsp + 16] ;还原rsi的值
    mov rcx, [rsp + 8] ;还原rcx的值
    inc rsi ;处理下一字节中的内容
    loop Lp

    add rsp, 24 ;恢复栈指针
    pop rbp
    mov rax, 0x2000001 ;程序正常返回0
    mov rdi, 0
    syscall
