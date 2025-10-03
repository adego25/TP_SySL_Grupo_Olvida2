echo "Archivo con primera palabra eliminada:"
sed 's/^[a-zA-ZáéíóúÁÉÍÓÚñÑ]*\b//' ../consignas/breve_historia.txt > ../evidencia/breve_historia_1i.txt