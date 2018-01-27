# Program for managing memory usage - allocate and deallocate

# Uses routines to make everything simpler with memory manager
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

#allocate memory
# Function: used to grab a section of memory. Checks to see if there are any free blocks and if not, Linux makes a new one
# Returns: Address of the allocated memory in %eax. If no available memory, it will return 0 in %eax 

# Variables used:
# %ecx - holds size of requested memory (first/only memory)
# %eax - current memory region being examined
# %ebx - current break position
# %edx - size of current memory region

.globl allocate
.type allocate, @function
.equ ST_MEM_SIZE

allocate:
 pushl  %ebp
 movl %esp, %ebp
 movl ST_MEM_SIZE(%ebp)
 movl heap_begin, %eax
 movl current_break, %ebx

alloc_loop_begin:
 cmpl %ebx, %eax
 je move_break

 movl HDR_SIZE_OFFSET(%eax), %edx #grab size of this memory
 cmpl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
 je next_location
 
 cmpl %edx, %ecx
 jle allocate_here

next_location:
 addl $HEADER_SIZE, %eax
 addl %edx, %eax

 jmp alloc_loop_begin

allocate_here:
 movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
 addl $HEADER_SIZE, %eax

 movl %ebp, %esp
 popl %ebp
 ret

# This means that we've exhausted all addressable memory
move_break:
 addl $HEADER_SIZE, %ebx
 addl %ecx, %ebx

 pushl %eax
 pushl %ecx
 pushl %ebx
 
 movl $SYS_BRK, %eax

 int $LINUX_SYSCALL

 cmpl $0, %eax
 je error

 popl %ebx
 popl %ecx
 popl %eax

 # memory unavailable, isnce we're about to give it away
 movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
 # set the size of the memory
 movl %ecx, HDR_SIZE_OFFSET(%eax)

# moves %eax to the actual start of usable memory
# %eax now holds the return value
 addl $HEADER_SIZE, %eax
 movl %ebx, current_break
 movl %ebp, %esp
 popl %ebp
 ret

error:
 movl $0, %eax
 movl %ebp, %esp
 popl %ebp
 ret

# EOF

# Deallocate
# Gives region of memory to the pool after we're done using it
.globl deallocate
.type deallocate, @function
.equ ST_MEMORY_SEG, 4 # stack position of memory region to free

deallocate:
 # just get address of memory to free
 movl ST_MEMORY_SEC(%esp), %eax

 subl $HEADER_SIZE, %eax
 
 # makes it available
 movl $AVAILABLE, HDR_AVAIL_OFFSET(%eax)

 ret

# Fin
