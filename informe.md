# Resumen

En el siguiente trabajo se han implementado diferentes mecanismos de exclusión mutua para posteriormente compararlos tanto a nivel se consumo energético como a nivel de rendimiento sobre la arquitectura ARMv8-A de 64 bits (AARCH64), concretamente en una Raspberry Pi 3 model B ejecutando el sistema operativo Debian de 64 bits.

Las implementaciones creadas han sido un fetch and add y un spin lock simple, garantizando la atomicidad de los procedimientos con las instrucciones ldaxr y stlxr. Por otra parte, se implementó un spin lock energéticamente eficiente basado en el simple pero en caso de no poder adquirirse el lock, cambia al procesador a modo  de bajo consumo energético mediante la instrucción wfe. A partir de esta implementación se creó una optimización que en vez de hacer uso de instrucciones que manejan 32 bits como ldaxr y stlxr, se utilizan instrucciones que manejaban 8 bits, ldaxrb y stlxrb, para de esta forma ahorrar energía al tener que transportar menos bits en las operaciones. Por último a partir de esta versión se creo otra en la cual el spin unlock estaba optimizado.

Utilizando estos spin locks, se crearon diferentes versiones de mutex, así como dos aplicaciones para poder medir su rendimiento. La primera realiza una reducción de un vector a un escalar de una forma poco eficiente para hacer un gran uso de los mutex. La segunda esta específicamente diseñada para probar el rendimiento de los mutex en un caso de uso intensivo. En esta, los diferentes threads lucharán por un recurso compartido utilizando los mutex para garantizar la exclusión. En este benchmark existen dos opciones de ejecución, una en la cual la sección critica es la mínima imprescindible y otra en la que es muy extensa.

Tras realizar pruebas en base al benchmark de uso intensivo para los distintos mutex, y analizarse los resultados, se obtuvo que en cuestión de rendimiento en tiempo en una sección crítica corta, el mutex energéticamente eficiente es un 1% más lento que el mutex simple, y en el caso de una sección crítica larga, esta diferencia se agranda a un 3%, por otro lado no se ha notado mejora en el rendimiento en la versión que sólo utiliza instrucciones de memoria de 8 bits respecto a la versión que usa de 32 bits. La versión que utiliza loads y stores de bytes optimizados (3ra versión del spin lock energéticamente eficiente), si que se aprecia un aumento de rendimiento, llegando a ser mucho más rápido que el spin lock simple e incluso que el nativo de C++. En el caso de una sección crítica larga, el spin lock simple es más rápido que todas la versiones energéticamente eficientes, incluso que la versión que utiliza loads y stores de bytes optimizados (3ra versión del spin lock energéticamente eficiente). En este escenario no se ha podido confirmar el tiempo de ejecución del mutex nativo de C++ debido a que utiliza llamadas al sistema operativo, lo que hace que durante las esperas al lock no esté en ejecución el hilo.

Al realizar pruebas de energía, solamente se utilizo la versión con una sección crítica larga. En ella los mutex energéticamente eficientes poseían un consumo similar, y las diferencias en el consumo total de estos sólo era marcado por el tiempo de ejecución. Tras comparar el consumo total de la placa (todos los componentes más el teclado que tenía conectado, no sólo el procesador) entre el mutex energéticamente eficiente y el mutex simple, se puedo comprobar como este último consume un 28% más de energía durante toda la ejecución. Si se procesan los datos para intentar obtener la fracción de ese consumo que se le puede atribuir a la ejecución de la prueba, restándole el consumo que se midió del sistema operativo sin ninguna tarea de usuario lanzada, se puede obtener que el spin lock simple consume un 199% mas de energía que el energéticamente eficiente.

Por ello para un sistema empotrado en el cual la administración de la energía consumida es importante, la opción de mutex energéticamente eficiente ha de ser siempre elegida respecto a la de mutex simple debido a que el 3% de aumento de rendimiento en cuanto a tiempo que implica un mutex simple, no justifica el 199% más de consumo que este posee.

 

# Introducción

En el siguiente trabajo se han implementado diferentes mecanismos de exclusión mutua para posteriormente compararlos tanto a nivel se consumo energético como a nivel de rendimiento en la arquitectura ARMv8 de 64 bits (AARCH64). Por un lado se ha implementado un spin lock simple y diferentes versiones energéticamente eficiente y por otro lado se ha implementado la primitiva fetch and add. 

Sobre todos ellos se han realizado test unitarios para comprobar su correcto funcionamiento.

Por otro lado, se a realizado una comparativa de rendimiento y eficiencia energética sobre cinco mutex creados sobre las implementaciones del spin lock simple y los diferentes tipos de spin lock energéticamente eficientes, así como el mutex el proporcionado por la librería estándar del lenguaje C++.

 

# Entorno de pruebas utilizado

Las pruebas se han realizado sobre una Raspberry Pi 3 model B. Para poder utilizar las instrucciones nativas de este procesador se instaló una versión de Debian de 64 bits y ARMv8-A ya que el Raspbian nativo, por mantener retrocompatibilidad no posee estas características sino que utiliza ARMv7 de 32 bits.

### Instalación de Debian

El sistema instalado fue el siguiente:

https://github.com/Debian/raspi3-image-spec.

En el propio proyecto de Github aparecen instrucciones para su instalación.

# Entorno de compilación utilizado

Para realizarse los experimentos se ha realizado compilación cruzada utilizado el compilador AARCH64 de linaro con soporte a Linux, el cual se puede encontrar en la página oficial de ARM con el nombre aarch64-linux-gnu.

https://developer.arm.com/open-source/gnu-toolchain/gnu-a/downloads

 

# Implementación y explicación del Fetch And Add

La implementación que se ha creado de la primitiva fetch and add es la siguiente:

``` asm
fetch_and_add:               // Function "fetch_and_add" entry point.
     ldaxr w2, [x0]
     add w4, w1, w2
     stlxr w3, w4, [x0]
     cbnz w3, fetch_and_add
     mov w0, w2              // Return the value before execute fetch_and_add
     ret                     // Return by branching to the address in the link register.
```

En ella nos aseguramos de repetir la operación tantas veces sea necesario hasta que se realiza un fetch and add en exclusión mutua (solamente se hace efectivo el resultado de la que se realiza en exclusión mutua).

 

# Implementación y explicación de los Spin Lock

## Spin Lock simple

La implementación que se ha creado de la primitiva spin lock es la siguiente:

``` asm
spin_lock:                 // Function "spin_lock" entry point.
     mov w3, #1
spin_lock_loop:       
     ldaxr w1, [x0]
     cmp w1, #0
     bne spin_lock_loop
     stlxr w2, w3, [x0]
     cbnz w2, spin_lock_loop   
     ret                  // Return by branching to the address in the link register.
```

En ella se posee el comportamiento típico de un spin lock, en el cual se intenta obtener un lock sobre una variable, y en caso de que no se pueda, se vuelve a intentar. Para ello se han usado las instrucciones ldaxrn y stlxr, que en el momento de leer la variable adquieren un token de exclusividad, que produce que si antes de una escritura por este hilo, otro hilo ha escrito, esta falla, en caso contrario realiza la escritura y se libera el token.

La implementación que se ha creado de la primitiva spin unlock es la siguiente:

``` asm
spin_unlock:                   // Function "spin_unlock" entry point.
     mov w1, #0
spin_unlock_loop:
     ldaxr w2, [x0]              // Needed to perform later stlxr w2, w1, [x0]
     stlxr w2, w1, [x0]          // Store 0 in the spin_lock variable
     cbnz w2, spin_unlock_loop   // This will be taken if a context change happens between ldaxr and stlxr. 
     ret                         // Return by branching to the address in the link register.
```

En ella el comportamiento es el típico de un spin unlock salvo porque se usan para desbloquearlo las primitivas ldaxrn y stlxr. El bucle de comprobación sobre el estado de la escritura es necesario debido a que entre la instrucción de lectura y la de escritura puede suceder un cambio de contexto. En ese caso se pierde el token de exclusividad y falla la escritura.

 

## Spin Lock energéticamente eficiente

La implementación que se ha creado de la primitiva spin lock es la siguiente:

``` asm
spin_lock_ee:              // Function "spin_lock" entry point.
     // send ourselves an event, so we don't stick on the wfe at the
     // top of the loop
     mov w3, #1
     sevl
spin_lock_ee_loop:
     wfe
     ldaxr w1, [x0]
     cmp w1, #0
     bne spin_lock_ee_loop
     stlxr w2, w3, [x0]
     cbnz w2, spin_lock_ee_loop   
     ret                  // Return by branching to the address in the link register.
```

La implementación se basa en el spin lock anterior, pero en este caso una vez fallada la obtención de la exclusividad se coloca el procesador en modo de ahorro de energía con la instrucción wfe hasta que el hilo que posea la exclusividad sobre la variable la libere.

La implementación que se ha creado de la primitiva spin unlock es idéntica al caso anterior, ya que en el momento que se produce una escritura sobre la variable con la instrucción stlxr, se envía un evento que saca a los núcleos del modo ahorro de energía.

 

## Spin Lock energéticamente eficiente utilizando instrucciones de memoria de bytes

La implementación que se ha creado de la primitiva spin lock es la siguiente:
``` asm
spin_lock_ee_b:              // Function "spin_lock" entry point.
     // send ourselves an event, so we don't stick on the wfe at the
     // top of the loop
     mov w3, #1
     sevl
spin_lock_ee_loop:
     wfe
     ldaxrb w1, [x0]
     cmp w1, #0
     bne spin_lock_ee_loop
     stlxrb w2, w3, [x0]
     cbnz w2, spin_lock_ee_loop   
     ret                  // Return by branching to the address in the link register.
```

La implementación que se ha creado de la primitiva spin unlock es la siguiente:

``` asm
spin_unlock_ee_b:                  // Function "spin_unlock" entry point.
     mov w1, #0
spin_unlock_loop_ee:
     ldaxrb w2, [x0]               // Needed to perform later stlxr w2, w1, [x0]
     stlxrb w2, w1, [x0]           // Store 0 in the spin_lock variable and automatic send sev
     cbnz w2, spin_unlock_loop_ee // This will be taken if a context change happens between ldaxr and stlxr. Read proyect README for more info
     ret     
```
Las implementaciones son idénticas al caso anterior salvo porque las instrucciones ldaxr y stlxr han sido sustituidas por las instrucciones que trabajan con bytes ldaxrb y stlxrb. Esta optimización pretende ahorrar energía y tiempo al tener que transportar solamente un byte en vez de 4 de la implementación anterior.

 

## Spin Lock energéticamente eficiente utilizando instrucciones de memoria de bytes optimizada

Esta versión se ha basado en la anterior y solamente se ha modificado el spin unlock que ha quedado de la siguiente forma:

``` asm
spin_unlock_ee_b_ne:              // Function "spin_unlock" entry point.
     mov w1, #0
     strb w1, [x0]                // Store 0 in the spin_lock variable
     sev                          // Send sev
     ret                          // Return by branching to the address in the link register.
```

En el se ha eliminado el bucle que se necesitaba en el spin unlock, al realizar la escritura con la instrucción strb. En este caso sería necesario enviar un evento con sev para poder despertar al resto de hilos.

 

# Creación de mutex basados en los Spin-Lock

La implementación de los mutex basados en los diferentes tipos de spin locks es igual en todos los casos:

``` c
// spin_lock.cpp

extern "C" void spin_lock(int *x);
extern "C" void spin_unlock(int *x);

mutex::mutex() : lock_variable(0) {}

void mutex::lock() {
    spin_lock(&lock_variable);
}

void mutex::unlock() {
    spin_unlock(&lock_variable);
}
```

En ella se llama a spin lock sobre una variable al hacer el lock del mutex y a spin unlock sobre la misma al realizar el unlock.

Para poder utilizar los distintos tipos de mutex en los programas de pruebas de una forma sencilla, al todos poseer la misma interfaz, se ha creado un interfaz que en tiempo de compilación permite seleccionar que tipo de mutex se desea usar, el cual es la siguiente:

``` c++
/**
 * Different mutex types to select
 */
#ifndef SELECTED_MUTEX_TYPE
#error "SELECTED_MUTEX_TYPE must be defined"
#endif

#if SELECTED_MUTEX_TYPE == MUTEX_NAIVE

#include <mutex>

#endif

#if SELECTED_MUTEX_TYPE == MUTEX_SPIN_LOCK
#include "../spin_lock/lib/mutex_spin_lock.h"
#endif

#if SELECTED_MUTEX_TYPE == MUTEX_SPIN_LOCK_EE
#include "../spin_lock_ee/lib/mutex_spin_lock_ee.h"
#endif

#if SELECTED_MUTEX_TYPE == MUTEX_SPIN_LOCK_EE_B
#include "../spin_lock_ee_b/lib/mutex_spin_lock_ee_b.h"
#endif

#if SELECTED_MUTEX_TYPE == MUTEX_SPIN_LOCK_EE_B_NE
#include "../spin_lock_ee_b_ne/lib/mutex_spin_lock_ee_b_ne.h"
#endif

#if SELECTED_MUTEX_TYPE == MUTEX_NONE
class mutex{
public:
    void lock(){ asm("nop"); }
    void unlock(){ asm("nop"); }
};
#endif
```

En él se puede seleccionar o uno de los tipos de mutex creados, el nativo de C++, o no seleccionar ningún tipo de mutex, en este caso el lock y el unlock se sustituirán por nops.

 

# Implementación y explicación de los programas de pruebas

## Reduce2D

El programa Reduce2D, realiza una reducción de un vector a un escalar en multithread mediante suma de las componentes. Esta suma de hace de una forma muy poco eficiente para hacer un gran uso de los mutex.

Su implementación es la siguiente:
``` c++
/**
 * Made a sum reduction over elements in v
 * v -> Vector over reduction will be done
 * n -> Number of elements of v
 */
int Reduce2D::parSum(int v[], unsigned int n) {
    mutex mutex_variable;
    int global_result = 0;
    thread *thread_pool[NUMBER_OF_THREADS];

    unsigned int work_for_thread[NUMBER_OF_THREADS];

    unsigned int thread_start_position[NUMBER_OF_THREADS];

    unsigned int work_left = n;

    /**
     * Calculate the work for every thread
     */
    for (unsigned int i = NUMBER_OF_THREADS; i >= 1; i--) {
        work_for_thread[i - 1] = work_left / i;
        work_left = work_left - (work_left / i);
        thread_start_position[i - 1] = work_left;
    }


    /**
     * Create threads
     */
    for (unsigned int i = 0; i < NUMBER_OF_THREADS; i++) {
        thread_pool[i] = new thread(thread_sum, &v[thread_start_position[i]], work_for_thread[i],
                                    ref(mutex_variable), ref(global_result));
    }

    /**
     * Wait for threads and delete
     */
    for (unsigned int i = 0; i < NUMBER_OF_THREADS; i++) {
        thread_pool[i]->join();
        delete thread_pool[i];
    }

    return global_result;
}

/**
 * n -> number of elements to process by the thread
 */
void Reduce2D::thread_sum(int v[], unsigned int n, mutex &mtx, int &global_variable) {
    for (int i = 0; i < n; ++i) {
        // Mux lock
        mtx.lock();

        global_variable = global_variable + v[i];

        // Mux unlock
        mtx.unlock();
    }
}
```

 

## Mutex benchmark

El programa mutex benchmark se ha creado con la intención de evaluar los mutex en un escenario de uso intensivo. En él, los diferentes threads lucharán por un recurso compartido utilizando los mutex para ello. Existen dos opciones de compilación, en la primera se crea una sección crítica muy larga, y en la segunda una corta en la que se ha reducido el tiempo de computación de labores distintas al uso de los mutex, al mínimo imprescindible.

Su implementación es la siguiente:

``` c++
mutex mtx;

/**
 * Critical section types
 */
#define CRITICAL_SECTION_SHORT 0
#define CRITICAL_SECTION_LONG 1

#if SELECTED_CRITICAL_SECTION == CRITICAL_SECTION_SHORT
#define TEST_SIZE 1000000
int variable_to_set;
void __attribute__((optimize("O0"))) critical_section(int thread_number){
    variable_to_set = thread_number;
}
#endif

#if SELECTED_CRITICAL_SECTION == CRITICAL_SECTION_LONG
#define TEST_SIZE 10000
#define SIZE_OVERHEAD_LOOP 3000
int variable_to_set;
void __attribute__((optimize("O0"))) critical_section(int thread_number){
    for(int j = 0; j < SIZE_OVERHEAD_LOOP; ++j){
        variable_to_set = thread_number;
    }
}
#endif

/**
 * Work that every thread do
 */
void thread_work(int thread_number){
    for (int i = 0; i < TEST_SIZE; ++i) {
        mtx.lock();
        critical_section(thread_number);
        mtx.unlock();
    }
}

/**
 * Competition over threads to be the last in write over a variable
 * @return
 */
int main() {
    thread *thread_pool[NUMBER_OF_THREADS];

    clock_t begin = clock();

    /**
     * Create threads
     */
    for (unsigned int i = 0; i < NUMBER_OF_THREADS; i++) {
        thread_pool[i] = new thread(thread_work, i);
    }

    /**
     * Wait for threads and delete
     */
    for (unsigned int i = 0; i < NUMBER_OF_THREADS; i++) {
        thread_pool[i]->join();
        delete thread_pool[i];
    }

    clock_t end = clock();
    double elapsed_secs = double(end - begin) / CLOCKS_PER_SEC;

    // CPU time taken
    cout << elapsed_secs << endl;

    return 0;
}
```

 

# Implementación y explicación del script para obtención de métricas de rendimiento

Este script ejecuta el programa mutex benchmark para las diferentes implementaciones un número definido de iteraciones y evalúa su rendimiento. Para ello crea un fichero csv en el que almacena el resultado de cada una de las iteraciones para un posterior análisis, así como obtiene la media de las ejecuciones de cada implementación en un fichero aparte. Para usarlo, primero se han de compilar las diferentes implementaciones mediante el fichero Makefile y posteriormente se ha de colocar el script en la carpeta build.

Actualmente está configurado para medir el rendimiento del programa mutex benchmark con sección crítica corta.

Su implementación es la siguiente:

``` sh
#
# Script that launch all threads competitions and obtain the averange performance
#

# File where metrics(averange) results will be stored 
RESULTS_FILE="./results_avg_short_cs.txt"

# File where all results will be stored in seconds
ALL_RESULTS_FILE_CSV="./results_short_cs.csv"

# Number of iterations
NUMBER_OF_ITERATIONS=10

# Seconds to sleep between iterations to decrease board temperature
TIME_TO_SLEEP_BETWEEN_ITERARIONS=4

# Files that you want to test
FILES_TO_TEST=(
    mutex_benchmark_naive_mutex_short_cs_o3_e 
    mutex_benchmark_none_mutex_short_cs_o3_e
    mutex_benchmark_spin_lock_short_cs_o3_e 
    mutex_benchmark_spin_lock_ee_short_cs_o3_e
    mutex_benchmark_spin_lock_ee_b_short_cs_o3_e
    mutex_benchmark_spin_lock_ee_b_ne_short_cs_o3_e
)

# Store the averange performance results
declare -A performance_results_avg

# Empty ALL_RESULTS_FILE_CSV if exists and create if not
> $ALL_RESULTS_FILE_CSV

# Initialize the hash map and init ALL_RESULTS_FILE_CSV
for application in ${FILES_TO_TEST[*]}
do
    performance_results_avg[$application]=0
    echo -n "$application;" >> $ALL_RESULTS_FILE_CSV
done

# Prepare to write results
echo >> $ALL_RESULTS_FILE_CSV

# Execute the applications to get the metrics
for i in $(seq 1 $NUMBER_OF_ITERATIONS)
do
    echo "---------------- Iteration $i of $NUMBER_OF_ITERATIONS ----------------" 

	for application in ${FILES_TO_TEST[*]}
    do
        echo "Executing $application"
        iteration_result=$("./$application")
        echo -n "$iteration_result;" >> $ALL_RESULTS_FILE_CSV
        # Utility bc is not installed so we need to use awk
        performance_results_avg[$application]=$(echo - | awk "{print ${performance_results_avg[$application]} + $iteration_result}")
        # performance_results_avg[$application]=$(echo "${performance_results_avg[$application]} + $iteration_result" | bc)
        sleep $TIME_TO_SLEEP_BETWEEN_ITERARIONS
    done

    # Prepare to write next results
    echo >> $ALL_RESULTS_FILE_CSV

    echo
done

# Init RESULTS_FILE
echo "Test done on" > $RESULTS_FILE
date >> $RESULTS_FILE
echo "" >> $RESULTS_FILE

# Write averange to RESULTS_FILE
echo "Averange execution time (seconds)" >> $RESULTS_FILE
for application in ${FILES_TO_TEST[*]}
do
    actual_performance=$(echo - | awk "{print ${performance_results_avg[$application]} / $NUMBER_OF_ITERATIONS}")
    echo "$application: $actual_performance" >> $RESULTS_FILE
done
```

 

# Evaluación de rendimiento

La evaluación de rendimiento se realizó sobre el entorno de pruebas que se describió al principio del informe, con el sistema operativo en estado de ejecución nº1 y utilizando el programa mutex benchmark comentado anteriormente, y para almacenar los resultados se utilizó el script performance_mutex_benchmark.sh también comentado anteriormente.

## Tiempo

Tras 30 iteraciones realizadas en el script performance_mutex_benchmark.sh configurado para ejecutar el benchmark con región crítica corta, se obtuvieron los siguientes resultados. Todos ellos se expresan en segundos y son relativos al tiempo de uso del procesador en las diferentes versiones de las implementaciones del mutex, esto es para evitar contar en todo lo posible tiempo que el sistema operativo dedica a otras tareas. Al poseer 4 núcleos el sistema, el tiempo de ejecución es mucho menor al de uso del procesador.

| Versión | Sin mutex | Mutex Nativo C++ | Spin lock simple | Spin lock EE |
|-------------|-------------|-----|-------------|-------------|
| media (s) | 0.4267 | 14.6513 | 17.3540 | 17.5425 |
| desviación típica (s) | 0.0014 | 0.0455 | 0.5489 | 0.5003 |
| mínimo (s) | 0.4259 | 14.5592 | 16.5428 | 16.3294 |
| máximo (s) | 0.4320 | 14.7715 | 18.6714 | 18.7380 | 

| Versión | Spin lock EE IM B | Spin lock EE IM B opt |
|-------------|-----|-----|
| media (s) | 17.7751 | 14.3856 |
| desviación típica (s) | 0.6902 | 0.5441 |
| mínimo (s)  | 16.2221 | 13.1974 |
| máximo (s)  | 19.0890 | 15.3787 |

Spin lock EE representa el spin lock energéticamente eficiente, Spin lock EE IM bytes representa el Spin lock energéticamente eficiente usando instrucciones de memoria de bytes y Spin lock EE IM B opt representa el Spin lock energéticamente eficiente usando instrucciones de memoria de bytes optimizado.

Como se puede comprobar, en media el más rápido es el spin lock energéticamente eficiente con instrucciones de memoria de bytes y optimizando los spin unlock, pero su desviación típica es bastante elevada. Por otro lado se puede ver como el spin lock simple posee mejor rendimiento que el spin lock energéticamente eficiente.

Tras dos iteraciones realizadas en el script performance_mutex_benchmark.sh configurado para ejecutar el benchmark con región crítica larga, se obtuvieron los siguientes resultados. Todos ellos se expresan en segundos y son relativos al tiempo de uso del procesador en las diferentes versiones de las implementaciones del mutex.

| Versión | Sin mutex | Mutex Nativo C++ | Spin lock simple | Spin lock EE |
|-------------|-------------|-----|-------------|-------------|
| tiempo (s) | 5.629 | 9.315 (*) | 52.455 | 54.180 | 

| Versión |  Spin lock EE IM B | Spin lock EE IM B opt |
|-------------|-------------|-----|
| tiempo (s) | 54.465 | 53.159 |

(*) Como se puede comprobar, el más rápido sería el mutex nativo de C++, pero el resultado no lo vamos a tener en cuenta debido a que durante su ejecución realiza llamadas al sistema operativo. Estas se realizan al no poder obtener la exclusividad sobre el mutex, y producen que se pase el control al kernel del sistema operativo para que este expulse al thread, y al suceder esto, no todos los tiempos de espera no computan como tiempo de uso de procesador, además de no existir casi colisiones al solicitar el mutex ya que las gestiona el sistema operativo.

Al comparar el resto de mutex, se puede comprobar como los mutex implementados sobre spin locks energéticamente eficientes obtienen menos rendimiento que el mutex implementado sobre un spin lock no energéticamente eficiente, aunque la diferencia es bastante baja.

 

## Energéticas

Tras tres iteraciones realizadas en el script performance_mutex_benchmark.sh configurado para ejecutar el benchmark con región crítica larga, se obtuvieron los siguientes resultados. Los tiempos son expresados en segundos y son relativos a los tiempos de ejecución, los consumos medios son expresados en Watts y el consumo total durante la ejecución es expresado en julios.

Las mediciones de potencia han sido realizadas entre el transformador y la placa (en el cable de alimentación antes de entrar a la placa).

La versión llamada sistema operativo representa el consumo que posee el sistema operativo sin ningún programa de usuario en ejecución.

| Versión | Sistema Operativo | Sin mutex | Mutex Nativo C++ | Spin lock simple | 
|-------------|-------------|-------------|-----|-------------|
| consumo medio (Watts)            | 1.374 | 2.492 | 1.716     | 2.155  | 
| tiempo de ejecución (s)          | -     | 1.460 | 6.169 (*) | 13.176 | 
| consumo durante la ejecución (J) | -     | 3.638 | 10.586 (*) | 28.394 |

| Versión | Spin lock EE | Spin lock EE IM B | Spin lock EE IM B opt |
|-------------|-------------|-------------|-----|
| consumo medio (Watts)            |  2.155  | 1.626  | 1.621  | 1.639 |
| tiempo de ejecución (s)          | 13.176 | 13.638 | 13.694 | 13.350 |
| consumo durante la ejecución (J) | 28.394 | 22.175 | 22.198 | 21.880 |

(*) En este caso los resultados del mutex nativo de C++ son más reales, aunque al haber utilizado el sistema operativo para su gestión no se tendrán en cuenta en el análisis.

Como se puede comprobar, hay una diferencia notable en el consumo total entre los mutex energéticamente eficientes y el no energéticamente eficiente. Entre los mutex energéticamente eficientes apenas hay diferencias en el consumo total.

 

## Comparativa entre Spin lock simple y Spin lock energéticamente eficiente

Se va a realizar una comparativa utilizando los datos anteriores sobre la diferencia de rendimiento tanto en términos de tiempo de cómputo como en términos de eficiencia energética entre el mutex construido sobre el spin lock simple y el mutex construido sobre el spin lock energéticamente eficiente. Se utilizará la primera versión de mutex energéticamente eficiente debido a que posee la misma implementación del mutex simple salvo por la inclusión de instrucciones que permiten el ahorro de energía.

### Comparativa rendimiento

Sección crítica corta:

| Versión | Spin lock simple | Spin lock energéticamente eficiente |
|-------------|-------------|-------------|
| media (s) | 17.3540 | 17.5425 |

En las pruebas realizadas en una sección crítica corta, el mutex implementado sobre un spin lock simple es un 1% más rápido que el mutex implementado sobre un spin lock energéticamente eficiente.

Sección crítica larga:

| Versión | Spin lock simple | Spin lock energéticamente eficiente |
|-------------|-------------|-------------|
| media (s) | 52.455 | 54.180 |

En las pruebas realizadas en una sección crítica larga, el mutex implementado sobre un spin lock simple es un 3,2% más rápido que el mutex implementado sobre un spin lock energéticamente eficiente.

Como se puede comprobar en ambos casos el mutex simple es mas rápido aunque nunca es una diferencia demasiado notable

### Comparativa energía

Sección crítica corta:
En una sección crítica corta no tiene sentido realizar una comparativa de energías, debido a que continuamente los hilos estarían terminando la región crítica y haciendo que el procesador saliese de estado ahorro de energía en el caso del mutex basado en el spin lock energéticamente eficiente.

Sección crítica larga:

| Versión | Spin lock simple | Spin lock energéticamente eficiente |
|-------------|-------------|-------------|
| consumo medio (Watts)            | 2.155  | 1.626  |
| tiempo de ejecución (s)          | 13.176 | 13.638 |
| consumo durante la ejecución (J) | 28.394 | 22.175 |

En las pruebas realizadas en una sección crítica larga, el mutex implementado sobre un spin lock simple consume un 28% más de energía que el mutex implementado sobre un spin lock energéticamente eficiente.

Debido al punto en el que se mide la potencia, en el consumo energético estamos incluyendo consumo de toda la placa, no solo del procesador. En la próxima comparativa de va a restar a la potencia que utiliza cada implementación, la que consume el sistema operativo (1.374 Watts). En este caso, obtendríamos una métrica más parecida a la cantidad de energía que consumen los programas.

| Versión | Spin lock simple | Spin lock energéticamente eficiente |
|-------------|-------------|-------------|
| consumo medio (Watts)            | 0.781  | 0.252  |
| tiempo de ejecución (s)          | 13.176 | 13.638 |
| consumo durante la ejecución (J) | 10.290 | 3,437 |

En este caso, el mutex implementado sobre un spin lock simple consume un 199% más de energía que el mutex implementado sobre un spin lock energéticamente eficiente.

Como se puede comprobar, la implementación con mutex energéticamente eficiente reduce drásticamente el consumo del procesador.

 

# Cuestiones

## Spin lock energéticamente eficiente

#### ¿Dónde entra en modo de ahorro de energía el procesador?

En la instrucción wfe "se entra en modo de ahorro de energía", ya que el procesador esperará sin realizar trabajos a que le llegue un evento.

#### ¿Se entera el Sistema Operativo de que el procesador está en modo bajo consumo?

El sistema operativo no tiene porque enterarse de que se está en bajo consumo, ya que el modo de bajo consumo, entre otras razones se suspende si llega una IRQ (cuando venza el quantum). 

 

# Repositorio del proyecto en GitHub

El proyecto completo se encuentra en el siguiente repositorio en GitHub:

- [https://github.com/AbelChT/Fetch-and-add-y-Spin-Lock-ARMv8](https://github.com/AbelChT/Fetch-and-add-y-Spin-Lock-ARMv8)
