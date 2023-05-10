#!/bin/bash
function is_valid_cp() {
  cp_regex='^[0-9]{5}$'
  if [[ $1 =~ $cp_regex ]]; then
    return 0
  else
    return 1
  fi
}
echo -e "\nLe but du jeu est simple, vous devez entrer un code postal valide (5 chiffres) et ensuite choisir la villes de votre choix.
Le jeu commencera une fois la ville sélectionner.
Vos avez 10 chances pour trouver le nombre d'habitant exact dans la ville.
Bonne chance \n"
if [[ $# -eq 1 ]]; then
  cp=$1
  if ! is_valid_cp $cp; then
    echo "Le code postal saisi n'est pas valide"
    exit 1
  fi
else
  while true; do
    read -p "Veuillez saisir un code postal : " cp
    if is_valid_cp $cp; then
      break
    else
      echo "Le code postal saisi n'est pas valide"
    fi
  done
fi
communes=$(curl -s "https://geo.api.gouv.fr/communes?codePostal=$cp")
i=0
while read commune; do
  echo "[ $i ] $commune"
  i=$((i+1))
done < <(echo $communes | jq -r '.[].nom')
while true; do
  read -p "Avec quelle ville souhaitez-vous jouer ? " choix
  echo -e "\n"
  if (( $choix >= 0 )) && (( $choix < $i )); then
    commune=$(echo $communes | jq -r ".[$choix].nom")
    break
  else
    echo "Choix invalide"
  fi
done
vies=10
habitants=$(echo $communes | jq -r ".[$choix].population")
while (( $vies > 0 )); do
  read -p "Combien y a-t-il d'habitants dans $commune ? " reponse
  if (( $choix >= 0 )); then
    if [[ $reponse -eq $habitants ]]; then
      echo "Bravo, vous avez trouvé le nombre d'habitants dans $commune !"
      exit 0
    elif (( $reponse > $habitants )); then
      echo "Moins"
    else
      echo "Plus"
    fi
    vies=$((vies-1))
    echo -e "Il vous reste $vies vies\n"
  else
    echo -e "Réponse invalide\n"
  fi
done
echo "Vous avez épuisé toutes vos vies. Le nombre d'habitants dans
$commune est de $habitants"
