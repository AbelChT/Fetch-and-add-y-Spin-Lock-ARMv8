# Entorno de pruebas
Para realizar las pruebas instale Debian de 64 bits: https://github.com/Debian/raspi3-image-spec.
Esto lo hice ya que de esta forma podía utilizar la arquitectura nativa del Cortex-A53 la cual es ARMv8-A de 64 bits, ya que Raspbian por compatibilidad con versiones anteriores, utiliza ARMv7 de 32 bits.
Una vez instalado, configuré Debian para tener una ip estática, para poder conectarme a él mediante ethernet. Los ficheros de configuración se encuentran en ConfigSSHEthernet.

# Descripción de carpetas
### spin_lock
Implementación de spin_lock y tests unitarios correspondientes

### fetch_and_add
Implementación de fetch and add y tests unitarios correspondientes

### spin_lock_ee
Implementación de spin lock energéticamente eficiente y tests correspondientes

# SPIN‐LOCK ENERGÉTICAMENTE EFICIENTE
### Cuestión: Identifica dónde entra en modo de ahorro de energía el procesador
En la instrucción wfe "se entra en modo de ahorro de energía", ya que el procesador esperará a que le envien un evento.

### Cuestión: ¿Se entera el Sistema Operativo de que el procesador está en modo bajo consumo?
El sistema operativo no tiene porque enterarse de que se está en bajo consumo, ya que el modo de bajo consumo, entre otras razones se suspende si llega una IRQ (cuando venza el quantum). 

# Ideas a mejorar
En el spin lock mover los mov fuera del load y store, para reducir al máximo esa región.

Crear una segunda versión utilizando fetch and add si existe, sino implementarlo usando load, store