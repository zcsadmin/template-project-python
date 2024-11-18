#!/bin/sh 

# Default values
EXEC=1
TESTS=0
VERBOSE=0
DEBUG=0
DISTIMAGE=0

set -e

show_help() {

    echo "Usage: $0 [-s] [-t] [-v] [-d] [-h]"
    echo "  -d: Run in debug mode"
    echo "  -s: Run a shell instead of running the application"
    echo "  -t: Run tests"
    echo "  -i: Build a distribution image"
    echo "  -v: Verbose output"
    echo "  -h: Show this help"
}

while getopts stivdh flag
do
    case "${flag}" in
        s) EXEC=0;;
        t) TESTS=1;;
        i) DISTIMAGE=1;;
        v) VERBOSE=1;;
        d) DEBUG=1;;
        h) show_help; exit 0;;
    esac
done

if [ $VERBOSE -eq 1 ]; then
    set -x
fi

if [ $DISTIMAGE -eq 1 ]; then
    docker build -f .build/dockerfiles/Dockerfile -t dist .
    docker run --rm dist
    exit 0
fi

# Build docker containers
docker compose build --pull --build-arg FIX_UID="$(id -u)" --build-arg FIX_GID="$(id -g)"

# Start docker environment
docker compose up -d

# Install app requirements (if needed)

docker compose exec app /bin/bash -c "pip3 install --user --disable-pip-version-check -r requirements.txt | grep -v \"already satisfied\"; exit \${PIPESTATUS[0]}" || true

if [ $TESTS -eq 1 ]; then
    # Uncomment the following line when you have tests ;)
    # docker compose exec app /bin/bash -c "pytest"
    exit 0
fi

if [ $DEBUG -eq 1 ]; then
    # Run application in debug mode
    docker compose exec app /bin/bash -c "pip3 install --user --disable-pip-version-check debugpy"
    docker compose exec app /bin/bash -c "python -m debugpy --listen 0.0.0.0:5678 --wait-for-client main.py"
    exit 0
fi

if [ $EXEC -eq 1 ]; then
    # Run application
    docker compose exec app /bin/bash -c "python main.py"
else
    # Log into container
    docker compose exec app /bin/bash
fi
