echo "Cantidad de oraciones con 'Sarmiento' y 'Rosas':"
sed 's/\./\.\n/g' ../consignas/breve_historia.txt | grep -i 'Sarmiento' | grep -i 'Rosas' | wc -l