# Writes hello world and exits

.include "linux.s"

.section .data

helloworld:
 .ascii "hello world\n"
helloworld_end:
 .equ helloworld_len, helloworld_end - helloworld
 
 .section .text
 .globl _start
_start:
 movl $STDOUT, %ebx
 movl $helloworld, %ecx
 movl $helloworld_len, %edx
 movl $SYS_WRITE, %eax
 int $LINUX_SYSCALL

 movl $0, %ebx
 movl $SYS_EXIT, %eax
 int $LINUX_SYSCALL

# Function for writing hello world and exiting
 .section .data

helloworld:
 .ascii "hello world\0"
 
 .section .text
 .globl _start
_start:
 pushl $helloworld
 calll printf

 pushl $0
 call exit

