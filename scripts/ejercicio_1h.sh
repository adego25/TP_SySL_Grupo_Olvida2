echo "Oraciones con fechas del siglo XIX:"
sed 's/\./\.\n/g' ../consignas/breve_historia.txt | grep -E '18[0-9]{2}'