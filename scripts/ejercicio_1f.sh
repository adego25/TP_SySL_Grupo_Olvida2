echo "Cantidad de oraciones con 'peronismo':"
sed 's/\./\.\n/g' ../consignas/breve_historia.txt | grep -i -c 'peronismo'