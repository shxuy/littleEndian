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
    char * pointerForPrint = (char *)(&integerOrString); //在C语言中，指针地址加1后，指针变量指向下一个数据元素的首地址，即 &integerOrString 加1后指针向后移动4个字节（Xcode编译器规定的int类型的长度）,而不是一个字节，不符合打印地址的需求，所以设置一个pointerForPrint，并用强制类型转换把该指针设置为char *类型
    puts("The original 32-bit integer:");
    printf("%p: 0x%x\n", &integerOrString, integerOrString.number);
    putchar('\n'); // 空一行
    puts("Values in the memory:");
    for (int i = 0; i < sizeof(int); i++)
        printf("%p: 0x%x\n", pointerForPrint + i, integerOrString.string[i]);
    return 0;
}
