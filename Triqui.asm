.data
	tablero: .asciiz 		"  1   2   3\n1   |   |   \n ---+---+---\n2   |   |   \n ---+---+---\n3   |   |   \n"
	preguntarJuego: .asciiz 	"\nDeseas jugar en el modo dos jugadores o deseas jugar contra el PC (1 PvP | 2 PvC): "
	preguntaMover: .asciiz 		" Jugador   donde quieres poner tu ficha? EJEMPLO: (12)(columna|fila): "
	movimientoInvalido: .asciiz 	"\n.:Movimiento Invalido:.\n\n"
	espacioOcupado: .asciiz 	"\n.:Esta casilla ya esta ocupadad:.\n\n"
	x: .asciiz 			"X"
	o: .asciiz 			"O"
	ganar: .asciiz 			"\nJugador   Gana! \n"
	empate: .asciiz  		"\n¡Hubo un empate!\n"
	menuDeJuego: .asciiz 		"\nElige una opcion ([1] Jugar de nuevo [2] Salir): "
	espacio: .byte 			' '


.text
.globl main


main:
	li $t1, 0           		#Inicializamos en 0, 9 enteros que usaremos como los valores del ttriqui
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0

	li $s0, 0 			#variable para el turno actual
	li $s5, 0 			#Variable para la cantidad de turnos

	la $s1, tablero                 #Asignamos valores s1,s2,s3 y s4 a cada uno de los mensajes para luego poder modificarlos facilmente con sb
	la $s2, preguntaMover
	la $s3, ganar
	la $s4, preguntarJuego

	lb $a1, espacio
	
	sb $a1, 14($s1)                 #Se agregan los espacios necesarios en las posiciones exactas de la tabla, para imprimir
	sb $a1, 18($s1)                 #El tablero correctamente
	sb $a1, 22($s1)
	sb $a1, 40($s1)
	sb $a1, 44($s1)
	sb $a1, 48($s1)
	sb $a1, 66($s1)
	sb $a1, 70($s1)
	sb $a1, 74($s1)
	
	li $v0, 4
	la $a0, preguntarJuego   	#Se imprime el mensaje para preguntar como quiere jugar
	syscall
	
	li $v0, 5              		#Pide por la opcion entera y lo guarda en v0
	syscall
	
	move $s4, $v0         		#Movemos  vO a s4 con el fin de poder utilizar la variable en las condiciones


ImprimirTablero:
	li $v0, 4                       #Se imprime tablero
	la $a0, tablero
	syscall

	beq $s5, 9, Empate 		#Se verifica que no se haya cruzado el limite de turnos, o sea 9

	add $s5, $s5, 1    		#Contador de turnos

	rem $t0, $s0, 2    		#Busca el residuo de el turno actual (en principio 0) sobre 2, para saber si es un turno par o impar
	add $s0, $s0, 1    		#Le añade a el turno actual +1, es un contador
	bnez $t0, Jugador0 		#Si el redisuo del turno / 2, no es igual a 0 va a jugador O
	beq $s4, 2, JugadaPC


JugadorX:
	lb $a1, x          		#Definimos a1, como x, esto con el fin de poder mencioarlo en los mensajes
	sb $a1, 9($s2)     		#En $s2  que es el mensaje de pregunta, en la posición 9 donde se dejo un espacio se digitara la x
	sb $a1, 9($s3)     		#En $s3 en donde esta el mensaje de victoria, en la posicion 9 se esceibira la x
	j Jugar
	
	
Jugador0:
	lb $a1, o        
	sb $a1, 9($s2)   
	sb $a1, 9($s3)
	j Jugar


JugadaPC:
	lb $a1, x          		#Definimos a1, como x, esto con el fin de poder mencioarlo en los mensajes
	sb $a1, 9($s2)     		#En $s2  que es el mensaje de pregunta, en la posición 9 donde se dejo un espacio se digitara la x
	sb $a1, 9($s3)     		#En $s3 en donde esta el mensaje de victoria, en la posicion 9 se esceibira la x
	
	la $s6, 0
	beq $s5, 1, J11
	beq $s5, 3, Calcular      	#En este apartado le asignamos a cada turno impar (turno de x) una casilla que le conviene
	beq $s5, 5, Calcular2         	#También damos inicio a funciones en las que hay incompatibilidad con algunas casillas abriendo así la posibilidad de más condiciones
	beq $s5, 7, J22
	beq $s5, 9, J32

	
OcupadoPC:
	beq $s5, 3, J31      		#Según el turno (3,5,7) X selecciona una casilla
	beq $s5, 5, J31         	#OcupadoPC y ocupado2PC son condiciones que se utilizaran encada turno y seleccion especifica, esto es para que la maquina se asegure de ganar o empatar, estas condiciones se ven cuando una casilla que quiere la maquina ya se encuentra ocupada.
	beq $s5, 7, Calcular3
	
	
Ocupado2PC:               
	beq $t6, 2, J12
	beq $t3, 1, J32
	beq $s5, 7, J23
	
	
Calcular:                 		#Calcular, Calcular2 y Calcular3, al igual que ocupado, se encargar se asignar X a las casillas, con la diferencia de que estas no se utilizan al momento de encontrar casillas ocupadas, es una condicion que parte de otras condiciones, para asegurar asi que no pierda.
	beq $t4, 2, J31
	beq $t6, 2, J31
	
	j J13


Calcular2:
	beq $t6, 2, J13
	beq $t8, 2, J31
	
	j J33


Calcular3:
	beq $t3, 2, J23
	beq $t5, 2, J21
	beq $t2, 2, J23
	beq $t7, 2, J32
	beq $t9, 2, J21
	
	j J32


Jugar:
	li $v0, 4
	la $a0, preguntaMover   	#Se imprime el mensaje para preguntar en donde desea agregar la x o O
	syscall

	li $v0, 5              		#Pide por un entero y lo guarda en v0
	syscall
	move $s6, $v0         		#Movemos  vO a s6 con el fin de poder utilizar la variable en las condiciones

	beq $s6, 11, J11      		#Condición en que pregunta si la variable ingresada es igual a 11,21,31.. que son las posiciones (x,y) 
	beq $s6, 21, J21
	beq $s6, 31, J31
	beq $s6, 12, J12
	beq $s6, 22, J22
	beq $s6, 32, J32
	beq $s6, 13, J13
	beq $s6, 23, J23
	beq $s6, 33, J33

	li $v0, 4
	la $a0, movimientoInvalido  	#En caso de digitar una posición incorrecta, se repite la función
	syscall
	j Jugar
	

J11:
	bnez $t1, Ocupado          	#En caso de que t1  no sea igual a 0, dirigimos a la persona a la función ocupado
	bnez $t0, O11             	#Aqui dependiendo de si el turno era par o impar decide por 0 o X y lo dirigimos a la función

	X11:
	li $t1, 1                  	#Le asigna a t1 el valor 1, que es el que le proporcionamos a x
	sb $a1, 14($s1)            	#Imprimimos la x en la tabla
	j RevisarVictoria

	O11:                     	#En caso de ser impar entra a O en donde realiza el mismo procedimiento que arriba
	li $t1, 2
	sb $a1, 14($s1)
	j RevisarVictoria


J21:
	bnez $t2, Ocupado
	bnez $t0, O21

	X21:
	li $t2, 1
	sb $a1, 18($s1)
	j RevisarVictoria

	O21:
	li $t2, 2
	sb $a1, 18($s1)
	j RevisarVictoria


J31:
	bnez $t3, Ocupado
	bnez $t0, O31

	X31:
	li $t3, 1
	sb $a1, 22($s1)
	j RevisarVictoria

	O31:
	li $t3, 2
	sb $a1, 22($s1)
	j RevisarVictoria


J12:
	bnez $t4, Ocupado
	bnez $t0, O12

	X12:
	li $t4, 1
	sb $a1, 40($s1)
	j RevisarVictoria

	O12:
	li $t4, 2
	sb $a1, 40($s1)
	j RevisarVictoria
	

J22:
	bnez $t5, Ocupado
	bnez $t0, O22

	X22:
	li $t5, 1
	sb $a1, 44($s1)
	j RevisarVictoria

	O22:
	li $t5, 2
	sb $a1, 44($s1)
	j RevisarVictoria


J32:
	bnez $t6, Ocupado
	bnez $t0, O32

	X32:
	li $t6, 1
	sb $a1, 48($s1)
	j RevisarVictoria

	O32:
	li $t6, 2
	sb $a1, 48($s1)
	j RevisarVictoria
	

J13:
	bnez $t7, Ocupado
	bnez $t0, O13

	X13:
	li $t7, 1
	sb $a1, 66($s1)
	j RevisarVictoria

	O13:
	li $t7, 2
	sb $a1, 66($s1)
	j RevisarVictoria
	

J23:
	bnez $t8, Ocupado
	bnez $t0, O23

	X23:
	li $t8, 1
	sb $a1, 70($s1)
	j RevisarVictoria

	O23:
	li $t8, 2
	sb $a1, 70($s1)
	j RevisarVictoria
	

J33:
	bnez $t9, Ocupado
	bnez $t0, O33

	X33:
	li $t9, 1
	sb $a1, 74($s1)
	j RevisarVictoria

	O33:
	li $t9, 2
	sb $a1, 74($s1)
	j RevisarVictoria
	

Ocupado:                        	#Función para mostrar mensaje de que la posición mencionada esta siendo utlizada y lo devuelve a jugar
	beq $s4, 2, Ocupado2          	#Se valida si se decidio jugar contra el PC
	li $v0, 4                    	
	la $a0, espacioOcupado
	syscall
	j Jugar
	
	
Ocupado2:
	add $s6, $s6, 1               	#Contador que nos ayuda a saber cuantas veces a entrado a ocupado
	beq $s6, 2, Ocupado3          	#Si ha estado en ocpado mas de una vez se dirige a Ocupado3
	beq $t0, 0, OcupadoPC         	#Valida si es turno del PC, de lo contrario continua normal
	li $v0, 4                    	
	la $a0, espacioOcupado
	syscall
	j Jugar
	
	
Ocupado3:
	beq $t0, 0, Ocupado2PC        	#Se dirige a la otra funcion de ocupado del PC
	li $v0, 4                    	
	la $a0, espacioOcupado
	syscall
	j Jugar


RevisarVictoria:
	and $s7, $t1, $t2           	#And es utilizado para comparar los bits de 2 variables, en caso de que sean distintas
	and $s7, $s7, $t3           	#Guardara 0, y si son iguales guardara 1, esta es la razon de usar 1 y 2 en X y Y  
	bnez $s7, Victoria          	#En caso de ser diferente de 0 es una victoria y te desplaza a dicha función

	and $s7, $t4, $t5
	and $s7, $s7, $t6
	bnez $s7, Victoria

	and $s7, $t7, $t8
	and $s7, $s7, $t9
	bnez $s7, Victoria

	and $s7, $t1, $t4
	and $s7, $s7, $t7
	bnez $s7, Victoria

	and $s7, $t2, $t5
	and $s7, $s7, $t8
	bnez $s7, Victoria

	and $s7, $t3, $t6
	and $s7, $s7, $t9
	bnez $s7, Victoria

	and $s7, $t1, $t5
	and $s7, $s7, $t9
	bnez $s7, Victoria

	and $s7, $t7, $t5
	and $s7, $s7, $t3
	bnez $s7, Victoria
	
	j ImprimirTablero         	#En caso de no haber un ganador en este turno, devolvera a imprimir tablero
	

Victoria:
	li $v0, 4                	#En caso de entrar a victoria se imprime el tablero y el mensaje del ganador
	la $a0, tablero
	syscall

	li $v0, 4
	la $a0, ganar
	syscall
	j MenuJuegoNuevo          	#Por ultimo enviaremos al jugador al menu para preguntar si desea volver a jugar
	

Empate:
	li $v0, 4                 	#Se ingresa a esta función cuando hay un empate  porque se completaron todas las casillas
	la $a0, empate            	#Se imprime el mensaje empate
	syscall
	

MenuJuegoNuevo:                 
	li $v0,4
	la $a0, menuDeJuego           	#Se imprime mensaje del menú
	syscall

	li $v0,5                    	#Se pide dato de selección del jugador
	syscall
	bne $v0, 2, main

	li $v0, 10                  	#Termina el programa
	syscall
