# Introducción
En el siguiente trabajo se han implementado diferentes mecanismos de exclusión mutua para posteriormente compararlos tanto a nivel se consumo energético como a nivel de rendimiento en la arquitectura ARMv8 de 64 bits (AARCH64). Por un lado se ha implementado un spin lock simple y diferentes versiones energéticamente eficiente y por otro lado se ha implementado la primitiva fetch and add. 

Sobre todos ellos se han realizado test unitarios para comprobar su correcto funcionamiento.

Por otro lado, se a realizado una comparativa de rendimiento sobre cinco mutex creados sobre las bases de las implementaciones del spin lock simple, el spin lock energéticamente eficiente, el spin lock energéticamente eficiente utilizando loads y stores de byte, el spin lock energéticamente eficiente utilizando loads y stores de byte optimizando el spin unlock y el proporcionado por la librería estándar del lenguaje C++.

Para más información consultar: [https://github.com/AbelChT/Fetch-and-add-y-Spin-Lock-ARMv8/blob/master/informe.md](https://github.com/AbelChT/Fetch-and-add-y-Spin-Lock-ARMv8/blob/master/informe.md)

# Entorno de pruebas utilizado
Las pruebas se han realizado sobre una Raspberry Pi 3 model B. Para poder utilizar las instrucciones nativas de este procesador se instaló una versión de Debian de 64 bits y ARMv8-A ya que el Raspbian nativo por mantener retrocompatibilidad no posee estas características, sino que utiliza ARMv7 de 32 bits.

### Instalación de Debian
El sistema instalado fue el siguiente:

https://github.com/Debian/raspi3-image-spec.

En el propio proyecto aparecen instrucciones para su instalación.

# Entorno de compilación utilizado
Para realizarse los experimentos se ha realizado compilación cruzada utilizado el compilador AARCH64 de linaro con soporte a Linux, el cual se puede encontrar en la página oficial de ARM con el nombre aarch64-linux-gnu.

https://developer.arm.com/open-source/gnu-toolchain/gnu-a/downloads

# Descripción de los fuentes: fetch and add
En esta carpeta se encuentra todo lo relacionado con el fetch and add.

## Carpeta build
Se almacenarán los resultados de las compilaciones

## Carpeta fetch_and_add
Implementación de fetch and add y tests unitarios correspondientes.

### Ficheros
- aarch64/fetch_and_add.s: Implementación del fetch and add.
- test/test_fetch_and_add.cpp: Test unitarios sobre la implementación en ensamblador.

## Fichero Makefile
Fichero que compila los test unitarios a un fichero ejecutable.

Antes de utilizar este fichero, hay que modificarlo para establecer la variable CC (path del compilador) de forma apropiada.

# Descripción de los fuentes: mutex
En esta carpeta se encuentra todo lo relacionado con los spin locks creados, así como los mutex que derivan de estos.

## Carpeta build
Se almacenarán los resultados de las compilaciones

## Carpeta app
Aquí se encuentran dos aplicación creada especialmente para probar el rendimiento de los diferentes spin locks creados.

### Ficheros
- mutex_selector.h: Declaración de los diferentes mutex que se pueden utilizar durante las pruebas.
- Reduce2D.h y Reduce2D.cpp: Reductor de 2D a 1D multithread mediante suma de las componentes. Esta suma de hace de una forma muy poco eficiente para hacer un gran uso de los mutex.
- app.cpp: Aplicación que hace uso de la biblioteca Reduce2D creada.
- mutex_benchmark.cpp: Aplicación creada para la evaluación de los mutex en un escenario de uso intensivo. En esta, los diferentes threads lucharán por un recurso compartido utilizando los mutex para ello. En este benchmark existen dos opciones de compilación. En la primera se crea una sección crítica muy larga, y en la segunda una corta en la que se ha reducido el tiempo de computación de labores distintas al uso de los mutex al mínimo imprescindible.

## Carpetas spin_lock, spin_lock_ee, spin_lock_ee_b y spin_lock_ee_b_ne
En estas carpetas se encuentras las implementaciones de los distintos spin locks, los mutex creados a partir de ellos, así como los test unitarios correspondientes.

### Correspondencia de carpetas
- spin_lock: spin lock simple
- spin_lock_ee: spin lock energéticamente eficiente
- spin_lock_ee_b: spin lock energéticamente eficiente utilizando loads y stores de byte
- spin_lock_ee_b_ne: spin lock energéticamente eficiente utilizando loads y stores de byte optimizando el spin unlock

### Ficheros
- aarch64/spin_lock.s: Implementación del spin lock.
- test/test_spin_lock.cpp: Test unitarios sobre la implementación en ensamblador.
- lib: Implementación de un mutex utilizando las funciones creadas. 

## Fichero Makefile
Fichero que compila los test unitarios a un fichero ejecutable, así como los diferentes programas para evaluar el rendimiento.

Antes de utilizar este fichero, hay que modificarlo para establecer la variable CC (path del compilador) de forma apropiada.

## Fichero performance_mutex_benchmark.sh
Script que ejecuta el programa mutex benchmark para las diferentes implementaciones un número definido de iteraciones y evalua su rendimiento. Para ello crea un fichero csv en el que almacena el resultado de cada una de las iteraciones para un posterior análisis así como obtiene la media de las ejecuciones de cada implementación. Para usarlo primero se han de compilar las diferentes implementaciones mediante el fichero Makefile y posteriormente se ha de colocar el script en la carpeta build.
Actualmente está configurado para medir el rendimiento del programa mutex benchmark con sección crítica corta.

## Carpeta misc
En la carpeta misc, se encuentra una demostración de que si entre dos instrucciones ldaxr y stlxr el sistema operativo realiza un cambio de contexto, la exclusividad de la escritura se pierde. Esto es debido a que al llegar una interrupción, el registro de exclusividad se borra, produciendo el mismo efecto que si se ejecutara la instrucción CLREX.

# Evaluación de rendimiento
La evaluación de rendimiento se realizó sobre el entorno de pruebas que se describirá posteriormente con el sistema operativo en estado de ejecución nº1 y utilizando el programa mutex benchmark comentado en la sección anterior. Para almacenar los resultados se utilizó el script performance_mutex_benchmark.sh.

## Tiempo
Tras 30 iteraciones realizadas en el script performance_mutex_benchmark.sh configurado para ejecutar el benchmark con región crítica corta, se obtuvieron los siguientes resultados. Todos ellos se expresan en segundos y son relativos al tiempo de uso del procesador en las diferentes versiones de las implementaciones del mutex, esto es para evitar contar en todo lo posible tiempo que el sistema operativo dedica a otras tareas. Al poseer 4 núcleos el sistema, el tiempo de ejecución es mucho menor al de uso del procesador.

| Versión | Sin mutex | Mutex Nativo C++ | Spin lock simple | Spin lock energéticamente eficiente | Spin lock energéticamente eficiente loads y stores con bytes | Spin lock energéticamente eficiente loads y stores con bytes optimizado |
|-------------|-------------|-----|-------------|-------------|-----|-----|
| media (s) | 0.4267 | 14.6513 | 17.3540 | 17.5425 | 17.7751 | 14.3856 |
| desviación típica (s) | 0.0014 | 0.0455 | 0.5489 | 0.5003 | 0.6902 | 0.5441 |
| mínimo (s) | 0.4259 | 14.5592 | 16.5428 | 16.3294 | 16.2221 | 13.1974 |
| máximo (s) | 0.4320 | 14.7715 | 18.6714 | 18.7380 | 19.0890 | 15.3787 |

Como se puede comprobar, en media el más rápido es el spin lock energéticamente eficiente con loads y stores utilizando instrucciones de bytes y optimizando los stores, pero su desviación típica es bastante elevada.

Tras dos iteraciones realizadas en el script performance_mutex_benchmark.sh configurado para ejecutar el benchmark con región crítica larga, se obtuvieron los siguientes resultados. Todos ellos se expresan en segundos y son relativos al tiempo de uso del procesador en las diferentes versiones de las implementaciones del mutex.

| Versión | Sin mutex | Mutex Nativo C++ | Spin lock simple | Spin lock energéticamente eficiente | Spin lock energéticamente eficiente loads y stores con bytes | Spin lock energéticamente eficiente loads y stores con bytes optimizado |
|-------------|-------------|-----|-------------|-------------|-----|-----|
| tiempo (s) | 5.629 | 9.315 (*) | 52.455 | 54.180 | 54.465 | 53.159 |

(*) Como se puede comprobar, el más rápido sería el mutex nativo de C++, pero el resultado no lo vamos a tener en cuenta debido a que durante su ejecución realiza llamadas al sistema operativo. Estas se realizan al no poder obtener la exclusividad sobre el mutex, y producen que se pase el control al kernel del sistema operativo para que este expulse al thread, y al suceder esto, no todos los tiempos de espera no computan como tiempo de uso de procesador, además de no existir casi solisiones al solicitar el mutex ya que las gestiona el sistema operativo.

Al comparar el resto de mutex, se puede comprobar como los mutex implementados sobre spin locks energeticamente eficientes obtienen menos rendimiento que el mutex implementado sobre un spin lock no energeticamente eficiente, aunque la diferencia es bastante baja.

## Energéticas
Tras dos iteraciones realizadas en el script performance_mutex_benchmark.sh configurado para ejecutar el benchmark con región crítica larga, se obtuvieron los siguientes resultados. Los tiempos son expresados en segundos y son relativos a los tiempos de ejecución, los consumos medios son expresados en Watts y el consumo total durante la ejecución es expresado en julios.

Las mediciones de potencia han sido realizadas entre el transformador y la placa (en el cable de alimentación antes de entrar a la placa).

La versión llamada sistema operativo representa el consumo que posee el sistema operativo sin ningún programa de usuario en ejecución.

| Versión | Sistema Operativo | Sin mutex | Mutex Nativo C++ | Spin lock simple | Spin lock energéticamente eficiente | Spin lock energéticamente eficiente loads y stores con bytes | Spin lock energéticamente eficiente loads y stores con bytes optimizado |
|-------------|-------------|-------------|-----|-------------|-------------|-----|-----|
| consumo medio (Watts)            | 1.374 | 2.492 | 1.716     | 2.155  | 1.626  | 1.621  | 1.639 |
| tiempo de ejecución (s)          | -     | 1.460 | 6.169 (*) | 13.176 | 13.638 | 13.694 | 13.350 |
| consumo durante la ejecución (J) | -     | 3.638 | 10.586 (*) | 28.394 | 22.175 | 22.198 | 21.880 |

(*) En este caso los resultados del mutex nativo de C++ son más reales, aunque al haber utilizado el sistema operativo para su gestión no se tendrán en cuenta en el análisis.

Como se puede comprobar, hay una diferencia notable en el consumo total entre los mutex energeticamente eficientes y el no energeticamente eficiente. Entre los mutex energeticamente eficientes apenas hay diferencias en el consumo total.

## Comparación general de rendimiento entre Spin lock simple y Spin lock energéticamente eficiente.
Se va a realizar una comparativa utilizando los datos anteriores sobre la diferencia de rendimiento tanto en terminos de tiempo de cómputo como en terminos de eficiencia energética entre el mutex construido sobre el spin lock simple y el mutex construido sobre el spin lock energéticamente eficiente. Se utilizará la primera versión de mutex energeticamente eficiente debido a que posee la misma implementación del mutex simple salvo por la inclusión de instrucciones que permiten el ahorro de energía.

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

Como se puede comprobar en ambos casos el mútex simple es mas rápido aunque nunca es una diferencia demasiado notable

### Comparativa energía
Sección crítica corta:
En una sección crítica corta no tiene sentido realizar una comparativa de energías, debido a que continuamente los hilos estarían terminando la región crítica y haciendo que el procesador saliese de estado ahorro de energía en el caso del mutex basado en el spin lock energeticamente eficiente.

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

Como se puede comprobar, la implementación con mutex energeticamente eficiente reduce drásticamente el consumo del procesador.

