.section .data
prompt_msg: .asciz "Enter your name: "
hello_msg:  .asciz "Hello, "
buffer:     .space 32               @ Input buffer

.section .text
.global main

@ --- Entry Point ---
main:
    @ Print "Enter your name: "
    ldr r4, =prompt_msg
    bl print_str_syscall

    @ Read user input into buffer
    ldr r4, =buffer
    bl read_str_syscall

    @ Print "Hello, "
    ldr r4, =hello_msg
    bl print_str_syscall

    @ Print the user’s input
    ldr r4, =buffer
    bl print_str_syscall

    @ Exit
    mov r0, #0
    mov r7, #1          @ syscall: exit
    svc #0

@ --- Subroutine: print_str_syscall ---
print_str_syscall:
    push {lr}
    mov r0, r4          @ r0 = fd or string (we will overwrite)
    mov r1, r4          @ r1 = pointer to string
    bl strlen           @ r0 = length
    mov r2, r0          @ r2 = length
    mov r0, #1          @ stdout (fd = 1)
    mov r7, #4          @ syscall: write
    svc #0
    pop {lr}
    bx lr

@ --- Subroutine: read_str_syscall ---
read_str_syscall:
    push {lr}
    mov r0, #0          @ stdin (fd = 0)
    mov r1, r4          @ r1 = buffer pointer
    mov r2, #31         @ max bytes to read (leave space for \0)
    mov r7, #3          @ syscall: read
    svc #0              @ r0 = number of bytes read

    @ Null-terminate the input
    add r1, r4, r0      @ r1 = buffer + bytes_read
    mov r2, #0
    strb r2, [r1]       @ store null terminator

    pop {lr}
    bx lr

@ --- Subroutine: strlen ---
strlen:
    push {r1, r2, lr}
    mov r1, r0          @ r1 = pointer
.loop:
    ldrb r2, [r1], #1   @ load byte and increment
    cmp r2, #0
    bne .loop
    sub r0, r1, r0      @ r1 - r0 = length + 1
    sub r0, r0, #1      @ subtract 1 to remove null
    pop {r1, r2, lr}
    bx lr
