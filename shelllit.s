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
help_text:   .asciz "Available commands: hello, help, clear, exit, calc, game\n"
exit_msg:    .asciz "Exiting shell...\n"
clear_cmd:   .asciz "\033[2J\033[H"

cmd_hello:   .asciz "hello"
cmd_help:    .asciz "help"
cmd_exit:    .asciz "exit"
cmd_clear:   .asciz "clear"
cmd_calc:    .asciz "calc"
cmd_game:    .asciz "game"

cal_prompt1:      .asciz "Enter first number: "
cal_prompt2:      .asciz "Enter operator (+ - * /) exit(0): "
cal_prompt3:      .asciz "Enter second number: "
cal_result_msg:   .asciz "Result: %d\n"
format_num:   .asciz "%d"
format_op:    .asciz " %c"

print_num:   .asciz "%ul"


fmt:        .asciz "%d | %d | %d\n"
player_info:     .asciz "chance to %c\n"
scan_fmt:   .asciz "%d"
X_char:     .asciz "X"
O_char:     .asciz "O"
winner_msg: .asciz "Player %c wins!\n"
invalid_msg: .asciz "Invalid move. Try again.\n"


.bss
dest_buffer: .space 32
num1:  .skip 4
num2:  .skip 4
result:.skip 4
op:    .skip 1

    .align 4
grid:   .skip 36     @ 9 integers = 9 * 4 bytes
choice: .skip 4      @ user input (1 to 9)
player: .skip 1     @ current player ('X' or 'O')

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


main:
    mov r0 ,#0
main_loop:
    
    ldr r0, =prompt
    bl printf
main_comeback:
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
    
    @calc
    ldr r0, =cmd_buf
    ldr r1, =cmd_calc
    bl strcmp
    cmp r0,#0
    beq calculator

    @game
    ldr r0, =cmd_buf
    ldr r1, =cmd_game
    bl strcmp
    cmp r0,#0
    beq Tic_tac_toe
    
    b main_loop
    
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

calculator:
    push {lr}

    @ --- Input first number ---
    ldr r0, =cal_prompt1
    bl printf
    ldr r0, =format_num
    ldr r1, =num1
    bl scanf
next:
    @ --- Input operator ---
    ldr r0, =cal_prompt2
    bl printf
    ldr r0, =format_op
    ldr r1, =op
    bl scanf

    @ --- exit if operator is '0' ---
    ldr r1, =op
    ldr r0, [r1]
    cmp r0, #'0'
    beq cal_exit


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
    mov r4, r3
    ldr r0, =cal_result_msg
    mov r1, r3
    bl printf
    ldr r1,=num1
    mov r2,r3
    str r2, [r1]

    ldr r0, =num1       
    mov r1,r4          
    str r1, [r0] 
 
    b next
    pop {lr}
    b cal_exit

cal_exit:
    pop {lr}
    b main_comeback



Tic_tac_toe:
    push {lr}

    // ==== Initialize grid ====
    ldr r4, =grid
    mov r5, #1          @ starting value
init_loop:
    str r5, [r4], #4
    add r5, r5, #1
    cmp r5, #10
    blt init_loop

    mov r0, #1          @ player 1 (X)
    ldr r1, =player
    strb r0, [r1]

game_loop:
    // ==== Get user input ====
    ldr r1, =player
    ldrb r5, [r1]
    cmp r5, #1
    moveq r1, #'X'      @ Player X
    movne r1, #'O'      @ Player O
    ldr r0, =player_info
    bl printf

    ldr r0, =scan_fmt
    ldr r1, =choice
    bl scanf

    // ==== Convert choice to index ====
    ldr r1, =choice
    ldr r2, [r1]        @ r2 = choice
    @ bl check_valid_move
    cmp r2, #1
    blt print_grid      @ skip if invalid
    cmp r2, #9
    bgt print_grid      @ skip if invalid

    sub r2, r2, #1      @ convert to 0-based index
    mov r3, #4
    mul r7, r2, r3      @ r2 = r2 * 4 (byte offset)
    mov r2,r7
    ldr r4, =grid
    add r4, r4, r2

    ldr r1, =player
    ldrb r5, [r1]
    cmp r5, #1
    moveq r6, #-1       @ X
    movne r6, #-2       @ O
    str r6, [r4]

@ check_valid_move:
@     push {r4, r5, r6, lr}
@     ldr r4, =grid
@     ldr r0, =inn
@     mov r1, r2
@     bl printf

@     ldr r11, [r4,r2]        @ Check if the cell is empty
@     ldr r0, =inn
@     mov r1, r11
@     bl printf
@     cmp r11, #-1         @ Empty cell for X
@     beq invalid_move      @ Valid move
@     cmp r11, #-2         @ Empty cell for O
@     beq invalid_move      @ Valid move
@     pop {r4, r5, r6, lr}
@     bx lr          @ Invalid move

@     // Invalid move, print message
@ invalid_move:
@     ldr r0, =invalid_msg
@     bl printf
@     b game_loop

print_grid:
    ldr r4, =grid
    mov r6, #0          @ loop index

print_loop:
    ldr r0, =fmt
    ldr r1, [r4]
    ldr r2, [r4, #4]
    ldr r3, [r4, #8]

    mov r7, r1
    mov r8, r2
    mov r9, r3

    bl print_row

    add r4, r4, #12
    add r6, r6, #1
    cmp r6, #3
    blt print_loop

    // Toggle player
    ldr r1, =player
    ldrb r5, [r1]
    cmp r5, #1
    moveq r5, #2
    movne r5, #1
    strb r5, [r1]
    
    bl check_winner
    b game_loop

    pop {lr}
    bx lr


print_row:
    push {lr}

    // Print first cell
    cmp r7, #-1
    beq print_X
    cmp r7, #-2
    beq print_O
    mov r0, r7
    bl printf_int
    b after_1
print_X:
    ldr r0, =X_char
    bl printf_str
    b after_1
print_O:
    ldr r0, =O_char
    bl printf_str
after_1:
    mov r0, #'|'
    bl putchar

    // Print second cell
    cmp r8, #-1
    beq print_X2
    cmp r8, #-2
    beq print_O2
    mov r0, r8
    bl printf_int
    b after_2
print_X2:
    ldr r0, =X_char
    bl printf_str
    b after_2
print_O2:
    ldr r0, =O_char
    bl printf_str
after_2:
    mov r0, #'|'
    bl putchar

    // Print third cell
    cmp r9, #-1
    beq print_X3
    cmp r9, #-2
    beq print_O3
    mov r0, r9
    bl printf_int
    b after_3
print_X3:
    ldr r0, =X_char
    bl printf_str
    b after_3
print_O3:
    ldr r0, =O_char
    bl printf_str
after_3:
    mov r0, #'\n'
    bl putchar
    

    pop {lr}
    bx lr

printf_int:
    push {lr}
    ldr r1, =int_fmt
    mov r1, r0
    ldr r0, =int_fmt
    bl printf
    pop {lr}
    bx lr

printf_str:
    push {lr}
    mov r1, r0
    ldr r0, =str_fmt
    bl printf
    pop {lr}
    bx lr


@winner_check:
check_winner:
    push {r4, r5, r6, r7, r8, lr}

    ldr r4, =grid
    mov r5, #0

check_rows:
    ldr r6, [r4, r5]
    add r5,r5, #4
    ldr r7, [r4, r5]
    add r5, r5, #4
    ldr r8, [r4, r5]
    
    cmp r6, r7
    bne not_row_found_winner
    cmp r7, r8
    bne not_row_found_winner
    bl found_winner
not_row_found_winner:
    add r5, r5, #4
    cmp r5, #36
    blt check_rows
    b check_columns


check_columns:
    
    ldr r4, =grid
    ldr r6, [r4, #0]
    ldr r7, [r4, #12]
    ldr r8, [r4, #24]
    cmp r6, r7
    bne not_column1_found_winner
    cmp r6, r8
    bne not_column1_found_winner
    bl found_winner
not_column1_found_winner:
    ldr r6, [r4, #4]
    ldr r7, [r4, #16]
    ldr r8, [r4, #28]
    cmp r6, r7
    bne not_column2_found_winner
    cmp r6, r8
    bne not_column2_found_winner
    bl found_winner
not_column2_found_winner:
    ldr r6, [r4, #8]
    ldr r7, [r4, #20]
    ldr r8, [r4, #32]
    cmp r6, r7
    bne not_column3_found_winner
    cmp r6, r8
    bne not_column3_found_winner
    bl found_winner
not_column3_found_winner:
    b check_diagonals

check_diagonals:
    ldr r4, =grid
    ldr r6, [r4, #0]
    ldr r7, [r4, #16]
    ldr r8, [r4, #32]
    cmp r6, r7
    bne not_diagonal1_found_winner
    cmp r6, r8
    bne not_diagonal1_found_winner
    bl found_winner
not_diagonal1_found_winner:
    ldr r6, [r4, #8]
    ldr r7, [r4, #16]
    ldr r8, [r4, #24]
    cmp r6, r7
    bne not_diagonal2_found_winner
    cmp r6, r8
    bne not_diagonal2_found_winner
    bl found_winner
not_diagonal2_found_winner:
    pop {r4, r5, r6, r7, r8 ,lr}
    bx lr

found_winner:
    ldr r0, =newline
    bl printf

    
    cmp r7, #-1
    bne Ovalue
    ldr r0, =winner_msg          @ winner found
    ldr r1,='X'
    bl printf
    ldr r0, =newline
    bl printf
    pop {r4, r5, r6, r7, r8, lr}
    b main_comeback
Ovalue:
    ldr r0, =winner_msg          @ winner found
    ldr r1,='O'
    bl printf
    ldr r0, =newline
    bl printf
    pop {r4, r5, r6, r7, r8, lr}
    b main_comeback
exit:

.data
int_fmt:    .asciz "%d"
str_fmt:    .asciz "%s"
