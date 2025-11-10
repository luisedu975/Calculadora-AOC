.data
msg_inicial:    .asciiz "=== CALCULADORA DIDÁTICA ===\nDigite um número em base 10: "
msg_opcoes:     .asciiz "Escolha a conversão:\n1 - Converter para base 2 (Binário)\n2 - Converter para base 8 (Octal)\n3 - Converter para base 16 (Hexadecimal)\n4 - Converter para BCD (Binary-Coded Decimal)\n5 - Converter para binário com sinal (16 bits, complemento de 2)\n6 - Converter real (decimal) para FLOAT (IEEE-754 32 bits)\n7 - Converter real (decimal) para DOUBLE (IEEE-754 64 bits)\nOpção: "
msg_bin_inicio: .asciiz "\nConvertendo para binário...\n"
msg_oct_inicio: .asciiz "\nConvertendo para octal...\n"
msg_hexa_inicio:.asciiz "\nConvertendo para hexadecimal...\n"
msg_bcd_inicio: .asciiz "\nConvertendo para BCD...\n"
msg_signed_inicio: .asciiz "\nConvertendo para binário com sinal (16 bits, complemento de 2)...\n"
msg_float_inicio: .asciiz "\nConvertendo para FLOAT (IEEE-754 32 bits)...\n"
msg_double_inicio:.asciiz "\nConvertendo para DOUBLE (IEEE-754 64 bits)...\n"
msg_passos:     .asciiz " Passo -> Quociente: "
msg_resto:      .asciiz " Resto: "
msg_resultado:  .asciiz "\nResultado: "
msg_fim:        .asciiz "\n\n--- Fim da execução ---\n"

buffer_bin:     .space 33
buffer_oct:     .space 20
buffer_hexa:    .space 20
buffer_bcd:     .space 80
buffer_signed:  .space 20
buffer_float:   .space 33     # 32 bits + null
buffer_double:  .space 65     # 64 bits + null

.text
.globl main
main:
    li $v0, 4
    la $a0, msg_inicial
    syscall

    li $v0, 5
    syscall
    move $t2, $v0             # número em base 10 (inteiro, usado nas conversões originais)

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
    beq $t0, 6, conv_float
    beq $t0, 7, conv_double
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
# CONVERSÃO PARA FLOAT (IEEE-754 32 bits)
# ============================================================
# Usa syscall 6 (read float) -> $f0
# Movemos os bits de $f0 para $t0 com mfc1 e extraímos sinal/expoente/fração
# ============================================================
conv_float:
    li $v0, 4
    la $a0, msg_float_inicio
    syscall

    # ler float decimal do usuário (syscall 6). Resultado em $f0
    li $v0, 6
    syscall

    # copiar bits do registrador float ($f0) para inteiro $t0
    mfc1 $t0, $f0        # $t0 contém pattern de 32 bits da float

    # Montar string de bits (32 bits)
    la $s0, buffer_float
    addi $s0, $s0, 32
    sb $zero, 0($s0)
    li $t5, 32           # contagem bits
    move $t6, $t0

build_float_bits:
    beqz $t5, done_build_float
    # pega bit menos significativo usando srl (desloca para LSB correspondente)
    addi $t5, $t5, -1
    srlv $t7, $t6, $t5   # t7 = t6 >> ($t5)
    andi $t7, $t7, 1
    addi $t7, $t7, 48
    addi $s0, $s0, -1
    sb $t7, 0($s0)
    j build_float_bits

done_build_float:
    # imprimir resultado (bits)
    li $v0, 4
    la $a0, msg_resultado
    syscall

    li $v0, 4
    move $a0, $s0
    syscall

    # extrair sinal, expoente e fração
    # sinal: bit 31
    srl $t1, $t0, 31
    andi $t1, $t1, 1

    # expoente (8 bits): bits 30..23
    srl $t2, $t0, 23
    li $t8, 255
    and $t2, $t2, $t8    # t2 = exponent field (biased)

    # fração (mantissa) 23 bits: bits 22..0
    li $t9, 0x7FFFFF
    and $t3, $t0, $t9    # t3 = fraction field

    # imprimir valores (sinal, expoente, fração)
    li $v0, 4
    la $a0, msg_resto   # usar msg_resto temporário (reaproveito msg)
    syscall

    # Print "Sinal: "
    la $a0, msg_resultado
    li $v0, 4
    syscall

    # Print Sinal (integer)
    li $v0, 1
    move $a0, $t1
    syscall

    # Print newline
    li $v0, 11
    li $a0, 10
    syscall

    # Print "Expoente (campo, com viés): "
    li $v0, 4
    la $a0, msg_passos
    syscall

    li $v0, 1
    move $a0, $t2
    syscall

    # newline
    li $v0, 11
    li $a0, 10
    syscall

    # Print "Fração (campo): "
    li $v0, 4
    la $a0, msg_resto
    syscall

    li $v0, 1
    move $a0, $t3
    syscall

    # newline
    li $v0, 11
    li $a0, 10
    syscall

    j fim

# ============================================================
# CONVERSÃO PARA DOUBLE (IEEE-754 64 bits)
# ============================================================
# Usa syscall 7 (read double) -> $f0 (64 bits em $f0/$f1)
# extraímos $f1 (msw) e $f0 (lsw) com mfc1
# ============================================================
conv_double:
    li $v0, 4
    la $a0, msg_double_inicio
    syscall

    # ler double decimal do usuário (syscall 7). Resultado em $f0/$f1
    li $v0, 7
    syscall

    # mover palavras do double para inteiros
    # convention (MARS/QtSpim): mfc1 $t0,$f0 -> baixa 32 bits (lsw)
    #                         mfc1 $t1,$f1 -> alta 32 bits (msw)
    mfc1 $t0, $f0    # low 32 bits
    mfc1 $t1, $f1    # high 32 bits

    # construir string de 64 bits: primeiro os bits do word alto (t1) 31..0, depois low (t0)
    la $s0, buffer_double
    addi $s0, $s0, 64
    sb $zero, 0($s0)

    # processar 32 bits do high word t1
    li $t5, 32
build_double_high:
    beqz $t5, build_double_low
    addi $t5, $t5, -1
    srlv $t7, $t1, $t5
    andi $t7, $t7, 1
    addi $t7, $t7, 48
    addi $s0, $s0, -1
    sb $t7, 0($s0)
    j build_double_high

build_double_low:
    li $t5, 32
build_double_low_loop:
    beqz $t5, done_build_double
    addi $t5, $t5, -1
    srlv $t7, $t0, $t5
    andi $t7, $t7, 1
    addi $t7, $t7, 48
    addi $s0, $s0, -1
    sb $t7, 0($s0)
    j build_double_low_loop

done_build_double:
    # imprimir bits (64)
    li $v0, 4
    la $a0, msg_resultado
    syscall

    li $v0, 4
    move $a0, $s0
    syscall

    # extrair sinal, expoente (11 bits) e fração (52 bits)
    # sinal: bit 63 -> bit 31 of high word t1
    srl $t2, $t1, 31
    andi $t2, $t2, 1

    # expoente (11 bits): bits 62..52 -> high word bits 30..20
    srl $t3, $t1, 20
    li $t8, 0x7FF
    and $t3, $t3, $t8   # t3 = exponent field (biased)

    # fração (52 bits) -> lower 20 bits of t1 and all 32 bits of t0
    # high 20 bits of fraction:
    li $t9, 0xFFFFF
    and $t4, $t1, $t9   # t4 = top 20 bits of fraction
    move $t5, $t0       # t5 = low 32 bits of fraction

    # imprimir sinal
    li $v0, 4
    la $a0, msg_passos
    syscall

    li $v0, 1
    move $a0, $t2
    syscall

    # newline
    li $v0, 11
    li $a0, 10
    syscall

    # imprimir expoente (campo, com viés)
    li $v0, 4
    la $a0, msg_resto
    syscall

    li $v0, 1
    move $a0, $t3
    syscall

    # newline
    li $v0, 11
    li $a0, 10
    syscall

    # imprimir fração: mostra as duas partes (alta 20 e baixa 32)
    li $v0, 4
    la $a0, msg_passos
    syscall

    # print high 20 bits (as integer)
    li $v0, 1
    move $a0, $t4
    syscall

    # print separator
    li $v0, 11
    li $a0, 32
    syscall

    # print low 32 bits
    li $v0, 1
    move $a0, $t5
    syscall

    # newline
    li $v0, 11
    li $a0, 10
    syscall

    j fim

# ============================================================
fim:
    li $v0, 4
    la $a0, msg_fim
    syscall

    li $v0, 10
    syscall
