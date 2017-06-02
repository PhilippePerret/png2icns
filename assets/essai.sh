# Pour tester


echo "

Bonjour tout le monde !

"
# maconstante=true

readonly MACONSTANTE=$maconstante
echo "MACONSTANTE = $MACONSTANTE"

if $MACONSTANTE ;
then
  echo "Elle est vraie"
else
  echo "Elle est fausse"
fi
