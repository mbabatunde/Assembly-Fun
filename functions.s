# Illustrating how functions work

# Values are stored in registers, nothing in data section

.section .data

.section .text

.globl _start

_start:
 pushl $3 # second argument
 pushl $2 # first argument
 call power # calling function
 addl $8, %esp # moving stack pointer back
 pushl %eax # saving first answer before calling next function
 
 pushl $2 # push second argument
 pushl $5 # push first argument
 call power # calls function
 addl $8, %esp # moving stack pointer back
 
 popl %ebx # Second answer in %eax. First answer on stack. Just popping it out onto %ebx

 addl %eax, %ebx # adding values together
 
 movl $1, $eax # exit (%ebx returned)
 int $0x80

 # Computing powers for a number
 # First argument - base number
 # Second argument - power to raise it
 # %ebx - base number
 # %ecx - holds power
 # -4(%ebp) - holds current result
 # %eax - temp storage

.type power, @function
power:
 pushl %ebp # save old base pointer
 movl $esp, %ebp # moving stack pointer to base pointer
 subl $4, %esp # room for local variable

 movl 8(%ebp), %ebx # puts first argument to %eax
 movl 12(%ebp), %ecx # second argument in %ecx

 movl %ebx, -4(%ebp) # current result

power_loop_start:
 cmpl $1, %ecx # if power = 1, it's done
 je end_power
 movl -4(%ebp), %eax # move current result to %eax
 imull %ebx, %eax # multiply current result by base number
 movl %eax, -4(%ebp) # store current result
 decl %ecx # decrease power
 jmp power_loop_start

end power:
 movl -4(%ebp), %eax # return value goes in %eax
 movl %ebp, %esp # restore stack pointer
 popl %ebp # restore base pointer
 ret 
