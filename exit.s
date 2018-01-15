#Returns status code of Linux Kernel through echo $?

#Variables:
# %eax - syscall number
# %ebx - return status

.section .data

.section .text
.globl _start
_start:
 movl $1, $eax  # linux kernel command for exiting a program
 movl $0, %ebx  # status returned to OS (will affect echo $?
 int $0x80      # kernel runs this command
