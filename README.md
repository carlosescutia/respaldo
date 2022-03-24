# Respaldo de proyecto en servidor de respaldos remoto
#


## Configurar acceso al servidor de respaldos
* Configurar vpn para acceder a la red del servidor de respaldos
    * Instalar binario de conexión vpn por línea de comandos. Ej.
        ```
        snx
        ```

* Automatizar conexión vpn utilizando utilería 'expect'. 
    ```
    sudo apt-get install expect
    ```

    * Basarse en script de ejemplo 'login.backupserver.ejemplo', renombrar a login.backupserver
        ```
        #!/usr/bin/expect
        # script para automatizar conexion mediante vpn snx
        # sustituir <password> por el password real

        spawn -ignore HUP /bin/sh -c "snx"
        expect "password:"
        send "<password>\r"
        expect eof
        ```


* Configurar acceso al servidor de respaldos mediante llaves ssh.
    * Verificar si existen llaves
        ```
        for key in ~/.ssh/id_*; do ssh-keygen -l -f "${key}"; done | uniq
        ```

    * Generar llave ed25519
        ```
        ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519
        ```

    * Copiar llave al servidor de respaldos
        ```
        ssh-copy-id -i ~/.ssh/id_ed25519.pub usuarioborg@backupserver
        ```


## Configurar respaldos en servidor del proyecto
* Crear directorio backup dentro del directorio del proyecto para volcado de base de datos
    * El volcado se crea antes del respaldo y se elimina al terminar, para evitar problemas de seguridad.
        ```
        sudo mkdir proyecto/backup
        sudo chown usuario proyecto/backup
        sudo chmod 700 proyecto/backup
        ```
* Crear directorio ~/respaldos/ para alojar script, configuración, bitácoras y montaje de respaldos
    ```
    mkdir ~/respaldos
    ```

* Estructura de directorios
    ```
    home/usuario
    └──respaldos
        ├── proyecto.log				// bitacora de respaldos de un proyecto
        ├── mnt
        │   ├── proyecto				// punto de montaje de un proyecto
        └── respaldo				// script de respaldo

    /var/www/proyecto
        ├── application
        ├── backup				// directorio creado para volcado de db
        ...
    ```

* Instalar borg 
    ```
    sudo apt-get install borgbackup
    ```
    * Otra distro/version antigua: descargar binario que soporte versión de libc del sistema. Para verificar libc: 
        ```
        ldd --version
        ```

* Obtener script de respaldo desde repositorio github
    ```
    cd ~/respaldos/
    git clone https://github.com/carlosescutia/respaldo .
    ```

    * Para obtener la última versión del proyecto: 
        ```
        git pull        // actualizar a ultima version del script
        ```

* Otorgar permisos de ejecución a scripts
    ```
    chmod a+x respaldo backup.proyecto
    ```

* Configurar script
    * Basarse en archivo 'respaldo.config.ejemplo', renombrar a 'respaldo.config'

        ```
        ################################
        # configure here your parameters

        # borg binary
        BORG=/usr/bin/borg

        # where to store logs and mount backups
        workdir="/home/admon/respaldos"

        # backup parameters
        compression="lz4"

        # borg server parameters
        # borg user password not needed since 
        # we're using ssh key based authentication
        backupuser="borgbackup"
        backupserver="172.31.100.109"
        backupport="22"
        backupdir="/home/borgbackup/"

        # backup retention policy
        resp_dia=7
        resp_sem=4
        resp_mes=3

        # end of config
        ################################
        ```

* Configurar credenciales de base de datos en caso de no usar docker. 
    * Basarse en archivo 'credenciales.proyecto.ejemplo', renombrar a 'credenciales.proyecto'

        ```
        # credentials for postgre database
        PG_HOST="localhost"
        PG_USER="user"
        PG_DB="db"

        # credentials for mysql database
        MY_HOST="localhost"
        MY_DB="db"
        MY_PWD="pwd"
        ```


* Programar respaldo y depuración con cron
    * Basarse en script que integra acceso a la vpn 'backup.proyecto.ejemplo', renombrar a 'backup.proyecto'
        ```
        #!/bin/bash
        # script para automatizar acceso por vpn a servidor de respaldos y ejecución del respaldo
        # sustituir rutas correctas, proyecto, proydir.
        # ajustar herramienta vpn (snx en este caso).

        /usr/bin/expect /home/admon/respaldos/login.backupserver
        /home/admon/respaldos/respaldo -p proyecto -d /var/www/proydir -pg backup
        /usr/bin/snx -d
        ```

    * Agregar programación a cron
        ```
        sudo crontab -e
        ```
            ```
            # backup projects
            #
            # proyecto.servidor. Tuesday to Saturday at 1:00 am (end of working day)
                0 1 * * 2-6 backup.proyecto

            # prune backups
            #
            # proyecto.servidor. Every Sunday at 1:00 am
                0 1 * * 7 ~/respaldos/respaldo -p proyecto prune
            ```

## Misc

* Utilizar namespaces para evitar conflictos en nombre de proyecto. Ej:
    ```
    inversion.produccion
    inversion.testserver
    inversion.pcdesarrollo
    ```

* Agregar usuario al grupo fuse para permitir montar y desmontar repositorio remoto (versiones de ubuntu < 18.04)
    ```
    sudo adduser usuario fuse
    ```

* Comandos del script:
    ```
    mostrar ayuda del script
        ~/respaldos/respaldo --help

    inicializar repositorio del proyecto en servidor de respaldo
        ~/respaldos/respaldo -p proyecto.servidor init

    mostrar lista de respaldos del proyecto
        ~/respaldos/respaldo -p proyecto.servidor list

    mostrar información de los respaldos
        ~/respaldos/respaldo -p proyecto.servidor info

    respaldar proyecto con base de datos postgresql en contenedor docker
        ~/respaldos/respaldo -p proyecto.servidor -d ~/proyectos/proyecto.servidor -pg -dbc postgres backup

    respaldar proyecto con base de datos postgresql sin docker
        ~/respaldos/respaldo -p proyecto.servidor -d /var/www/proyecto.servidor -pg backup

    respaldar proyecto sin base de datos 
        ~/respaldos/respaldo -p proyecto.servidor -d /var/www/proyecto.servidor backup

    montar repositorio de respaldos del proyecto para revisión
        ~/respaldos/respaldo -p proyecto.servidor mount

    desmontar repositorio de respaldos
        ~/respaldos/respaldo -p proyecto.servidor umount

    restaurar respaldo del proyecto en la ruta indicada por -d
        ~/respaldos/respaldo -p proyecto.servidor -d ~/proyectos/proyecto.servidor -ar proyecto_16-03-2022_17-30 restore
    ```
