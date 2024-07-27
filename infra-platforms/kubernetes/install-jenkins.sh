#!/bin/bash

# Mostrar el menú
echo "Please enter what kind of jenkins installation you need:"
echo "1. Jenkins on k8s"
echo "2. Jenkins on rancher k3s"
echo "3. Jenkins on Docker"

# Leer la opción del usuario
read -p "Enter your choice (1, 2 or 3): " opcion

# Ejecutar el script correspondiente basado en la opción elegida
case $opcion in
    1)
        echo "Ejecutando jenkins-deploy.sh..."
        cd ci-cd/jenkins/declarative
        ./jenkins-deploy.sh
        ;;
    2)
        echo "Ejecutando script2.sh..."
        ./ci-cd/jenkins/declarative/jenkins-deploy.sh
        ;;
    *)
        echo "Opción no válida. Por favor, selecciona 1 o 2."
        ;;
esac

##!/bin/bash
#
#cd  ../ci-cd/jenkins/declarative/
#
#./jenkins-deploy.sh