# Este programa fue pensado para ejecutarse en el emulador QTSpim. Septiembre 2021

.data
# Punteros
MultigrafoP: .word 0 # Multigrafo ponderado
EtiquetasT: .word 0 # Etiquetados temporales
EtiquetasP: .word 0 # Etiquetados permanentes
Cementerio: .word 0
Buffer: .space 49 # Máximo 10 nodos de 3
# Una prueba mas

.text
.globl main
main:
    li $v0, 8
    la $a0, Buffer
    li $a1, 49
    syscall

    addi $sp, $sp, -4 # Esto es para paserle argumentos a la subrutina AgregarV, que es llamada desde ExtraerV.
    la $t0, MultigrafoP
    sw $t0, 0($sp)
    la $a0, Buffer
    jal ExtraerV
    addi $sp, $sp, 4
    
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
        beq $t0, 8, ExtraerVSig 
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
            jal AgregarV
            li $t2, 0 # Contador de los caracteres revisados antes de la coma
            addi $sp, $sp, 4

            ExtraerVElse3:
            lb $t0, ($s0)
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

AgregarV:
    # s0 tiene la dirección del nodo
    # sp tiene la dirección del ascii del nodo. Automáticamente después de empezar lo muevo a s1.
    # Ya que la subrutina Smalloc no tiene argumentos, voy a utilizar los registros a. De esta manera no tengo que reservar la pila de vuelta.
    move $t0, $sp
    lw $t0, ($t0)
    lw $a1, 16($sp) # MultigrafoP
    addi $sp, $sp, -12 # Hago uso de la pila para poder volver de las llamadas
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    move $s1, $t0

    jal Smalloc # Pido espacio para el nodo vértice. Me devuelve en $v0 la direccion del nuevo nodo
    move $s0, $v0
    jal Smalloc # Pido espacio para el nodo en MatrizAdy
    move $s2, $v0
    # jal Smalloc
    # move $s3, $v0

    lw $t0, ($a1)
    beqz $t0, PrimerV
    
    NuevoV:
        lw $t1, ($t0) # Genero el nodo de vértice vacío en MultigrafoP
        sw $s0, 12($t1)
        sw $t1, 0($s0)
        sw $0, 4($s0)
        sw $s1, 8($s0)
        sw $t0, 12($s0)
        sw $s0, 0($t0)

        move $s0, $t0
        li $t0, 0
        AgregarBucle: beq $t0, $s0, AgregarFin # Todo esto se podría optimizar, pero a quién le importa
            jal Smalloc
            lw $t1, 4($s0) # Coloco el nodo correspondiente al final de cada lista del vértice
            lw $t2, ($t1)
            sw $v0, 12($t2)
            sw $t2, ($v0)
            sw $0, 4($v0)
            sw $s1, 8($v0)
            sw $t1, 12($v0)
            sw $v0, ($t1)

            jal Smalloc
            lw $t0, ($a2)
            lw $t3, 8($s0)
            bne $t0, $s0, AgregarIf # Cuando sea el primero de mi nueva lista del vértice voy a tener que actuializar su puntero
                sw $v0, 4($s2)
                sw $v0, ($v0)
                sw $0, 4($v0)
                sw $t3, 8($v0)
                sw $v0, 12($v0)
                j AgregarElse

            AgregarIf:
            lw $t1, 4($s2)
            lw $t2, ($t1)
            sw $v0, 12($t2)
            sw $t2, ($v0)
            sw $0, 4($v0)
            sw $t3, 8($v0)
            sw $t1, 12($v0)
            sw $v0, ($t1)

            AgregarElse:
            lw $t0, ($t0)
            lw $s0, 12($s0)
            j AgregarBucle

        AgregarFin:
        jal Smalloc
        lw $t1, 4($s2)
        lw $t2, ($t1)
        lw $t3, 8($s2)
        sw $v0, 12($t2)
        sw $t2, ($v0)
        sw $0, 4($v0)
        sw $t3, 8($v0)
        sw $t1, 12($v0)
        sw $v0, ($t1)
        j NuevoListo

    PrimerV:
        sw $s0, ($a1) # Guardo puntero en MultigrafoP, además de empezar la lista
        sw $s0, ($s0)
        sw $0, 4($s0)
        sw $s1, 8($s0)
        sw $s0, 12($s0)

        jal Smalloc
        move $s0, $v0

        sw $s2, ($a2) # Guardo tabla en MatrizAdy
        sw $s2, ($s2)
        sw $s0, 4($s2) # Procedo a agregarle el nodo que indica los lazos consigo mismo
            sw $s0, 0($s0)
            sw $0, 4($s0)
            sw $s1, 8($s0)
            sw $s0, 12($s0)
        sw $s1, 8($s2)
        sw $s2, 12($s2)

        # sw $s3, ($a3)
        # sw $s3, ($s3)
        # sw $0, 4($s3)
        # sw $s1, 8($s3)
        # sw $s3, 12($s3)

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