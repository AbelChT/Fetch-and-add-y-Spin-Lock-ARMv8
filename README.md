# Introducción
En el siguiente trabajo se han implementado diferentes mecanismos de exclusión mutua para posteriormente compararlos tanto a nivel se consumo energético como a nivel de rendimiento en la arquitectura ARMv8 de 64 bits (AARCH64). Por un lado se ha implementado un spin lock simple y una versión energeticamente eficiente y por otro lado se ha implementado la primitiva fetch and add. 
Sobre todos ellos se han realizado test unitarios para comprobar su correcto funcionamiento.
Por otro lado, se a realizado una comparativa de rendimiento sobre tres mutex creados sobre las bases de las implementaciones del spin lock simple, el spin lock energeticamente eficiente y el proporcionado por la librería estándar del lenguaje C++.


# Descripción de los fuentes
## Carpeta app
Aquí se encuentra una aplicación creada especialmente para probar el rendimiento de los diferentes mutex creados.

#### Ficheros
- mutex_selector.h: Declaración de los diferentes mutex que se pueden utilizar durante las pruebas.
- Reduce2D.h y Reduce2D.cpp: Reductor de 2D a 1D multithread mediante suma de las componentes. Esta suma de hace de una forma muy poco eficiente para hacer un gran uso de los mutex.
- app.cpp: Aplicación principal.


## Carpeta fetch_and_add
Implementación de fetch and add y tests unitarios correspondientes.

#### Ficheros
- aarch64/fetch_and_add.s: Implementación del fetch and add.
- test/test_fetch_and_add.cpp: Test unitarios sobre la implementación en ensamblador.


## Carpeta spin_lock
Implementación de spin_lock y tests unitarios correspondientes

#### Ficheros
- aarch64/spin_lock.s: Implementación del spin lock.
- test/test_spin_lock.cpp: Test unitarios sobre la implementación en ensamblador.
- lib: Implementación de un mutex utilizando las funciones creadas. 


## Carpeta spin_lock_ee
Implementación de spin lock energéticamente eficiente y tests correspondientes

#### Ficheros
- aarch64/spin_lock_ee.s: Implementación del spin lock energéticamente eficiente.
- test/test_spin_lock_ee.cpp: Test unitarios sobre la implementación en ensamblador.
- lib: Implementación de un mutex utilizando las funciones creadas. 


# Evaluación de rendimiento

# Misc
En la carpeta misc, se encuentra una demostración de que si entre dos instrucciones ldaxr y stlxr el sistema operativo realiza un cambio de contexto, la exclusividad de la escritura se pierde. Es decir aunque ningún otro thread escriba sobre la variable, la instrucción stlxr fallará cómo si hubiese perdido la exclusividad sobre la variable. Al realizarse un cambio de contexto no se almacena la exclusividad de las variables para luego restaurarlo.

# Cuestiones
## Spin lock energéticamente eficiente
#### ¿Dónde entra en modo de ahorro de energía el procesador?
En la instrucción wfe "se entra en modo de ahorro de energía", ya que el procesador esperará sin realizar trabajos a que le llegue un evento.

#### ¿Se entera el Sistema Operativo de que el procesador está en modo bajo consumo?
El sistema operativo no tiene porque enterarse de que se está en bajo consumo, ya que el modo de bajo consumo, entre otras razones se suspende si llega una IRQ (cuando venza el quantum). 


# Entorno de pruebas utilizado
Las pruebas se han realizado sobre una Raspberry Pi 3 model B. Para poder utilizar las instrucciones nativas de este procesador se instaló una versión de Debian de 64 bits y ARMv8-A ya que el Raspbian nativo por mantener retrocompatibilidad no posee estas características, sino que utiliza ARMv7 de 32 bits.

### Instalación de Debian
El sistema instalado fue el siguiente:

https://github.com/Debian/raspi3-image-spec.

En el propio proyecto aparecen instrucciones para su instalación.

# Entorno de compilación utilizado
Para realizarse los experimentos se ha realizado compilación cruzada utilizado el compilador AARCH64 de linaro con soporte a Linux, el cual se puede encontrar en la página oficial de ARM con el nombre aarch64-linux-gnu.

https://developer.arm.com/open-source/gnu-toolchain/gnu-a/downloads
