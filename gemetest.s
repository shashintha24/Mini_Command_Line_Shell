.data
fmt:        .asciz "%d | %d | %d\n"
player_info:     .asciz "chance to %c\n"
scan_fmt:   .asciz "%d"
X_char:     .asciz "X"
O_char:     .asciz "O"
winner_msg: .asciz "Player %c wins!\n"
invalid_msg: .asciz "Invalid move. Try again.\n"
inn: .asciz "%d\n"

    .bss
    .align 4
grid:   .skip 36     @ 9 integers = 9 * 4 bytes
choice: .skip 4      @ user input (1 to 9)
player: .skip 1     @ current player ('X' or 'O')

    .text
    .global main
main:
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
    @cmp r5, #3
    @beq check_columns
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
    pop {r4, r5, r6, r7, r8, lr}
    ldr r0, =winner_msg          @ winner found
    mov r1, r5
    bl printf
    bx lr


    .data
int_fmt:    .asciz "%d"
str_fmt:    .asciz "%s"
