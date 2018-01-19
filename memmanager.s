# Program for managing memory usage - allocate and deallocate

#Uses routines to make everything simpler with memory manager
# Size field, available/unavailable marker

# Returned pointer starts at actual memory location

.section .data

# Beginning of memory management

heap_begin:
 .long 0

# End of memory management
current_break:
 .long 0

# Size of memory region header
.equ HEADER_SIZE, 8

# Location of available flag in header
.equ HDR_AVAILABLE_OFFSET, 0

# Location of size field in header
.equ HDR_SIZE_OFFSET, 4

.equ UNAVAILABLE, 0 # Number used to mark space given out
.equ AVAILABLE, 1 # Number used to mark space returned
.equ SYS_BREAK, 45 # Number used for syscall for break
.equ LINUX_SYSCALL, 0x80 @ Makinf syscalls easier to read

.section .text

# Initializes functions
.globl allocate_init
.type allocate_init, @function
allocate_inti:
 pushl %ebp
 movl %esp, %ebp
 
 # If brk syscall is called with 0 in %ebx, return the last valid usable address
 
 movl $SYS_BRK, %eax # break location
 movl $0, %ebx
 int $LINUX_SYSCALL

 incl %eax # %eax has last valid address and we want the mem locationm
 movl %eax, current_break #store current break
 movl %eax, heap_begin # stores curr break to first address to get more mem
 
 movl %ebp, %esp
 popl %ebp
 ret

#fin
