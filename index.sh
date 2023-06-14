#!/bin/bash

# Función para mostrar el menú de opciones
mostrar_menu() {
    echo "1. Crear carpeta"
    echo "2. Crear archivo"
    echo "3. Asignar permisos"   
    echo "4. Crear usuario"
    echo "5. Crear grupo"
    echo "6. Asignar usuario a grupo"
    echo "7. Cambiar usuario de grupo"
    echo "8. Cambiar propietario y grupo propietario"
    echo "9. Borrar grupo"
    echo "10. Borrar usuario"
    echo "11. Programar tarea cron"
    echo "12. Mostrar tareas cron"
    echo "13. Eliminar tarea cron"
    echo "14. Salir"
    echo "Selecciona una opción:"
}

# Función para borrar un grupo
borrar_grupo() {
    echo "Escribe el nombre del grupo a borrar:"  # Imprime un mensaje solicitando al usuario el nombre del grupo a borrar
    read nombre_grupo  # Lee el nombre del grupo desde la entrada del usuario y lo guarda en la variable "nombre_grupo"
    if grep -q "^$nombre_grupo:" /etc/group; then  # Utiliza el comando `grep` para buscar el nombre del grupo en el archivo "/etc/group"
        groupdel "$nombre_grupo" && echo "Grupo borrado: $nombre_grupo"  # Si el grupo existe, utiliza el comando `groupdel` para borrar el grupo y muestra un mensaje indicando que el grupo ha sido borrado
        echo -e "\n"
    else
        echo "El grupo no existe."  # Si el grupo no existe, muestra un mensaje indicando que el grupo no existe
        echo -e "\n"
    fi
}

# Función para borrar un usuario y su carpeta home
borrar_usuario() {
    echo "Escribe el nombre de usuario a borrar:"  # Imprime un mensaje solicitando al usuario el nombre del usuario a borrar
    read nombre_usuario  # Lee el nombre del usuario desde la entrada del usuario y lo guarda en la variable "nombre_usuario"
    if id "$nombre_usuario" >/dev/null 2>&1; then  # Utiliza el comando `id` para verificar si el usuario existe en el sistema. Redirige la salida estándar y la salida de error a /dev/null para descartarla.
        echo "¿Deseas borrar también la carpeta home del usuario? (y/n)"  # Pregunta al usuario si también desea borrar la carpeta home del usuario
        read opcion  # Lee la opción del usuario (y/n) y la guarda en la variable "opcion"
        if [ "$opcion" = "y" ]; then  # Comprueba si la opción es "y"
            userdel -r "$nombre_usuario" && echo "Usuario borrado: $nombre_usuario y su carpeta home"  # Si la opción es "y", utiliza el comando `userdel` con la opción -r para borrar al usuario y su carpeta home, y muestra un mensaje indicando que el usuario y su carpeta home han sido borrados
        else
            userdel "$nombre_usuario" && echo "Usuario borrado: $nombre_usuario"  # Si la opción no es "y", utiliza el comando `userdel` para borrar al usuario solamente, y muestra un mensaje indicando que el usuario ha sido borrado
            echo -e "\n"
        fi
    else
        echo "El usuario no existe."  # Si el usuario no existe, muestra un mensaje indicando que el usuario no existe
        echo -e "\n"
    fi
}

# Función para crear una carpeta
crear_carpeta() {
    echo "Escribe el nombre de la carpeta:"  # Imprime un mensaje solicitando al usuario el nombre de la carpeta a crear
    read nombre_carpeta  # Lee el nombre de la carpeta desde la entrada del usuario y lo guarda en la variable "nombre_carpeta"
    if [ -d "$nombre_carpeta" ]; then  # Verifica si el directorio (carpeta) ya existe utilizando el comando `test` y la opción `-d` para verificar si es un directorio
        echo "La carpeta ya existe."  # Si la carpeta ya existe, muestra un mensaje indicando que la carpeta ya existe
        echo -e "\n"
    else
        mkdir "$nombre_carpeta" && echo "Carpeta creada: $nombre_carpeta"  # Si la carpeta no existe, utiliza el comando `mkdir` para crear la carpeta y muestra un mensaje indicando que la carpeta ha sido creada
        ls -l
        echo -e "\n"
    fi
}


# Función para crear un archivo
crear_archivo() {
    echo "Escribe el nombre del archivo:"
    read nombre_archivo
    if [ -f "$nombre_archivo" ]; then
        echo "El archivo ya existe."
        echo -e "\n"
    else
        touch "$nombre_archivo" && echo "Archivo creado: $nombre_archivo"
        ls -l
        echo -e "\n"
    fi
}

# Función para asignar permisos a un archivo o carpeta
asignar_permisos() {
    echo "Escribe el nombre del archivo o carpeta:"
    read nombre
    if [ -e "$nombre" ]; then
        echo "Escribe los permisos (ejemplo: 755):"
        read permisos
        chmod "$permisos" "$nombre" && echo "Permisos asignados: $permisos"
        ls -l $nombre
        echo -e "\n"
    else
        echo "El archivo o carpeta no existe."
        echo -e "\n"
    fi
}

# Función para programar una tarea cron
programar_tarea_cron() {
    echo "Escribe el comando de la tarea:"
    read comando
    echo "Escribe el intervalo de tiempo (ejemplo: * * * * * para cada minuto):"
    read intervalo
    (crontab -l ; echo "$intervalo $comando") | crontab - && echo "Tarea cron programada: $comando"
    echo -e "\n"
}

# Función para mostrar las tareas cron programadas
mostrar_tareas_cron() {
    crontab -l
}

# Función para eliminar una tarea cron
eliminar_tarea_cron() {
    echo "Escribe el número de línea de la tarea cron a eliminar:"
    read num_linea
    crontab -l | sed "${num_linea}d" | crontab -
    echo "Tarea cron eliminada."
    echo -e "\n"
}

# Función para crear un usuario
crear_usuario() {
    echo "Escribe el nombre de usuario:"
    read nombre_usuario
    if id "$nombre_usuario" >/dev/null 2>&1; then
        echo "El usuario ya existe."
        echo -e "\n"
    else
        echo "Escribe la contraseña del usuario:"
        read -s password
        echo "Escribe la carpeta home del usuario:"
        read carpeta_home
        if [ ! -d "$carpeta_home" ]; then
            mkdir -p "$carpeta_home" && echo "Carpeta home creada: $carpeta_home"
        fi
        echo "Escribe el shell del usuario (ejemplo: /bin/bash):"
        read shell_usuario

        useradd -m -d "$carpeta_home" -s "$shell_usuario" "$nombre_usuario" && echo "$nombre_usuario:$password" | chpasswd && echo "Usuario creado: $nombre_usuario"
        echo "Usuarios creados en el sistema:"
        cut -d: -f1 /etc/passwd | sort
        echo -e "\n"
    fi
}

# Función para crear un grupo
crear_grupo() {
    echo "Escribe el nombre del grupo:"
    read nombre_grupo
    if grep -q "^$nombre_grupo:" /etc/group; then
        echo "El grupo ya existe."
        echo -e "\n"
    else
        groupadd "$nombre_grupo" && echo "Grupo creado: $nombre_grupo"
        echo "Grupos en el sistema:"
        cut -d: -f1 /etc/group | sort
        echo -e "\n"
    fi
}

# Función para asignar un usuario a un grupo
asignar_usuario_a_grupo() {
    echo "Escribe el nombre de usuario:"
    read nombre_usuario

    echo "Escribe el nombre del grupo:"
    read nombre_grupo

    # Verificar si el grupo existe en /etc/group
    if grep -q "^$nombre_grupo:" /etc/group; then
        # Verificar si el usuario existe en el sistema
        if id "$nombre_usuario" >/dev/null 2>&1; then
            # Asignar el usuario al grupo utilizando usermod
            usermod -a -G "$nombre_grupo" "$nombre_usuario" && echo "Usuario $nombre_usuario asignado al grupo $nombre_grupo"
            echo -e "\n"
        else
            echo "El usuario no existe."
            echo -e "\n"
        fi
    else
        echo "El grupo no existe."
        echo -e "\n"
    fi
}

# Función para cambiar el grupo primario de un usuario
cambiar_grupo_usuario() {
    echo "Escribe el nombre de usuario:"
    read nombre_usuario

    echo "Escribe el nombre del nuevo grupo primario:"
    read nombre_grupo

    # Verificar si el grupo existe en /etc/group
    if grep -q "^$nombre_grupo:" /etc/group; then
        # Verificar si el usuario existe en el sistema
        if id "$nombre_usuario" >/dev/null 2>&1; then
            # Cambiar el grupo primario del usuario utilizando usermod
            usermod -g "$nombre_grupo" "$nombre_usuario" && echo "Grupo primario de $nombre_usuario cambiado a $nombre_grupo"
            echo "Este usuario pertenece a:" 
            group $nombre_usuario
            echo -e "\n"
        else
            echo "El usuario no existe."
            echo -e "\n"
        fi
    else
        echo "El grupo no existe."
        echo -e "\n"
    fi
}

# Función para cambiar el usuario propietario y el grupo propietario de un archivo o carpeta
cambiar_propietario() {
    echo "Escribe el nombre del archivo o carpeta:"
    read nombre
    if [ -e "$nombre" ]; then
        echo "Escribe el nombre del nuevo propietario:"
        read nuevo_propietario
        echo "Escribe el nombre del nuevo grupo propietario:"
        read nuevo_grupo_propietario
        chown "$nuevo_propietario:$nuevo_grupo_propietario" "$nombre" && echo "Propietario cambiado a $nuevo_propietario y grupo propietario cambiado a $nuevo_grupo_propietario"
        echo -e "\n"
    else
        echo "El archivo o carpeta no existe."
        echo -e "\n"
    fi
}

opc=0

while [ $opc -ne 13 ]; do
    mostrar_menu
    read opc

    case $opc in
        1) crear_carpeta ;;  # Llama a la función para crear una carpeta
        2) crear_archivo ;;  # Llama a la función para crear un archivo
        3) asignar_permisos ;;  # Llama a la función para asignar permisos
        4) crear_usuario ;;  # Llama a la función para crear un usuario
        5) crear_grupo ;;  # Llama a la función para crear un grupo
        6) asignar_usuario_a_grupo ;;  # Llama a la función para asignar un usuario a un grupo
        7) cambiar_grupo_usuario ;;  # Llama a la función para cambiar el grupo primario de un usuario
        8) cambiar_propietario ;;  # Llama a la función para cambiar el usuario propietario y el grupo propietario
        9) borrar_grupo ;;  # Llama a la función para borrar un grupo
        10) borrar_usuario ;;  # Llama a la función para borrar un usuario y su carpeta home
        11) programar_tarea_cron ;;  # Llama a la función para programar una tarea cron
        12) mostrar_tareas_cron ;;  # Llama a la función para mostrar las tareas cron programadas
        13) eliminar_tarea_cron ;;  # Llama a la función para eliminar una tarea cron
        14) echo "Saliendo..." ;;
        *) echo "Opción inválida";;
    esac
done
