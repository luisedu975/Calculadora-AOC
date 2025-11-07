.data
msg_menu:      .asciiz "=== CALCULADORA DIDATICA ===\n1 - Decimal para Binário\n2 - Decimal para Octal\nEscolha uma opção: "
msg_input:     .asciiz "\nDigite um número decimal: "
msg_div:       .asciiz "\nDividindo: "
msg_por2:      .asciiz " / "
msg_resto:     .asciiz "  resto: "
msg_resultado: .asciiz "\n\nResultado: "
newline:       .asciiz "\n"

array_restos:  .space 64        # espaço para armazenar restos (máx 64 bits)

.text
main:
    # Mostra o menu
    li $v0, 4
    la $a0, msg_menu
    syscall

    li $v0, 5
    syscall
    move $t9, $v0       # opção escolhida

    # Pede número ao usuário
    li $v0, 4
    la $a0, msg_input
    syscall

    li $v0, 5
    syscall
    move $t0, $v0          # número decimal original

    # Decide base (2 ou 8)
    beq $t9, 1, base2
    beq $t9, 2, base8
    j end_program

# -----------------------------
# Conversão para base 2
# -----------------------------
base2:
    li $t5, 2
    j converte

# -----------------------------
# Conversão para base 8
# -----------------------------
base8:
    li $t5, 8
    j converte

# -----------------------------
# Processo de conversão genérico
# -----------------------------
converte:
    move $t1, $t0          # cópia para divisões
    la $t2, array_restos   # ponteiro para armazenar restos
    li $t3, 0              # contador de dígitos

    # Caso especial: entrada = 0 -> mostrar "0"
    beqz $t1, handle_zero

div_loop:
    beqz $t1, show_result  # se t1 == 0, terminou

    # mostra "Dividindo: X / base"
    li $v0, 4
    la $a0, msg_div
    syscall

    li $v0, 1
    move $a0, $t1
    syscall

    li $v0, 4
    la $a0, msg_por2
    syscall

    li $v0, 1
    move $a0, $t5
    syscall

    # calcula quociente e resto (div $t1, divisor)
    div $t1, $t5
    mflo $t1
    mfhi $t4

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

handle_zero:
    # guarda 0 como único resto
    sb $zero, 0($t2)
    addi $t3, $t3, 1
    j show_result

# -----------------------------
# Exibe o resultado final
# -----------------------------
show_result:
    li $v0, 4
    la $a0, msg_resultado
    syscall

    la $t2, array_restos
    add $t2, $t2, $t3
    addi $t2, $t2, -1

print_loop:
    beqz $t3, end_program    # CORREÇÃO: para quando contador chega a 0

    lb $t4, 0($t2)
    li $v0, 1
    move $a0, $t4
    syscall

    addi $t2, $t2, -1
    addi $t3, $t3, -1
    j print_loop

# -----------------------------
# Encerramento
# -----------------------------
end_program:
    li $v0, 10
    syscall
