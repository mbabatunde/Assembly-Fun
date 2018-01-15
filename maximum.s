# Finding the largest number in a set of data items

# Variables
# %edi - current element in data section
# %ebx - current largest value
# %eax - current data item

# data_items - contains the item data. 0 terminates (sentinel value)

 .section data
 data_items:
 .long 3, 67, 34, 222, 45, 75, 54, 34, 44, 33, 22, 11, 66, 0
 
 .section .text
 .globl _start
_start:
 movl $0, %edi # 0 in index register
 movl data_items(, %edi, 4), %eax # loading first byte of data
 movl %eax, $ebx

start_loop:
 cmpl $0, %eax # checking if we hit the end
 je loop_exit
 incl %edi # loads next value
 movl data_items(, %edi, 4), %eax
 cmpl %ebx, %eax # comparing values
 jle start_loop # starts loop again if new one isn't bigger
 movl %eax, %ebx # now move into largest value
 jmp start_loop # jump to start of loop

loop_exit:
 # %ebx is the status code for exiting and holds max value
 movl $1, %eax # exit syscall
 int $0x80
  
