//本程序证明x86处理器采用的是小端（Little-Endian）模式
#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    int number = 0x12345678;
    int * pointer = &number; //number的地址
    char * pointerForPrint = (char *)pointer; //在C语言中，指针地址加1后，指针变量指向下一个数据元素的首地址，即pointer加1后指针向后移动4个字节（Visual Studio编译器规定的int类型的长度）,而不是一个字节，不符合打印地址的需求，所以设置一个pointerForPrint，并用强制类型转换把该指针设置为char *类型
    int buffer[4] = {0}; // buffer内所有元素全部初始化为0
    int * pbuffer = buffer; // 创建一个指向缓冲区的指针，供汇编语言使用。不能直接用buffer代替pbuffer，否则会导致汇编代码中操作数大小冲突
    _asm { //本段汇编代码的功能是把number最低4位放入buffer[0]中，次低4位放入buffer[1]中，次高4位放入buffer[2]中，最高4位放入buffer[3]中
        mov ebx, pointer // 把number的地址pointer传入ebx中
        mov edi, pbuffer // 把缓冲区的起始地址传入edi中
        mov eax, [ebx]
        mov [edi], al //al是eax最低4位，这句话把eax最低4位放入缓冲区buffer中
        mov eax, [ebx + 1]
        mov [edi + 4], al
        mov eax, [ebx + 2]
        mov [edi + 8], al
        mov eax, [ebx + 3]
        mov [edi + 12], al
    }
    puts("The original 32-bit integer:");
    printf("%p: 0x%x\n", pointer, number);
    putchar('\n'); // 空一行
    puts("Values in the memory:");
    for (int i = 0; i < 4; i++)
        printf("%p: 0x%x\n", pointerForPrint + i, buffer[i]);
    system("PAUSE");
    return 0;
}
