.data
board:      .ascii "123456789"
prompt:     .asciz "\nEnter position (1-9): "
newline:    .asciz "\n"
xwins:      .asciz "\nPlayer X wins!\n"
owins:      .asciz "\nPlayer O wins!\n"
drawmsg:    .asciz "\nIt's a draw!\n"
invalid:    .asciz "Invalid move.\n"

.text
.global main

main:
    mov r6, #'X'       @ Start with Player X
    
main_loop:
    bl print_board
    ldr r0, =prompt
    bl print_string

    bl get_input       @ r0 = user input (1-9)
    bl valid_move
    cmp r0, #0
    beq invalid_move

    mov r1, r0         @ move index
    sub r1, r1, #1     @ 0-based index
    ldr r2, =board
    add r2, r2, r1
    strb r6, [r2]      @ Set player's symbol

    bl check_winner
    cmp r0, #1
    beq player_wins

    bl is_draw
    cmp r0, #1
    beq draw

    @ Switch player
    cmp r6, #'X'
    moveq r6, #'O'
    movne r6, #'X'
    b main_loop

invalid_move:
    ldr r0, =invalid
    bl print_string
    b main_loop

player_wins:
    cmp r6, #'X'
    ldreq r0, =xwins
    ldrne r0, =owins
    bl print_string
    b end

draw:
    ldr r0, =drawmsg
    bl print_string
    b end

end:
    mov r7, #1
    mov r0, #0
    svc #0

@ ----------- Helpers -----------

@ print_board
print_board:
    ldr r1, =board
    mov r2, #0
print_row:
    mov r0, #1
    mov r7, #4
    mov r3, r1
    add r3, r3, r2
    mov r2, #3
    svc #0

    ldr r0, =newline
    bl print_string

    add r2, r2, #3
    cmp r2, #9
    blt print_row
    bx lr

@ get_input -> r0 = position (1-9)
get_input:
    sub sp, sp, #4
    mov r7, #3
    mov r0, #0
    ldr r1, =board
    add r1, r1, #10    @ input buffer (reuse memory)
    mov r2, #2
    svc #0
    ldrb r0, [r1]
    sub r0, r0, #'0'
    add sp, sp, #4
    bx lr

@ valid_move -> r0 = index (1-9), return 1 if valid else 0
valid_move:
    push {r1, r2, lr}
    cmp r0, #1
    blt _invalid
    cmp r0, #9
    bgt _invalid
    sub r1, r0, #1
    ldr r2, =board
    add r2, r2, r1
    ldrb r1, [r2]
    cmp r1, #'X'
    beq _invalid
    cmp r1, #'O'
    beq _invalid
    mov r0, #1
    b done_valid

_invalid:
    mov r0, #0
    bx lr
done_valid:
    pop {r1, r2, lr}
    bx lr

@ check_winner -> r0 = 1 if win else 0
check_winner:
    push {r1-r6, lr}
    ldr r1, =board
    mov r0, #0

    @ Check rows, columns, diagonals
    ldrb r2, [r1]
    ldrb r3, [r1, #1]
    ldrb r4, [r1, #2]
    cmp r2, r3
    bne chk2
    cmp r2, r4
    beq win

chk2: ldrb r2, [r1, #3]
    ldrb r3, [r1, #4]
    ldrb r4, [r1, #5]
    cmp r2, r3
    bne chk3
    cmp r2, r4
    beq win

chk3: ldrb r2, [r1, #6]
    ldrb r3, [r1, #7]
    ldrb r4, [r1, #8]
    cmp r2, r3
    bne chk4
    cmp r2, r4
    beq win

chk4: ldrb r2, [r1]
    ldrb r3, [r1, #3]
    ldrb r4, [r1, #6]
    cmp r2, r3
    bne chk5
    cmp r2, r4
    beq win

chk5: ldrb r2, [r1, #1]
    ldrb r3, [r1, #4]
    ldrb r4, [r1, #7]
    cmp r2, r3
    bne chk6
    cmp r2, r4
    beq win

chk6: ldrb r2, [r1, #2]
    ldrb r3, [r1, #5]
    ldrb r4, [r1, #8]
    cmp r2, r3
    bne chk7
    cmp r2, r4
    beq win

chk7: ldrb r2, [r1]
    ldrb r3, [r1, #4]
    ldrb r4, [r1, #8]
    cmp r2, r3
    bne chk8
    cmp r2, r4
    beq win

chk8: ldrb r2, [r1, #2]
    ldrb r3, [r1, #4]
    ldrb r4, [r1, #6]
    cmp r2, r3
    bne no_win
    cmp r2, r4
    beq win

no_win:
    mov r0, #0
    pop {r1-r6, lr}
    bx lr

win:
    mov r0, #1
    pop {r1-r6, lr}
    bx lr

@ is_draw -> r0 = 1 if draw, else 0
is_draw:
    push {r1-r2, lr}
    ldr r1, =board
    mov r2, #0
check_loop:
    ldrb r0, [r1, r2]
    cmp r0, #'X'
    beq check_next
    cmp r0, #'O'
    beq check_next
    mov r0, #0
    pop {r1-r2, lr}
    bx lr
check_next:
    add r2, r2, #1
    cmp r2, #9
    blt check_loop
    mov r0, #1
    pop {r1-r2, lr}
    bx lr

@ print_string
print_string:
    mov r7, #4
    mov r1, r0
    mov r0, #1
    mov r2, #100
    svc #0
    bx lr
