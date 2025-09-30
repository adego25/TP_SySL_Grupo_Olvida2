#1a
sed 's/\./\.\n/g' ../consignas/breve_historia.txt |
#1b
sed '/^[[:space:]]*$/d' > ../evidencia/breve_historia_2.txt
echo "Archivo breve_historia_2.txt creado en la carpeta evidencia"
#no entendi que habia que hacer en este punto muy bien, creo que es esto? o usar cat para leer el primer archivo y modificarlo
# y guardarlo para el punto c? nose