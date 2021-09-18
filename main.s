# Este programa fue pensado para ejecutarse en el emulador QTSpim. Septiembre 2021

.data
# Punteros
MultigrafoP: .word 0 # Multigrafo ponderado
EtiquetasT: .word 0 # Etiquetados temporales
EtiquetasP: .word 0 # Etiquetados permanentes
MatrizAdy: .word 0 # Matriz de adyacencia. Guardamos esta info para que sea fácil de mostrar
Cementerio: .word 0
Buffer: .space 49 # Máximo 10 nodos de 3

.text
.globl main
main:
    li $v0, 8
    la $a0, Buffer
    li $a1, 49
    syscall

    la $a0, Buffer
    jal ExtraerV
    
    li $v0, 10
syscall

ExtraerV:
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp) # Puntero al buffer
    move $s0, $a0
    sw $s1, 0($sp)
    li $s1, 0 # bandera para saber si lo último ocurrió
    # $t1, puntero a la dirección de la pila en sentido creciente
    li $t2, 0 # Contador de los caracteres revisados antes de la coma
    ExtraerVBucle:
        lb $t0, ($s0)
        beqz $t0, ExtraerVElse2 # Por si no dio enter
        beq  $t0, 10, ExtraerVElse2 # \n
        beq $t0, 44, ExtraerVIf # Tras encontrar la coma salto a guardar el campo
        bnez $s1, ExtraerVSalto2 # Si la bandera está alta hay que ignorar caracteres
        beq $t2, 3, ExtraerVSalto
        beq $t0, 32, ExtraerVSig # Ignoro los espacios
        bge $t1, $sp, ExtraerVElse # No quiero pedir más pila por cada iteración
            addi $sp, $sp, -4
            move $t1, $sp
        ExtraerVElse:
            sb $t0, ($t1)
                addi $t1, $t1, 1
                addi $t2, $t2, 1
            ExtraerVSig:
            addi $s0, $s0, 1
            j ExtraerVBucle
        ExtraerVSalto:
            li $s1, 1 # Bandera que indica si se pasaron los 3 caracteres
            j ExtraerVElse2
        ExtraerVIf: bne $s1, 1, ExtraerVElse2 # Estaba la bandera alta? Pues significa que encontró el siguiente campo
                li $s1, 0 # Restablezco la bandera
                j ExtraerVSalto2
        ExtraerVElse2: beqz $t2, ExtraerVElse3
            sb $0, ($t1)
            jal AgregarNodo
            li $t2, 0 # Contador de los caracteres revisados antes de la coma
            addi $sp, $sp, 4
            ExtraerVElse3:
            beqz $t0, ExtraerVListo # Por si no dio enter
            beq  $t0, 10, ExtraerVListo # \n
        ExtraerVSalto2:
        addi $s0, $s0, 1
        j ExtraerVBucle

    ExtraerVListo:
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
jr $ra

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