.section .data
hello_msg: .asciz "Hello from syscall!\n"

.section .text
.global main

@ --- Entry Point ---
main:
    bl do_hello        @ Call your do_hello function

    @ Exit syscall
    mov r0, #0         @ exit code
    mov r7, #1         @ syscall number: exit
    svc #0

@ --- Function: do_hello ---
do_hello:
    push {lr}
    ldr r4, =hello_msg     @ Load address of hello_msg into r4
    bl print_str_syscall   @ Call your print routine
    pop {lr}
    bx lr

@ --- Function: print_str_syscall ---
print_str_syscall:
    push {lr}
    mov r0, r4             @ Pass string pointer to r0
    bl strlen              @ strlen returns length in r0
    mov r2, r0             @ r2 = length
    mov r0, #1             @ stdout
    mov r1, r4             @ pointer to string
    mov r7, #4             @ syscall: write
    svc #0
    pop {lr}
    bx lr

@ --- Function: strlen ---
strlen:
    push {r1, r2, lr}
    mov r1, r0             @ r1 = pointer
.loop:
    ldrb r2, [r1], #1      @ Load byte, post-increment pointer
    cmp r2, #0             @ Check for null terminator
    bne .loop
    sub r0, r1, r0         @ r1 - r0 = length + 1
    sub r0, r0, #1         @ Adjust length to exclude null byte
    pop {r1, r2, lr}
    bx lr
