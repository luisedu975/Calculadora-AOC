.data
msg_input:     .asciiz "\nDigite um numero decimal: "
msg_div:       .asciiz "\nDividindo: "
msg_por2:      .asciiz " / 2 = "
msg_resto:     .asciiz "  resto: "
msg_resultado: .asciiz "\n\nResultado em binario: "
newline:       .asciiz "\n"

array_restos:  .space 64        # espaço para armazenar restos (máx 64 bits)

.text
main:
    # Pede número ao usuário
    li $v0, 4
    la $a0, msg_input
    syscall

    li $v0, 5
    syscall
    move $t0, $v0          # número decimal original

    move $t1, $t0          # cópia para divisões
    la $t2, array_restos   # ponteiro para armazenar restos
    li $t3, 0              # contador de bits
    li $t5, 2              # divisor (2)

div_loop:
    beqz $t1, show_result  # se t1 == 0, terminou

    # mostra "Dividindo: X / 2"
    li $v0, 4
    la $a0, msg_div
    syscall

    li $v0, 1
    move $a0, $t1
    syscall

    li $v0, 4
    la $a0, msg_por2
    syscall

    div $t1, $t5           # divide por 2
    mflo $t1               # quociente
    mfhi $t4               # resto

    # mostra quociente e resto
    li $v0, 1
    move $a0, $t1
    syscall

    li $v0, 4
    la $a0, msg_resto
    syscall

    li $v0, 1
    move $a0, $t4
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    # guarda resto na memória
    sb $t4, 0($t2)
    addi $t2, $t2, 1
    addi $t3, $t3, 1

    j div_loop

# --------------------------------------
# Exibe o resultado binário (restos invertidos)
# --------------------------------------
show_result:
    li $v0, 4
    la $a0, msg_resultado
    syscall

    # t2 está no fim do array, precisamos voltar
    la $t2, array_restos
    add $t2, $t2, $t3
    addi $t2, $t2, -1

print_loop:
    beqz $t3, end_program

    lb $t4, 0($t2)
    li $v0, 1
    move $a0, $t4
    syscall

    addi $t2, $t2, -1
    addi $t3, $t3, -1
    j print_loop

end_program:
    li $v0, 10
    syscall
