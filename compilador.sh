#!/bin/bash

clear

echo "*** TP Nro 2 - Flex & Bison ***"
echo
echo "Versión a compilar"
echo "Elija una de las siguientes opciones:"
echo "1 Original"
echo "2 Optimizado"
echo "* Salir"
echo

read n
case $n in
        1) cd original/;;
        2) cd optimizado/;;
	*) clear; exit 1;;
esac

flex scanner.l
bison parser.y
gcc *.c -o compilador -lfl

clear

echo "##### TEST #1: entradaok.txt #####"
echo

./compilador < ../entradaok.txt

echo
read -rsp $'Presione una tecla para continuar con el TEST #2...' -n1 key

clear

echo "##### TEST #2: entradaerr.txt #####"
echo

./compilador < ../entradaerr.txt

echo
read -rsp $'Presione una tecla para terminar...' -n1 key

clear
