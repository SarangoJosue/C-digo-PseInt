Proceso RiegoRabanoEstricto
	// 1. DECLARACIÓN DE VARIABLES 
	Definir historialVariables Como Real;
	Definir historialDecisiones Como Cadena;
	Definir opcionMenu, totalJornadas, contadorRiegos, i Como Entero;
	Definir techoMovilDesplegado, decidirRiego, decidirTecho Como Logico;
	Definir humedadIngresada, temperaturaIngresada, probabilidadLluvia Como Real;
	Definir humedadActual, temperaturaActual, lluviaActual Como Real;
	Definir sumaHumedad, sumaTemperatura Como Real;
	
	// Matriz de 11 filas por 4 columnas y Vector de 11 posiciones
	Dimension historialVariables[11,4];   
	Dimension historialDecisiones[11];      
	
	// Inicialización de variables de control
	opcionMenu <- 0;
	totalJornadas <- 0;
	contadorRiegos <- 0;
	techoMovilDesplegado <- Falso;
	
	// Ciclo Mientras: Controla el menú principal hasta seleccionar la opción 8
	Mientras opcionMenu <> 8 Hacer
		desplegarMenu;
		Escribir "Seleccione una opción: " Sin Saltar;
		Leer opcionMenu;
		
		// Condicional múltiple Segun para gestionar las opciones del menú
		Segun opcionMenu Hacer
			1:
				Si totalJornadas < 10 Entonces
					totalJornadas <- totalJornadas + 1;
					Escribir "--- REGISTRO DE LA JORNADA #", totalJornadas, " ---";
					
					// Ciclo Repetir...Hasta Que para validar Humedad (0% a 100%)
					Repetir
						Escribir "Ingrese la humedad del suelo (%): " Sin Saltar;
						Leer humedadIngresada;
						Si humedadIngresada < 0 O humedadIngresada > 100 Entonces
							Escribir "Error: La humedad debe estar entre 0% y 100%.";
						FinSi
					Hasta Que humedadIngresada >= 0 Y humedadIngresada <= 100;
					
					// Ciclo Repetir...Hasta Que para validar Temperatura (-10C a 60C)
					Repetir
						Escribir "Ingrese la temperatura ambiental (°C): " Sin Saltar;
						Leer temperaturaIngresada;
						Si temperaturaIngresada < -10 O temperaturaIngresada > 60 Entonces
							Escribir "Error: Temperatura fuera de rango razonable.";
						FinSi
					Hasta Que temperaturaIngresada >= -10 Y temperaturaIngresada <= 60;
					
					// Guardar en la matriz del historial (Base 1)
					historialVariables[totalJornadas, 1] <- humedadIngresada;
					historialVariables[totalJornadas, 2] <- temperaturaIngresada;
					historialVariables[totalJornadas, 3] <- 0; 
					historialDecisiones[totalJornadas] <- "Pendiente";
					Escribir "Datos ambientales registrados correctamente.";
				Sino
					Escribir "Historial lleno. No se pueden registrar más jornadas.";
				FinSi
				
			2:
				Si totalJornadas > 0 Entonces
					// Ciclo Repetir...Hasta Que para validar Probabilidad de Lluvia (0% a 100%)
					Repetir
						Escribir "Ingrese la probabilidad de lluvia para la jornada actual (%) [0-100]: " Sin Saltar;
						Leer probabilidadLluvia;
						Si probabilidadLluvia < 0 O probabilidadLluvia > 100 Entonces
							Escribir "Error: La probabilidad debe estar entre 0 y 100.";
						FinSi
					Hasta Que probabilidadLluvia >= 0 Y probabilidadLluvia <= 100;
					
					historialVariables[totalJornadas, 3] <- probabilidadLluvia;
					Escribir "Probabilidad de lluvia actualizada para la jornada actual.";
				Sino
					Escribir "Primero debe registrar variables ambientales en la opción 1.";
				FinSi
				
			3:
				// Subproceso para consultar el estado del cultivo
				consultarEstadoCultivo(historialVariables, totalJornadas, techoMovilDesplegado);
				
			4:
				Si totalJornadas > 0 Entonces
					humedadActual <- historialVariables[totalJornadas, 1];
					lluviaActual <- historialVariables[totalJornadas, 3];
					
					// Lógica integrada directa del Riego Automatizado
					Si humedadActual < 40 Y lluviaActual < 60 Entonces
						decidirRiego <- Verdadero;
					Sino
						decidirRiego <- Falso;
					FinSi
					
					Si decidirRiego Entonces
						Escribir "Resultado de Evaluación: [ACTIVAR BOMBA DE AGUA]";
						Escribir "Simulando: Bomba encendida. Regando cultivo de rábano...";
						historialDecisiones[totalJornadas] <- "Riego";
						
						Si historialDecisiones[totalJornadas] = "Riego" Entonces
							contadorRiegos <- contadorRiegos + 1;
						FinSi
					Sino
						Escribir "Resultado de Evaluación: [MANTENER BOMBA APAGADA]";
						Escribir "Simulando: El suelo tiene suficiente humedad o la probabilidad de lluvia es alta.";
						historialDecisiones[totalJornadas] <- "No Riego";
					FinSi
				Sino
					Escribir "No hay datos registrados en esta jornada para evaluar el riego.";
				FinSi
				
			5:
				Si totalJornadas > 0 Entonces
					temperaturaActual <- historialVariables[totalJornadas, 2];
					
					// Lógica integrada directa de temperatura del techo
					Si temperaturaActual > 30 Entonces
						decidirTecho <- Verdadero;
					Sino
						decidirTecho <- Falso;
					FinSi
					
					Si decidirTecho Entonces
						Escribir "Resultado de Evaluación: [DESPLEGAR TECHO PROTECTOR]";
						Si NO techoMovilDesplegado Entonces
							Escribir "Simulando servomotor: Desplegando lona para proteger el cultivo del calor excesivo...";
							techoMovilDesplegado <- Verdadero;
						Sino
							Escribir "El techo móvil ya se encuentra desplegado. No se repite la orden.";
						FinSi
					Sino
						Escribir "Resultado de Evaluación: [TECHO EN REPOSO / RETRAÍDO]";
						Si techoMovilDesplegado Entonces
							Escribir "Simulando servomotor: Retrayendo lona, temperatura ambiental óptima...";
							techoMovilDesplegado <- Falso;
						Sino
							Escribir "El mecanismo se mantiene en reposo.";
						FinSi
					FinSi
				Sino
					Escribir "No hay datos de temperatura para evaluar la protección del techo.";
				FinSi
				
			6:
				// Subproceso para mostrar el historial de decisiones
				presentarHistorialDecisiones(historialVariables, historialDecisiones, totalJornadas);
				
			7:
				Si totalJornadas > 0 Entonces
					
					sumaHumedad <- 0;
					sumaTemperatura <- 0;
					
					Escribir "====== ESTADÍSTICAS DEL SISTEMA DEL CULTIVO ======";
					Para i <- 1 Hasta totalJornadas Con Paso 1 Hacer
						sumaHumedad <- sumaHumedad + historialVariables[i, 1];
						sumaTemperatura <- sumaTemperatura + historialVariables[i, 2];
					FinPara
					
					Escribir "Jornadas evaluadas en total: ", totalJornadas;
					Escribir "Promedio de humedad registrado: ", (sumaHumedad / totalJornadas), "%";
					Escribir "Promedio de temperatura ambiental: ", (sumaTemperatura / totalJornadas), " °C";
					Escribir "Cantidad de veces que se activó la bomba de riego: ", contadorRiegos;
					Escribir "==================================================";
				Sino
					Escribir "No existen registros guardados para generar estadísticas.";
				FinSi
				
			8:
				Escribir "Finalizando la simulación telemática de riego. ¡Hasta pronto!";
				
			De Otro Modo:
				Escribir "Opción inválida. Intente de nuevo.";
		FinSegun
		Escribir ""; 
	FinMientras
FinProceso

// ============================================================================
// 3. SUBPROCESOS
// ============================================================================

SubProceso desplegarMenu
	Escribir "==================================================";
	Escribir "     SISTEMA TELEMÁTICO DE RIEGO - RÁBANO         ";
	Escribir "==================================================";
	Escribir "1. Registrar humedad del suelo y cond. ambientales";
	Escribir "2. Registrar o ingresar probabilidad de lluvia";
	Escribir "3. Consultar el estado del cultivo";
	Escribir "4. Evaluar y simular el riego automático";
	Escribir "5. Evaluar y simular la protección mediante techo móvil";
	Escribir "6. Consultar historial de decisiones";
	Escribir "7. Mostrar estadísticas de riego y cond. registradas";
	Escribir "8. Finalizar el programa";
	Escribir "==================================================";
FinSubProceso

SubProceso consultarEstadoCultivo(historialVariables Por Referencia, totalJornadas, techoMovilDesplegado)
	Si totalJornadas > 0 Entonces
		Escribir "====== ESTADO ACTUAL DEL CULTIVO DE RÁBANO ======";
		Escribir "Última Humedad del Suelo registrada: ", historialVariables[totalJornadas, 1], "%";
		Escribir "Última Temperatura Ambiental registrada: ", historialVariables[totalJornadas, 2], " °C";
		Escribir "Última Probabilidad de Lluvia guardada: ", historialVariables[totalJornadas, 3], "%";
		Si techoMovilDesplegado Entonces
			Escribir "Estado del Techo Móvil: [DESPLEGADO - PROTEGIENDO]";
		Sino
			Escribir "Estado del Techo Móvil: [RETRAÍDO - EXPOSICIÓN NORMAL]";
		FinSi
		Escribir "=================================================";
	Sino
		Escribir "No se han capturado lecturas de sensores aún.";
	FinSi
FinSubProceso

SubProceso presentarHistorialDecisiones(historialVariables Por Referencia, historialDecisiones Por Referencia, totalJornadas)
	Definir k Como Entero;
	Si totalJornadas > 0 Entonces
		Escribir "==================== HISTORIAL DE JORNADAS Y DECISIONES ====================";
		Escribir "Jornada | Humedad | Temperatura | Prob. Lluvia | Acción de Riego";
		Escribir "----------------------------------------------------------------------------";
		Para k <- 1 Hasta totalJornadas Con Paso 1 Hacer
			Escribir "   ", k, "    |   ", historialVariables[k, 1], "%   |    ", historialVariables[k, 2], " °C    |     ", historialVariables[k, 3], "%     |   ", historialDecisiones[k];
		FinPara
		Escribir "============================================================================";
	Sino
		Escribir "El historial se encuentra vacío temporalmente.";
	FinSi
FinSubProceso

