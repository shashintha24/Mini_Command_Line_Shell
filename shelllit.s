.data
prompt_num:     .asciz "Enter the number of strings : \n"
invalid_num:    .asciz "Invalid Number\n"
prompt_str:     .asciz "Enter input string %d: \n"
output_str:     .asciz "Output string %d is...\n"
input_buffer:   .space 200    @ 200-byte buffer
cmd_buf:        .space 100
newline:        .asciz "\n"

prompt:      .asciz "shell> "
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

cal_prompt1:      .asciz "Enter first number: "
cal_prompt2:      .asciz "Enter operator (+ - * /): "
cal_prompt3:      .asciz "Enter second number: "
cal_result_msg:   .asciz "Result: %d\n"
format_num:   .asciz "%d"
format_op:    .asciz " %c"

print_num:   .asciz "%ul"

.bss
dest_buffer: .space 32
num1:  .skip 4
num2:  .skip 4
op:    .skip 1

.text
.global main

@ strlen function - Input: r0, Output: r0
strlen:
    mov r1, #0          @ r1: Counter
strlen_loop:
    ldrb r2, [r0], #1   @ Load byte
    cmp r2, #0          @ Check null
    beq strlen_end
    add r1, r1, #1
    b strlen_loop
strlen_end:
    mov r0, r1
    mov pc, lr          @ Return

@ reverse_string - Input: r0
reverse_string:
	@ r4: input string
	@ r5: string length from strlen
	@ r6: 
    sub sp, sp, #16     @ Make space for 4 registers
    str lr, [sp, #12]   @ Save lr
    str r6, [sp, #8]
    str r5, [sp, #4]
    str r4, [sp, #0]
    
    mov r4, r0          @ Save string
    bl strlen
    mov r5, r0          @ Length
    
    cmp r5, #1		@ if the string is a single letter or empty return rev_done
    ble rev_done
    
    mov r1, r4          @ Start pointer
    add r2, r4, r5
    sub r2, r2, #1      @ End pointer
    
rev_loop:
    cmp r1, r2
    bge rev_done
    
    ldrb r3, [r1]       @ Swap
    ldrb r6, [r2]
    strb r6, [r1], #1
    strb r3, [r2], #-1
    
    b rev_loop
    
rev_done:
    ldr r4, [sp, #0]    @ Restore
    ldr r5, [sp, #4]
    ldr r6, [sp, #8]
    ldr lr, [sp, #12]
    add sp, sp, #16
    mov pc, lr

main:
    b calcultor

    b main_loop

    sub sp, sp, #24     @ Space for 6 registers
    str lr, [sp, #20]
    str r8, [sp, #16]
    str r7, [sp, #12]
    str r6, [sp, #8]
    str r5, [sp, #4]
    str r4, [sp, #0]
    
    bl do_help

    @LDR r1, =prompt_num     @ r1 = source address
    @LDR r0, =dest_buffer    @ r0 = destination address
    @BL strcpy               @ call strcpy
    @ldr r0, =dest_buffer
    @bl printf
    ldr r0, =print_num
    ldr r1,=5000000
    bl printf

    ldr r0, =prompt_num
    bl printf
    
    ldr r0, =input_buffer
    bl gets
    bl atoi 		@ atoi converts string to an integer
    mov r4, r0          @ String count

    cmp r4, #0
    blt invalid
    
    cmp r4, #0
    beq exit
    
    mov r5, #0          @ Counter

main_loop:
    ldr r0, =cmd_buf
    bl gets
    
    @hello
    ldr r0, =cmd_buf     @ r0 → input command
    ldr r1, =cmd_hello   @ r1 → "hello"
    bl strcmp            @ compare input vs "hello"
    cmp r0, #0
    beq do_hello         @ If equal, run hello handler

    @help
    ldr r0, =cmd_buf
    ldr r1, =cmd_help
    bl strcmp
    cmp r0,#0
    beq do_help
    
    @exit
    ldr r0, =cmd_buf
    ldr r1, =cmd_exit
    bl strcmp
    cmp r0,#0
    beq do_exit
 
    @clear
    ldr r0, =cmd_buf
    ldr r1, =cmd_clear
    bl strcmp
    cmp r0,#0
    beq do_clear


    b main_loop
    
loop:
    cmp r5, r4
    bge exit
    
    ldr r0, =prompt_str
    mov r1, r5
    bl printf
    
    ldr r0, =input_buffer
    bl gets
    
    ldr r0, =input_buffer
    bl reverse_string
    
    ldr r0, =output_str
    mov r1, r5
    bl printf
    
    ldr r0, =input_buffer
    bl printf
    
    ldr r0, =newline
    bl printf
    
    add r5, r5, #1
    b loop
    
invalid:
    ldr r0, =invalid_num
    bl printf

do_hello:
    push {lr}
    ldr r0, =hello_msg
    bl printf
    pop {lr}
    bx lr

do_help:
    push {lr}
    ldr r0, =help_text
    bl printf
    pop {lr}
    bx lr

do_clear:
    push {lr}
    ldr r0, =clear_cmd
    bl printf
    pop {lr}
    bx lr

do_exit:
    push {lr}
    ldr r0, =exit_msg
    bl printf
    mov r7, #1      @ syscall exit
    mov r0, #0
    svc #0

do_hex:
    push {lr}
    mov r0, #42     @ decimal 42 immediate
    bl printf
    ldr r0, =newline
    bl printf
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

strcpy:
    sub sp,sp, #4     @ adjust stack for 1 item
    str r4,[sp,#0]    @ save r4
    mov r4,#0         @ i = 0
L1: add r2,r4,r1      @ addr of y[i] in r2
    ldrb r3, [r2, #0] @ r3 = y[i]
    add r12,r4,r0     @ Addr of x[i] in r12
    strb r3,[r12, #0] @ x[i] = y[i]
    cmp r3,#0
    beq L2            @ exit loop if y[i] == 0
    add r4,r4,#1      @ i = i + 1
    b L1              @ next iteration of loop
L2: ldr r4, [sp,#0]   @ restore saved r4
    add sp,sp, #4     @ pop 1 item from stack
    mov pc,lr         @ return

@ r0 = address of string1
@ r1 = address of string2
@ Returns: r0 = 0 if equal, non-zero if not equal

strcmp:
    push {r2, r3, lr}     @ Save temp registers and link register

strcmp_loop:
    ldrb r2, [r0], #1     @ Load byte from string1 and post-increment
    ldrb r3, [r1], #1     @ Load byte from string2 and post-increment
    cmp r2, r3            @ Compare characters
    bne strcmp_not_equal  @ If different, strings are not equal
    cmp r2, #0            @ End of both strings?
    bne strcmp_loop       @ If not, continue loop

    mov r0, #0            @ Equal → return 0
    b strcmp_end

strcmp_not_equal:
    mov r0, #1            @ Not equal → return 1

strcmp_end:
    pop {r2, r3, lr}
    bx lr

calcultor:
    push {lr}

    @ --- Input first number ---
    ldr r0, =cal_prompt1
    bl printf
    ldr r0, =format_num
    ldr r1, =num1
    bl scanf

    @ --- Input operator ---
    ldr r0, =cal_prompt2
    bl printf
    ldr r0, =format_op
    ldr r1, =op
    bl scanf

    @ --- Input second number ---
    ldr r0, =cal_prompt3
    bl printf
    ldr r0, =format_num
    ldr r1, =num2
    bl scanf

    @ --- Load values into registers ---
    ldr r0, =num1
    ldr r0, [r0]
    ldr r1, =num2
    ldr r1, [r1]
    ldr r2, =op
    ldrb r2, [r2]

    @ --- Perform operation ---
    cmp r2, #'+'     
    beq do_add
    cmp r2, #'-'
    beq do_sub
    cmp r2, #'*'
    beq do_mul
    cmp r2, #'/'
    beq do_div

    b exit

do_add:
    add r3, r0, r1
    b print_result

do_sub:
    sub r3, r0, r1
    b print_result

do_mul:
    mul r3, r0, r1
    b print_result

do_div:
    mov r3, #0
div_loop:
    cmp r0, r1
    blt print_result
    sub r0, r0, r1
    add r3, r3, #1
    b div_loop

print_result:
    ldr r0, =cal_result_msg
    mov r1, r3
    bl printf
    b cal_exit

cal_exit:
    pop {lr}
    bx lr




exit:
    ldr r4, [sp, #0]
    ldr r5, [sp, #4]
    ldr r6, [sp, #8]
    ldr r7, [sp, #12]
    ldr r8, [sp, #16]
    ldr lr, [sp, #20]
    add sp, sp, #24
    mov pc, lr

