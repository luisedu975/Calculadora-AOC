.data
msg_inicial:    .asciiz "=== CALCULADORA DIDÁTICA ===\nDigite um número em base 10: "
msg_opcoes:     .asciiz "Escolha a conversão:\n1 - Converter para base 2 (Binário)\n2 - Converter para base 8 (Octal)\n3 - Converter para base 16 (Hexadecimal)\n4 - Converter para BCD (Binary-Coded Decimal)\n5 - Converter para binário com sinal (16 bits, complemento de 2)\nOpção: "
msg_bin_inicio: .asciiz "\nConvertendo para binário...\n"
msg_oct_inicio: .asciiz "\nConvertendo para octal...\n"
msg_hexa_inicio:.asciiz "\nConvertendo para hexadecimal...\n"
msg_bcd_inicio: .asciiz "\nConvertendo para BCD...\n"
msg_signed_inicio: .asciiz "\nConvertendo para binário com sinal (16 bits, complemento de 2)...\n"
msg_passos:     .asciiz " Passo -> Quociente: "
msg_resto:      .asciiz " Resto: "
msg_resultado:  .asciiz "\nResultado: "
msg_fim:        .asciiz "\n\n--- Fim da execução ---\n"

buffer_bin:     .space 33
buffer_oct:     .space 20
buffer_hexa:    .space 20
buffer_bcd:     .space 80
buffer_signed:  .space 20

.text
.globl main
main:
    li $v0, 4
    la $a0, msg_inicial
    syscall

    li $v0, 5
    syscall
    move $t2, $v0             # número em base 10

    li $v0, 4
    la $a0, msg_opcoes
    syscall

    li $v0, 5
    syscall
    move $t0, $v0             # opção escolhida

    beq $t0, 1, binario
    beq $t0, 2, octal
    beq $t0, 3, hexa
    beq $t0, 4, bcd
    beq $t0, 5, signed16
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
# BASE BCD
# ============================================================
bcd:
    li $v0, 4
    la $a0, msg_bcd_inicio
    syscall

    move $t1, $t2
    la $s0, buffer_bcd
    addi $s0, $s0, 79
    sb $zero, 0($s0)

loop_bcd:
    beqz $t1, mostra_bcd
    divu $t1, $t1, 10
    mfhi $t3
    mflo $t1

    li $t5, 4
conv_bits:
    beqz $t5, fim_digito
    andi $t6, $t3, 1
    srl $t3, $t3, 1
    addi $t6, $t6, 48
    addi $s0, $s0, -1
    sb $t6, 0($s0)
    addi $t5, $t5, -1
    j conv_bits

fim_digito:
    addi $s0, $s0, -1
    li $t7, 32
    sb $t7, 0($s0)
    j loop_bcd

mostra_bcd:
    li $v0, 4
    la $a0, msg_resultado
    syscall

    li $v0, 4
    move $a0, $s0
    syscall
    j fim

# ============================================================
# BINÁRIO COM SINAL (16 bits, COMPLEMENTO DE 2)
# ============================================================
signed16:
    li $v0, 4
    la $a0, msg_signed_inicio
    syscall

    move $t1, $t2      # número original
    li $t4, 16         # contador de bits
    la $s0, buffer_signed
    addi $s0, $s0, 17
    sb $zero, 0($s0)

    bltz $t1, negativo_signed
positivo_signed:
    li $t5, 0

conv_signed_pos:
    beqz $t4, mostra_signed
    andi $t3, $t1, 1
    srl $t1, $t1, 1
    addi $t3, $t3, 48
    addi $s0, $s0, -1
    sb $t3, 0($s0)
    addi $t4, $t4, -1
    j conv_signed_pos

negativo_signed:
    sub $t1, $zero, $t1   # pega valor absoluto
    li $t4, 16
    li $t5, 0
    move $t6, $t1
    li $t7, 0

    # converte valor absoluto
    li $t8, 16
    la $s1, buffer_signed
    addi $s1, $s1, 17
    sb $zero, 0($s1)

conv_abs:
    beqz $t8, inverte_bits
    andi $t3, $t6, 1
    srl $t6, $t6, 1
    addi $t3, $t3, 48
    addi $s1, $s1, -1
    sb $t3, 0($s1)
    addi $t8, $t8, -1
    j conv_abs

# inverte bits
inverte_bits:
    la $s2, buffer_signed
    addi $s2, $s2, 1
    li $t9, 16

inv_loop:
    beqz $t9, soma_um
    lb $t3, 0($s2)
    beqz $t3, prox_inv
    beq $t3, 48, troca1
    beq $t3, 49, troca0
    j prox_inv

troca1:
    li $t3, 49
    j prox_inv

troca0:
    li $t3, 48

prox_inv:
    sb $t3, 0($s2)
    addi $s2, $s2, 1
    addi $t9, $t9, -1
    j inv_loop

# soma 1 ao resultado invertido
soma_um:
    la $s2, buffer_signed
    addi $s2, $s2, 16
    li $t9, 1

soma_loop:
    beqz $t9, mostra_signed
    lb $t3, 0($s2)
    beqz $t3, prox_soma
    sub $t3, $t3, 48
    add $t3, $t3, $t9
    div $t3, $t3, 2
    mflo $t3
    mfhi $t9
    addi $t3, $t3, 48
    sb $t3, 0($s2)
    addi $s2, $s2, -1
    j soma_loop

prox_soma:
    addi $s2, $s2, -1
    j soma_loop

mostra_signed:
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
