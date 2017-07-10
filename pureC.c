//本程序利用C语言中联合体union的特性证明x86处理器采用的是小端（Little-Endian）模式
#include <stdio.h>
union //联合体union的存放顺序是所有成员都从低地址开始存放
{
    int number;
    char string[sizeof(int)];
} integerOrString;


int main(void)
{
    integerOrString.number = 0x12345678;
    puts("The original 32-bit integer:");
    printf("%p: 0x%x\n", &integerOrString, integerOrString.number);
    putchar('\n'); // 空一行
    puts("Values in the memory:");
    for (int i = 0; i < sizeof(int); i++)
        printf("%p: 0x%x\n", &integerOrString.string[i], integerOrString.string[i]);
    return 0;
}
