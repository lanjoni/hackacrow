#! /bin/bash

# NOTE: single quotes do not evaluate to-be-evaluated
# command strings. Warning you all here, because this
# simple difference got a couple hours of confused
# debugging of mine. :)

# NOTE: These vars are customizable on runtime.
# For example: DOCKER=/my/docker; GAWK=/my/gawk; ./docker.sh
[[ -z "$DOCKER" ]] && DOCKER=$(which docker)
[[ -z "$GAWK" ]] && GAWK=$(which gawk)

if [[ -z "$DOCKER" ]]; then
    echo "docker is not installed"
    exit 1
elif [[ -z "$GAWK" ]]; then
    echo "gawk is not installed"
    exit 1
fi

IMAGE=
USER_VOLUME=
# CONTAINER_VOLUME=/my/volume; ./docker.sh
[[ -z "$CONTAINER_VOLUME" ]] && CONTAINER_VOLUME=/usr/hackacrow
CONTAINER=
FILE=
COMMAND=

function help() {
    echo "docker.sh [--up IMAGE] [--down CONTAINER] [--run CONTAINER COMMAND FILE] [--help]"
    echo
    echo "A tool that bridges the docker client with the main Hackacrow application."
    echo "Built with <3 by the hackacrow team <https://github.com/lanjoni/hackacrow>."
    echo
    echo "  --up IMAGE <USER_VOLUME>      Pull and run IMAGE as a KeepAlive container with cache at USER_VOLUME dir."
    echo "  --down CONTAINER              Stops IMAGE container."
    echo "  --run CONTAINER FILE COMMAND  Runs COMMAND on CONTAINER based on volume from FILE."
    echo "  --help                        Shows this help message."
    echo
}

function up() {
    if [[ -z "$IMAGE" ]]; then
        echo "invalid image"
        echo
        help
        
        exit 1
    fi
    
    # Pull image.
    [[ $($DOCKER image ls | grep $IMAGE) ]] || $DOCKER pull $IMAGE
    if [[ -z $($DOCKER image ls | grep $IMAGE) ]]; then
        echo "failed to pull image $IMAGE"
        exit 2
    fi

    # Container already running?
    CONTAINER=$($DOCKER ps | grep $IMAGE)
    if [[ -n $CONTAINER ]]; then
        echo $CONTAINER | $GAWK 'NR==1 {print $1}'
        return
    fi

    # Container stopped?
    CONTAINER=$(echo "$($DOCKER ps -a | grep $IMAGE)" | $GAWK 'NR==1 {print $1}')
    if [[ -n "$CONTAINER" ]]; then
        $DOCKER restart $CONTAINER
        return
    fi

    if [[ ! -d "$USER_VOLUME" ]]; then
        echo "invalid volume $USER_VOLUME"
        echo
        help

        exit 1
    fi

    # NOTE: Most language images were built with the purposes of
    # doing their job (compiling, linking, running, etc) and
    # exiting; `tail -f /dev/null` keeps the service alive.
    # This isn't supposed be a de-facto solution, cleverer
    # ones are welcome.
    # KEEP_ALIVE='tail -f /dev/null'
    # CONTAINER=$($DOCKER run -td -v $USER_VOLUME:$CONTAINER_VOLUME $IMAGE $KEEP_ALIVE)

    # Run container.
    CONTAINER=$($DOCKER run -td -v $USER_VOLUME:$CONTAINER_VOLUME $IMAGE)
    if [[ -z "$CONTAINER" ]]; then
        echo "failed to run lang container"
        exit 2
    fi
    
    echo $CONTAINER
}

function down() {
    [[ $($DOCKER inspect -f '{{ .Id }}' $CONTAINER) ]] && docker stop $CONTAINER
}

function run() {
    if [[ -z "$CONTAINER" ]]; then
        echo "invalid empty container."
        return 1
    elif [[ -z "$COMMAND" ]]; then
        echo "invalid empty command"
        return 1
    elif [[ -z "$FILE" ]]; then
        echo "invalid empty file."
        return 1
    elif [[ ! -f "$FILE" ]]; then
        echo "file $FILE does not exist."
        return 1
    fi

    MOUNTS=$($DOCKER inspect -f "{{ .Mounts }}" $CONTAINER)
    if [[ ! $MOUNTS ]]; then
        echo "container $CONTAINER does not exist. Try using --up before using --run."
        help

        exit 1
    elif [[ $MOUNTS == "[]" ]]; then
        echo "container was not binded to local volume."
        echo
        help

        exit 1
    fi

    USER_VOL=$(echo $MOUNTS | $GAWK 'NR==1 {print $2}')
    if [[ -z "$USER_VOL" ]]; then
        echo "failed to find user volume for container $CONTAINER"
        exit 2
    fi
    cp $FILE $USER_VOL

    # NOTE: Using `-i` instead of `-it` since enabling TTY causes errors
    # when calling this script from withing hackacrow.
    docker exec -i $CONTAINER $COMMAND $CONTAINER_VOLUME/$(basename $FILE)
}

case $1 in
    "--up")
        IMAGE=$2
        USER_VOLUME=$3
        up
        ;;
    "--down")
        CONTAINER=$2
        down
        ;;
    "--run")
        CONTAINER=$2
        FILE=$3
        COMMAND=$4
        run

        [[ $? == 1 ]] && echo && help
        ;;
    "--help") help ;;
    *)
        [[ -n $1 ]] && echo "unknown command $1" && echo
        help

        exit 1
        ;;
esac

exit 0
