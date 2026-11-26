
package codigo.java.proyecto;

/**
 *
 * @author Acer
 */

import java.util.Scanner;

public class CodigoJavaProyecto {

    static Scanner teclado = new Scanner(System.in);

    // Declaracion de variables
    static double[][] historialVariables = new double[10][4];
    static String[] historialDecisiones = new String[10];

    static int opcionMenu = 0;
    static int totalJornadas = 0;
    static int contadorRiegos = 0;

    static boolean techoMovilDesplegado = false;

    static double humedadIngresada;
    static double temperaturaIngresada;
    static double probabilidadLluvia;

    static double humedadActual;
    static double temperaturaActual;
    static double lluviaActual;

    static double sumaHumedad;
    static double sumaTemperatura;

    public static void main(String[] args) {

        // Inicializacion del historial
        for (int i = 0; i < 10; i++) {
            historialDecisiones[i] = "Pendiente";
        }

        // Menu principal
        while (opcionMenu != 8) {

            desplegarMenu();

            System.out.print("Seleccione una opcion: ");
            opcionMenu = leerEntero();

            switch (opcionMenu) {

                case 1:

                    if (totalJornadas < 10) {

                        totalJornadas++;

                        System.out.println("--- REGISTRO DE LA JORNADA #"
                                + totalJornadas + " ---");

                        // Validacion de humedad
                        do {
                            System.out.print(
                                    "Ingrese la humedad del suelo (%): ");

                            humedadIngresada = leerReal();

                            if (humedadIngresada < 0
                                    || humedadIngresada > 100) {
                                System.out.println(
                                        "Error: La humedad debe estar entre 0% y 100%.");
                            }

                        } while (humedadIngresada < 0
                                || humedadIngresada > 100);

                        // Validacion de temperatura
                        do {
                            System.out.print(
                                    "Ingrese la temperatura ambiental (°C): ");

                            temperaturaIngresada = leerReal();

                            if (temperaturaIngresada < -10
                                    || temperaturaIngresada > 60) {
                                System.out.println(
                                        "Error: Temperatura fuera de rango razonable.");
                            }

                        } while (temperaturaIngresada < -10
                                || temperaturaIngresada > 60);

                        // Guardar datos en la matriz
                        int posicion = totalJornadas - 1;

                        historialVariables[posicion][0] = humedadIngresada;
                        historialVariables[posicion][1] = temperaturaIngresada;
                        historialVariables[posicion][2] = 0;

                        historialDecisiones[posicion] = "Pendiente";

                        System.out.println(
                                "Datos ambientales registrados correctamente.");

                    } else {
                        System.out.println(
                                "Historial lleno. No se pueden registrar mas jornadas.");
                    }

                    break;

                case 2:

                    if (totalJornadas > 0) {

                        do {
                            System.out.print(
                                    "Ingrese la probabilidad de lluvia (%) [0-100]: ");

                            probabilidadLluvia = leerReal();

                            if (probabilidadLluvia < 0
                                    || probabilidadLluvia > 100) {
                                System.out.println(
                                        "Error: La probabilidad debe estar entre 0 y 100.");
                            }

                        } while (probabilidadLluvia < 0
                                || probabilidadLluvia > 100);

                        historialVariables[totalJornadas - 1][2]
                                = probabilidadLluvia;

                        System.out.println(
                                "Probabilidad de lluvia actualizada.");

                    } else {
                        System.out.println(
                                "Primero debe registrar variables ambientales en la opcion 1.");
                    }

                    break;

                case 3:

                    consultarEstadoCultivo();

                    break;

                case 4:

                    if (totalJornadas > 0) {

                        humedadActual =
                                historialVariables[totalJornadas - 1][0];

                        lluviaActual =
                                historialVariables[totalJornadas - 1][2];

                        boolean decidirRiego;

                        // Evaluacion del riego
                        if (humedadActual < 40 && lluviaActual < 60) {
                            decidirRiego = true;
                        } else {
                            decidirRiego = false;
                        }

                        if (decidirRiego) {

                            System.out.println(
                                    "Resultado: ACTIVAR BOMBA DE AGUA");

                            System.out.println(
                                    "Simulando: Bomba encendida. Regando cultivo de rabano...");

                            historialDecisiones[totalJornadas - 1] = "Riego";

                            contadorRiegos++;

                        } else {

                            System.out.println(
                                    "Resultado: MANTENER BOMBA APAGADA");

                            System.out.println(
                                    "El suelo tiene suficiente humedad o la probabilidad de lluvia es alta.");

                            historialDecisiones[totalJornadas - 1] = "No Riego";
                        }

                    } else {
                        System.out.println(
                                "No hay datos registrados para evaluar el riego.");
                    }

                    break;

                case 5:

                    if (totalJornadas > 0) {

                        temperaturaActual =
                                historialVariables[totalJornadas - 1][1];

                        boolean decidirTecho;

                        // Evaluacion de temperatura
                        if (temperaturaActual > 30) {
                            decidirTecho = true;
                        } else {
                            decidirTecho = false;
                        }

                        if (decidirTecho) {

                            System.out.println(
                                    "Resultado: DESPLEGAR TECHO PROTECTOR");

                            if (!techoMovilDesplegado) {

                                System.out.println(
                                        "Simulando servomotor: Desplegando lona para proteger el cultivo.");

                                techoMovilDesplegado = true;

                            } else {

                                System.out.println(
                                        "El techo movil ya se encuentra desplegado.");
                            }

                        } else {

                            System.out.println(
                                    "Resultado: TECHO EN REPOSO / RETRAIDO");

                            if (techoMovilDesplegado) {

                                System.out.println(
                                        "Simulando servomotor: Retrayendo lona.");

                                techoMovilDesplegado = false;

                            } else {

                                System.out.println(
                                        "El mecanismo se mantiene en reposo.");
                            }
                        }

                    } else {
                        System.out.println(
                                "No hay datos de temperatura para evaluar el techo.");
                    }

                    break;

                case 6:

                    presentarHistorialDecisiones();

                    break;

                case 7:

                    if (totalJornadas > 0) {

                        sumaHumedad = 0;
                        sumaTemperatura = 0;

                        System.out.println(
                                "====== ESTADISTICAS DEL SISTEMA ======");

                        for (int i = 0; i < totalJornadas; i++) {

                            sumaHumedad += historialVariables[i][0];

                            sumaTemperatura += historialVariables[i][1];
                        }

                        System.out.println(
                                "Jornadas evaluadas: " + totalJornadas);

                        System.out.println(
                                "Promedio de humedad: "
                                + (sumaHumedad / totalJornadas) + "%");

                        System.out.println(
                                "Promedio de temperatura: "
                                + (sumaTemperatura / totalJornadas) + " °C");

                        System.out.println(
                                "Veces que se activo la bomba: "
                                + contadorRiegos);

                        System.out.println(
                                "======================================");

                    } else {

                        System.out.println(
                                "No existen registros para generar estadisticas.");
                    }

                    break;

                case 8:

                    System.out.println(
                            "Finalizando el sistema de riego. ¡Hasta pronto!");

                    break;

                default:

                    System.out.println(
                            "Opcion invalida. Intente de nuevo.");
            }

            System.out.println();
        }

        teclado.close();
    }

    // Metodo para mostrar el menu
    public static void desplegarMenu() {

        System.out.println("==================================================");
        System.out.println("       SISTEMA TELEMATICO DE RIEGO - RABANO");
        System.out.println("==================================================");
        System.out.println("1. Registrar humedad y condiciones ambientales");
        System.out.println("2. Registrar probabilidad de lluvia");
        System.out.println("3. Consultar estado del cultivo");
        System.out.println("4. Evaluar y simular el riego automatico");
        System.out.println("5. Evaluar proteccion mediante techo movil");
        System.out.println("6. Consultar historial de decisiones");
        System.out.println("7. Mostrar estadisticas");
        System.out.println("8. Finalizar el programa");
        System.out.println("==================================================");
    }

    // Metodo para consultar el estado del cultivo
    public static void consultarEstadoCultivo() {

        if (totalJornadas > 0) {

            int posicion = totalJornadas - 1;

            System.out.println(
                    "====== ESTADO ACTUAL DEL CULTIVO ======");

            System.out.println(
                    "Humedad del suelo: "
                    + historialVariables[posicion][0] + "%");

            System.out.println(
                    "Temperatura ambiental: "
                    + historialVariables[posicion][1] + " °C");

            System.out.println(
                    "Probabilidad de lluvia: "
                    + historialVariables[posicion][2] + "%");

            if (techoMovilDesplegado) {

                System.out.println(
                        "Estado del techo: DESPLEGADO - PROTEGIENDO");

            } else {

                System.out.println(
                        "Estado del techo: RETRAIDO - EXPOSICION NORMAL");
            }

            System.out.println(
                    "======================================");

        } else {

            System.out.println(
                    "No se han registrado datos ambientales.");
        }
    }

    // Metodo para presentar el historial
    public static void presentarHistorialDecisiones() {

        if (totalJornadas > 0) {

            System.out.println(
                    "================ HISTORIAL DE JORNADAS ================");

            System.out.println(
                    "Jornada | Humedad | Temperatura | Prob. Lluvia | Riego");

            for (int i = 0; i < totalJornadas; i++) {

                System.out.println(
                        (i + 1) + "       | "
                        + historialVariables[i][0] + "%     | "
                        + historialVariables[i][1] + " °C       | "
                        + historialVariables[i][2] + "%       | "
                        + historialDecisiones[i]);
            }

            System.out.println(
                    "=======================================================");

        } else {

            System.out.println(
                    "El historial se encuentra vacio.");
        }
    }

    // Metodo para leer numeros enteros
    public static int leerEntero() {

        while (!teclado.hasNextInt()) {

            System.out.println("Ingrese un numero entero valido.");

            teclado.next();
        }

        int numero = teclado.nextInt();

        return numero;
    }

    // Metodo para leer numeros reales
    public static double leerReal() {

        while (!teclado.hasNextDouble()) {

            System.out.println("Ingrese un numero valido.");

            teclado.next();
        }

        double numero = teclado.nextDouble();

        return numero;
    }
}
