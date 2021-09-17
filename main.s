# Este programa fue pensado para ejecutarse en el emulador QTSpim. Septiembre 2021

.data
# Punteros
MultigrafoP: .word 0 # Multigrafo ponderado
EtiquetasT: .word 0 # Etiquetados temporales
EtiquetasP: .word 0 # Etiquetados permanentes
MatrizAdy: .word 0 # Matriz de adyacencia. Guardamos esta info para que sea fácil de mostrar
Cementerio: .word 0
Buffer: .space 49 # Máximo 10 nodos de 3

## 44 , 45 -
.text
.globl main
main:
    li $v0, 8
    la $a0, Buffer
    li $a1, 49
    syscall
    la $a1, Buffer
    lb $t0, ($a1)
    mainBucle:
        addi $sp, $sp, -4
        move $t1, $sp
        li $t2, 0
        mainBucle2: beqz $t0, mainBucle3 # Por si no se puso un \n
            beq $t0, 10, mainBucle3 # \n
            beq $t0, 44, mainBucle3 # Tras encontrar la coma salto a guardar el campo
            beq $t2, 3, mainBucle31
                mainIf: beq $t0, 32, mainElse # Ignoro los espacios
                    sb $t0, ($t1)
                    addi $t1, $t1, 1
                    addi $t2, $t2, 1
                mainElse:
                addi $a1, $a1, 1
                lb $t0, ($a1)
                j mainBucle2
        mainBucle3:
            addi $a1, $a1, 1
        mainBucle31:
        sb $0, ($t1)
        jal AgregarNodo
        addi $sp, $sp, 4
        beqz $t0, mainListo # Sacamos esta línea y la de arriba comentada y peta cuando no le das enter
        beq  $t0, 10, mainListo
        lb $t0, ($a1)
        j mainBucle
    mainListo:
    addi $sp, $sp, 4
    li $v0, 10
syscall

AgregarNodo:
    # s0 tiene la dirección del nodo
    # sp tiene la dirección del ascii del nodo. Automáticamente después de empezar lo muevo a s1.
    li $v0, 4
    move $a0, $sp
    syscall
    li $v0, 11
    li $a0, 10
    syscall
    jr $ra
    move $t0, $sp
    addi $sp, $sp, -12 # Hago uso de la pila para poder volver de las llamadas
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    move $s1, $t0

    jal Smalloc # Pido espacio para el nodo vértice. Me devuelve en $v0 la direccion del nuevo nodo
    move $s0, $v0

    lw $t0, MultigrafoP
    beqz $t0, PrimerNodo
    
    NuevoNodo:
        lw $t1, ($t0) # Me muevo al último
        lw $t2, 4($t0)
        lw $t2, ($t2) # Me desplazo a la última columna
        Campos:
        sw $s0, 8($s1) # Guardo la dirección del dato
        # Ahora tengo que hacer que el anterior sea el primero, y que el siguiente del primero sea este nodo
        sw $s1, 12($t1) # Ahora último nodo apunta como siguiente al nuevo
        sw $t1, ($s1) # Ahora el anterior de nuevo nodo apunta al último
        sw $t0, 12($s1) # El siguiente del nuevo nodo es el primero
        sw $s1, ($t0) # El anterior del último nodo es el nuevo nodo
        j NuevoListo

    PrimerNodo:
        li $t2, 0
        sw $s0, MultigrafoP
        move $t0, $a0
        lw $t1, 8($s0)
        Primerbn: beq $t0, 10, Primerbn2
            sb $t0, ($t1)
            addi $t0, $t0, 1
            addi $t1, $t1, 1
            li $t2, 1
            j Primerbn
        Primerbn2:
        sw $s0, ($s0)
        sw $s1, 4($s0)
        sw $t0, 8($s0)
        sw $s0, 12($s0)

        sw $s1, ($s1)
        sw $0, 4($s1)
        sw $0, 8($s1)
        sw $s1, 12($s1)

    NuevoListo:
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
jr $ra

Smalloc:
    lw $t0, Cementerio
    beqz $t0, sbrk # Verifico que no haya ningun nodo liberado, por lo que si no es así, irremediablemente voy a tener que pedir memoria
        move $v0, $t0 # Si es así obtengo su dirección
        lw $t0, 12($t0) # Obtengo adónde estaba apuntando para modificar el puntero Cementerio
        sw $t0, Cementerio
        jr $ra

    sbrk:
        li $a0, 16
        li $v0, 9
        syscall
jr $ra

Sfree:
    lw $t0, Cementerio # Obtengo el último de la lista
    sw $t0, 12($a0) # Hago que el nodo ahora apunte ahí
    sw $a0, Cementerio # Él es ahora el último de la lista, por lo que actualizo Cementerio
jr $ra

.end