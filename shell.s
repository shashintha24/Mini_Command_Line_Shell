    .equ STACK_SIZE, 1024

    .section .bss
stack:      .space STACK_SIZE
buffer:     .skip 128
int_buf:    .space 12
hex_chars:  .space 8

    .section .data
prompt:      .asciz "shell> "
newline:     .asciz "\n"
hello_msg:   .asciz "Hello World!\n"
help_text:   .asciz "Available commands: hello, help, clear, exit, hex, avg\n"
exit_msg:    .asciz "Exiting shell...\n"
clear_cmd:   .asciz "\033[2J\033[H"

cmd_hello:   .asciz "hello"
cmd_help:    .asciz "help"
cmd_exit:    .asciz "exit"
cmd_clear:   .asciz "clear"
cmd_hex:     .asciz "hex"
cmd_avg:     .asciz "avg"

    .section .rodata
hex_table:   .asciz "0123456789ABCDEF"

    .section .text
    .global _start
_start:
    ldr sp, =stack + STACK_SIZE

shell_loop:
    ldr r0, =prompt
    bl print_string

    ldr r0, =buffer
    mov r1, #128
    bl read_input

    bl handle_command
    b shell_loop

handle_command:
    push {r4, lr}

    ldr r1, =cmd_hello
    ldr r0, =buffer
    bl strcmp
    cmp r0, #1
    beq do_hello

    ldr r1, =cmd_help
    ldr r0, =buffer
    bl strcmp
    cmp r0, #1
    beq do_help

    ldr r1, =cmd_clear
    ldr r0, =buffer
    bl strcmp
    cmp r0, #1
    beq do_clear

    ldr r1, =cmd_exit
    ldr r0, =buffer
    bl strcmp
    cmp r0, #1
    beq do_exit

    ldr r1, =cmd_hex
    ldr r0, =buffer
    bl strcmp
    cmp r0, #1
    beq do_hex

    ldr r1, =cmd_avg
    ldr r0, =buffer
    bl strcmp
    cmp r0, #1
    beq do_avg

    pop {r4, lr}
    bx lr

do_hello:
    push {lr}
    ldr r0, =hello_msg
    bl print_string
    pop {lr}
    bx lr

do_help:
    push {lr}
    ldr r0, =help_text
    bl print_string
    pop {lr}
    bx lr

do_clear:
    push {lr}
    ldr r0, =clear_cmd
    bl print_string
    pop {lr}
    bx lr

do_exit:
    push {lr}
    ldr r0, =exit_msg
    bl print_string
    mov r7, #1      @ syscall exit
    mov r0, #0
    svc #0

do_hex:
    push {lr}
    mov r0, #42     @ decimal 42 immediate
    bl print_hex
    ldr r0, =newline
    bl print_string
    pop {lr}
    bx lr

do_avg:
    push {r4, lr}
    mov r0, #10
    mov r1, #20
    mov r2, #30
    add r3, r0, r1
    add r3, r3, r2      @ r3 = sum = 60

    mov r4, #3          @ divisor
    mov r0, #0          @ quotient
do_avg_div_loop:
    cmp r3, r4
    blt do_avg_div_end
    sub r3, r3, r4
    add r0, r0, #1
    b do_avg_div_loop
do_avg_div_end:
    bl print_int
    ldr r0, =newline
    bl print_string
    pop {r4, lr}
    bx lr

strcmp:
    push {r2, r3, lr}
strcmp_loop:
    ldrb r2, [r0], #1
    ldrb r3, [r1], #1
    cmp r2, r3
    bne strcmp_false
    cmp r2, #0
    bne strcmp_loop
strcmp_true:
    mov r0, #1
    b strcmp_end
strcmp_false:
    mov r0, #0
strcmp_end:
    pop {r2, r3, lr}
    bx lr

print_string:
    push {r1, r2, r7, lr}
    mov r1, r0
    mov r2, #0
find_len:
    ldrb r3, [r1, r2]
    cmp r3, #0
    beq found_len
    add r2, r2, #1
    b find_len
found_len:
    mov r7, #4
    mov r0, #1
    svc #0
    pop {r1, r2, r7, lr}
    bx lr

read_input:
    push {r7, lr}
    mov r7, #3
    mov r0, #0
    mov r2, #128
    svc #0
    pop {r7, lr}
    bx lr

print_int:
    push {r1, r2, r3, r4, lr}
    mov r1, r0
    ldr r2, =int_buf + 12
    mov r3, #10
    mov r4, #0
    sub r2, r2, #1       @ Point to last byte of buffer
print_int_loop:
    mov r0, r1
    udiv r1, r0, r3      @ REPLACE: No udiv! Use manual division below instead
    mls r4, r1, r3, r0  @ REPLACE: No mls! Use subtraction below instead

    cmp r0, r3
    blt print_int_continue

print_int_continue:
    sub r1, r0, r3
    @ This part needs to be rewritten without udiv/mls, replaced with manual division

    @ For now, just print fixed "0"
    mov r4, #'0'
    strb r4, [r2], #-1
    b print_int_done

print_int_done:
    mov r0, #1
    mov r1, r2
    mov r2, #12
    mov r7, #4
    svc #0
    pop {r1, r2, r3, r4, lr}
    bx lr

print_hex:
    push {r1, r2, r3, lr}
    mov r1, r0
    ldr r2, =hex_chars + 8
    mov r3, #0
    strb r3, [r2, #-1]!
print_hex_loop:
    and r3, r1, #0xF
    ldr r0, =hex_table
    ldrb r0, [r0, r3]
    strb r0, [r2, #-1]!
    lsr r1, r1, #4
    cmp r1, #0
    bne print_hex_loop
    mov r0, #1
    mov r1, r2
    ldr r2, =hex_chars + 8
    sub r2, r2, r1
    mov r7, #4
    svc #0
    pop {r1, r2, r3, lr}
    bx lr
