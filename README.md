Este programa escrito en MIPS Assembly entre Septiembre y Octubre de 2021 permite 
ingresar un multigrafo ponderado, ya sea direccional o no. Se desarrolló para 
utilizarse en QTSpim Simulator. Tristemente Assembly es un lenguaje que no tiene
sentido utlizarse para proyectos de esta índole, porque hay soluciones que sirven mejor
para este tipo de problemas

Funcionamiento:

Se establecen 2 tipos de estructuras de datos para almacenar la información: 
Una que mantiene la información de los distintos vértices, y otra que tiene 
las aristas de cada uno de ellos.

struct Node {
    Node * ant;
    Edge * aristas;
    char[3] nombre;
    Node * sig;
}

struct Edge {
    Edge * ant;
    int peso;
    Node * nodo;
    Edge * sig;
}

Para desarrollar el algoritmo definiremos la siguiente estructura de distinto tamaño:

struct Djikstra {
    Djikstra * ant;
    int etiqueta;
    char[3] nombre;
    bool permanente;
    Djikstra * sig;
}

A partir de esta información se podrá mostrar una matriz de adyacencia, y por supuesto, 
los resultados de Djikstra. Existirá una función que determine el camino más corto para
cada uno de los vértices.


 ------- ------ -----


Soluciones descartadas:

MatrizAdy: .word 0 # Matriz de adyacencia. Guardamos esta info para que sea fácil de mostrar
CostoMenor: .word 0 # Esta matriz tiene el menor costo para cada vertice
EtiquetasT: .word 0 # Etiquetados temporales
EtiquetasP: .word 0 # Etiquetados permanentes

Aunque los nodos de Djikstra difiera de tamaño con los del Multigrafo, tras mucho pensarlo
parece que es lo mejor, tanto para ahorrar memoria, como para llevar a cabo la programación
correspondiente. El nuevo método realiza una mayor cantidad de operaciones, pero qué se yo, ya
fue, se puede hacer como una versión alternativa. Lo que queda definitavemente descartado es guardar
la matriz de adyacencia y la tabla con los caminos más cortos.