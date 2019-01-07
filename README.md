# Introducción
En el siguiente trabajo se han implementado diferentes mecanismos de exclusión mutua para posteriormente compararlos tanto a nivel se consumo energético como a nivel de rendimiento en la arquitectura ARMv8 de 64 bits (AARCH64). Por un lado se ha implementado un spin lock simple y una versión energéticamente eficiente y por otro lado se ha implementado la primitiva fetch and add. 

Sobre todos ellos se han realizado test unitarios para comprobar su correcto funcionamiento.

Por otro lado, se a realizado una comparativa de rendimiento sobre cinco mutex creados sobre las bases de las implementaciones del spin lock simple, el spin lock energéticamente eficiente, el spin lock energéticamente eficiente utilizando loads y stores de byte, el spin lock energéticamente eficiente utilizando loads y stores de byte optimizando el spin unlock y el proporcionado por la librería estándar del lenguaje C++.

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
- thread_competition.cpp: Aplicación creada para la evaluación de los mutex en un escenario de uso intensivo. En esta, los diferentes threads lucharán por un recurso compartido utilizando los mutex para ello. Por otro lado, se ha reducido el tiempo de computación de labores distintas al uso de los mutex al mínimo imprescindible.
- performance_thread_competition_o3.sh: Script que ejecuta el programa thread competiton para las diferentes implementaciones un número definido de iteraciones y evalua su rendimiento. Para ello crea un fichero csv en el que almacena el resultado de cada una de las iteraciones para un posterior análisis así como obtiene la media de las ejecuciones de cada implementación. Para usarlo primero se han de compilar las diferentes implementaciones mediante el fichero Makefile y posteriormente se ha de colocar el script en la carpeta build.

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

## Carpeta misc
En la carpeta misc, se encuentra una demostración de que si entre dos instrucciones ldaxr y stlxr el sistema operativo realiza un cambio de contexto, la exclusividad de la escritura se pierde. Esto es debido a que al llegar una interrupción, el registro de exclusividad se borra, produciendo el mismo efecto que si se ejecutara la instrucción CLREX.

# Evaluación de rendimiento
La evaluación de rendimiento se realizó sobre el entorno de pruebas que de describirá posteriormente y utilizando el programa thread_competition.cpp comentado anteriormente. Para almacenar los resultados se utilizó el script performance_thread_competition_o3.sh.

## Tiempo
Tras 30 iteraciones realizadas en el script performance_thread_competition_o3.sh se obtuvieron los siguientes resultados. Todos ellos se expresan en segundos y són relativos al tiempo de ejecución de las diferentes versiones.

| Versión | Sin mutex | Mutex Nativo C++ | Spin lock simple | Spin lock energéticamente eficiente | Spin lock energéticamente eficiente loads y stores con bytes | Spin lock energéticamente eficiente loads y stores con bytes optimizado |
|-------------|-------------|-----|-------------|-------------|-----|-----|
| media | 0.4267 | 14.6513 | 17.3540 | 17.5425 | 17.7751 | 14.3856 |
| desviación típica | 0.0014 | 0.0455 | 0.5489 | 0.5003 | 0.6902 | 0.5441 |
| mínimo | 0.4259 | 14.5592 | 16.5428 | 16.3294 | 16.2221 | 13.1974 |
| máximo | 0.4320 | 14.7715 | 18.6714 | 18.7380 | 19.0890 | 15.3787 |

Como se puede comprobar en media el más rápido es el spin lock energéticamente eficiente con loads y stores utilizando instrucciones de bytes y optimizando los stores, pero su desviación típica es bastante elevada.

## Energéticas
TODO: Estas pruebas aún no se han realizado.

# Entorno de pruebas utilizado
Las pruebas se han realizado sobre una Raspberry Pi 3 model B. Para poder utilizar las instrucciones nativas de este procesador se instaló una versión de Debian de 64 bits y ARMv8-A ya que el Raspbian nativo por mantener retrocompatibilidad no posee estas características, sino que utiliza ARMv7 de 32 bits.

### Instalación de Debian
El sistema instalado fue el siguiente:

https://github.com/Debian/raspi3-image-spec.

En el propio proyecto aparecen instrucciones para su instalación.

# Entorno de compilación utilizado
Para realizarse los experimentos se ha realizado compilación cruzada utilizado el compilador AARCH64 de linaro con soporte a Linux, el cual se puede encontrar en la página oficial de ARM con el nombre aarch64-linux-gnu.

https://developer.arm.com/open-source/gnu-toolchain/gnu-a/downloads

# Cuestiones
## Spin lock energéticamente eficiente
#### ¿Dónde entra en modo de ahorro de energía el procesador?
En la instrucción wfe "se entra en modo de ahorro de energía", ya que el procesador esperará sin realizar trabajos a que le llegue un evento.

#### ¿Se entera el Sistema Operativo de que el procesador está en modo bajo consumo?
El sistema operativo no tiene porque enterarse de que se está en bajo consumo, ya que el modo de bajo consumo, entre otras razones se suspende si llega una IRQ (cuando venza el quantum). 
