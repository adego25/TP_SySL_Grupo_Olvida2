echo "oraciones con idependencia: "
sed 's/\./\.\n/g' ../consignas/breve_historia.txt |
egrep -i 'independencia'
echo "Listo"