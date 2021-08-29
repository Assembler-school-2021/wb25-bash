
#!/bin/bash
echo "Agenda en BASH"
AGENDA="agenda.txt"

function verlinea(){
    head -${1} $AGENDA | tail -1
}

function listar(){
    echo "Nombre|Apellido|Dirección|Teléfono|Mail|Ciudad|País" > ${AGENDA}.tmp
    cat $AGENDA >> ${AGENDA}.tmp
    column ${AGENDA}.tmp -t -s '|'
    rm ${AGENDA}.tmp
}

function buscar(){
    [ -f $AGENDA ] || ( echo "La agenda está vacía, introduzca antes algun dato" && return 1 )
    read -p "Introduce el texto que buscas: " item
    grep -in "$item" $AGENDA | column -t -s '|'
}

function buscaDuplicado(){
	ITEM=$1
	LINEA=`grep -n "$ITEM" $AGENDA | cut -d: -f1 2> /dev/null`
	[ -z "$LINEA" ] || echo $LINEA
}

function getColumn(){
    COL=$1
    shift;
    echo $@ | cut -d'|' -f${COL}
}

function addName(){
    if [ ! -z "$1" ]; then
        NOM=`getColumn 1 $1`
        APE=`getColumn 2 $1`
        DIR=`getColumn 3 $1`
        TEL=`getColumn 4 $1`
        EML=`getColumn 5 $1`
        CIU=`getColumn 6 $1`
        PAI=`getColumn 7 $1`
    fi
    read -p "Introduce el nombre [$NOM]: " nombre
    [ -z "$nombre" ] && nombre=$NOM
    read -p "Introduce el apellido [$APE]: " apellido
    [ -z "$apellido" ] && apellido=$APE
    read -p "Introduce la dirección [$DIR]:" direc
    [ -z "$direc" ] && direc=$DIR
    read -p "Introduce el teléfono [$TEL]: " telf
    [ -z "$telf" ] && telf=$TEL
    read -p "Introduce el mail [$EML]: " email
    [ -z "$email" ] && email=$EML
    read -p "Introduce la ciudad [$CIU]: " ciudad
    [ -z "$ciudad" ] && ciudad=$CIU
    read -p "Introduce el pais [$PAI]: " pais
    [ -z "$pais" ] && pais=$PAI
    [ -f $AGENDA ] || touch $AGENDA
    read -p "Va a introducir el contacto de $nombre $apellido, con teléfono $telf y email $email que vive en la $direc de $ciudad ($pais), estás seguro [Y/n]: " seguro
    if [ "$seguro" = "y" ] || [ -z "$seguro" ]; then
        LINEA=`buscaDuplicado "$nombre|$apellido"`
        if [ ! -z "$LINEA" ]; then
            echo "El registro está duplicado (registro $LINEA)"
            read -p "Desea sustituirlo?[Y/n]: " susti
            if [ "$susti" = "y" ] || [ -z "$susti" ]; then
                sed -i "${LINEA}d" $AGENDA
                echo "$nombre|$apellido|$direc|$telf|$email|$ciudad|$pais" >> $AGENDA
            fi
        else
                echo "$nombre|$apellido|$direc|$telf|$email|$ciudad|$pais" >> $AGENDA
        fi
    fi
}
function edita(){
    LINE=$1
    REG=`verlinea ${LINE} | column -t -s '|'`
    echo "Va a editar el registro $REG"
    read -p "Está seguro?[N/y]: " resp
    if [ "$resp" = "y" ]; then 
        addName "$(verlinea $LINE)"
        sed -i "${LINE}d" $AGENDA
    fi
    
}
function borra() {
    LINEA=$1
    REG=`verlinea ${LINEA} | column -t -s '|'`
    echo "Va a borrar el registro $REG"
    read -p "Está seguro?[N/y]: " resp
    if [ "$resp" = "y" ]; then 
        sed -i "${LINEA}d" $AGENDA
        echo "Registro $LINEA borrado"
        return 0
    else
        return 1
    fi
}

function borraEdita(){
    read -p "Introduce el criterio de búsqueda para encontrar el registro que quieres borrar o editar: " crit
    FINDFILE="posibles.tmp"
    grep -n $crit $AGENDA > $FINDFILE
    if [ ! -f "$FINDFILE" ]; then echo "No existe ningún contacto que cumpla el criterio $crit"; rm $FINDFILE; return 1; fi
    read -p "Desea borrar o editar [b o e]: " BoE
    while IFS= read -r -u9 I; do
        #C=`echo $I | cut -d:`
        L=`echo $I | cut -d: -f1`
        if [ "$BoE" = "b" ]; then borra $L && rm $FINDFILE && return 0; fi
        if [ "$BoE" = "e" ]; then edita $L $T; fi
    done 9< $FINDFILE
    rm $FINDFILE
}

function menu(){
    PS3='Elige la opcion: '
    options=("buscar en la libreta de direcciones" "añadir entradas" "borrar o editar entradas" "listar las entradas" "salir")
    select opt in "${options[@]}"
    do
        echo "Has elegido $opt"
        case $REPLY in
            "1")
                buscar
                ;;
            "2")
                addName
                ;;
            "3")
                borraEdita
                ;;
            "4")
                listar
                ;;
            "5")
                break
                ;;
            *) echo "las opciones van del 1 al 5 (has elegido $REPLY)";;
        esac
    done
}

menu
