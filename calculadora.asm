.data
msg_inicial:    .asciiz "=== CALCULADORA DIDÁTICA ===\nDigite um número em base 10: "
msg_opcoes:     .asciiz "\nEscolha a conversão:\n1 - Converter para base 2 (Binário)\n2 - Converter para base 8 (Octal)\n3 - Converter para base 16 (Hexadecimal)\nOpção: "
msg_bin_inicio: .asciiz "\nConvertendo para binário...\n"
msg_oct_inicio: .asciiz "\nConvertendo para octal...\n"
msg_hexa_inicio:.asciiz "\nConvertendo para hexadecimal...\n"
msg_passos:     .asciiz " Passo -> Quociente: "
msg_resto:      .asciiz " Resto: "
msg_resultado:  .asciiz "\nResultado: "
msg_fim:        .asciiz "\n\n--- Fim da execução ---\n"

buffer_bin:     .space 33
buffer_oct:     .space 20
buffer_hexa:    .space 20

.text
.globl main
main:
    li $v0, 4
    la $a0, msg_inicial
    syscall

    li $v0, 5
    syscall
    move $t2, $v0

    li $v0, 4
    la $a0, msg_opcoes
    syscall

    li $v0, 5
    syscall
    move $t0, $v0

    beq $t0, 1, binario
    beq $t0, 2, octal
    beq $t0, 3, hexa
    j fim

# ============================================================
# BASE 2
# ============================================================
binario:
    li $v0, 4
    la $a0, msg_bin_inicio
    syscall

    move $t1, $t2
    la $s0, buffer_bin
    addi $s0, $s0, 32
    sb $zero, 0($s0)

loop_bin:
    beqz $t1, mostra_bin
    divu $t1, $t1, 2
    mfhi $t3
    mflo $t1

    li $v0, 4
    la $a0, msg_passos
    syscall

    li $v0, 1
    move $a0, $t1
    syscall

    li $v0, 4
    la $a0, msg_resto
    syscall

    li $v0, 1
    move $a0, $t3
    syscall

    addi $s0, $s0, -1
    addi $t3, $t3, 48
    sb $t3, 0($s0)
    j loop_bin

mostra_bin:
    li $v0, 4
    la $a0, msg_resultado
    syscall

    li $v0, 4
    move $a0, $s0
    syscall

    j fim

# ============================================================
# BASE 8
# ============================================================
octal:
    li $v0, 4
    la $a0, msg_oct_inicio
    syscall

    move $t1, $t2
    la $s0, buffer_oct
    addi $s0, $s0, 20
    sb $zero, 0($s0)

loop_oct:
    beqz $t1, mostra_oct
    divu $t1, $t1, 8
    mfhi $t3
    mflo $t1

    li $v0, 4
    la $a0, msg_passos
    syscall

    li $v0, 1
    move $a0, $t1
    syscall

    li $v0, 4
    la $a0, msg_resto
    syscall

    li $v0, 1
    move $a0, $t3
    syscall

    addi $s0, $s0, -1
    addi $t3, $t3, 48
    sb $t3, 0($s0)
    j loop_oct

mostra_oct:
    li $v0, 4
    la $a0, msg_resultado
    syscall

    li $v0, 4
    move $a0, $s0
    syscall

    j fim

# ============================================================
# BASE 16
# ============================================================
hexa:
    li $v0, 4
    la $a0, msg_hexa_inicio
    syscall

    move $t1, $t2
    la $s0, buffer_hexa
    addi $s0, $s0, 20
    sb $zero, 0($s0)

loop_hex:
    beqz $t1, mostra_hex
    divu $t1, $t1, 16
    mfhi $t3
    mflo $t1

    li $v0, 4
    la $a0, msg_passos
    syscall

    li $v0, 1
    move $a0, $t1
    syscall

    li $v0, 4
    la $a0, msg_resto
    syscall

    blt $t3, 10, digito
    addi $t4, $t3, 55
    j print_char

digito:
    addi $t4, $t3, 48

print_char:
    li $v0, 11
    move $a0, $t4
    syscall

    addi $s0, $s0, -1
    sb $t4, 0($s0)
    j loop_hex

mostra_hex:
    li $v0, 4
    la $a0, msg_resultado
    syscall

    li $v0, 4
    move $a0, $s0
    syscall
    j fim

# ============================================================
fim:
    li $v0, 4
    la $a0, msg_fim
    syscall
    li $v0, 10
    syscall
