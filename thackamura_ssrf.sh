#!/usr/bin/env bash
#..........................................................................
#..........................................................................
reset=`tput sgr0`
green=`tput setaf 2`
RED='\033[0;31m'
  clear
  echo "${green}
    --------------------------------
    --                            --
    -- Thackamura-SSRF JSanalyser --
    --                            --
    --------------------------------
"
echo -e  "${RED}Target : ${reset}"
read orga
echo -e  "${RED}Target domain: ${reset}"
read domaine

mkdir -p ./report/$orga

echo -e  "${RED}Discovery of URLs belonging to $domaine ${reset}"
echo $domaine | waybackurls > ./report/$orga/urls
echo ""
echo "File saved in ./report/$orga/urls"
echo ""

echo -e  "${RED}Recovery of URLs with main.js & app.js ${reset}"
cat ./report/$orga/urls | egrep 'main.js|app.js' > ./report/$orga/js
echo ""
echo "File saved in ./report/$orga/js"
echo ""
echo "---------------------------------------------------------------------------------------------"

unset option menu ERROR
declare -a menu
menu[0]=""

while IFS= read -r line; do
  menu[${#menu[@]}]="$line"
done < ./report/$orga/js


menu() {
  echo "Choose the JS file to analyze"
  echo ""
  for (( i=1; i<${#menu[@]}; i++ )); do
    echo "$i) ${menu[$i]}"
  done
  echo ""
}

menu
read option

while ! [ "$option" -gt 0 ] 2>/dev/null || [ -z "${menu[$option]}" ]; do
  echo "No such option '$option'" >&2
  menu
  read option
done

echo "---------------------------------------------------------------------------------------------"
echo "You have chosen the file '${menu[$option]}' to analyze"
echo ""
mkdir -p ./report/$orga/js-files
touch ./report/$orga/js-files/$option.txt
curl "${menu[$option]}"  > ./report/$orga/js-files/$option.txt

echo ""
echo "File saved in ./report/$orga/js-files/$option.txt"
echo ""
echo ""
echo ""
echo "---------------------------------------------------------------------------------------------"

echo -e  "${RED}Start of the file analysis  ./report/$orga/js-files/$option.txt ${reset}"
echo "Search for potential resources accessible via localhost"
localhost=$(cat ./report/$orga/js-files/$option.txt | grep -o "localhost" | wc -l); 
echo "Number of occurrences of the localhost pattern in ./report/$orga/js-files/$option.txt : $localhost times"
localh=$(cat ./report/$orga/js-files/$option.txt | grep -o "127.0.0.1" | wc -l); 
echo "Number of occurrences of the 127.0.0.1 in ./report/$orga/js-files/$option.txt : $localh times"
internal=$(cat ./report/$orga/js-files/$option.txt | grep -o "internal" | wc -l); 
echo "Number of occurrences of the internal in ./report/$orga/js-files/$option.txt : $internal times"
local=$(cat ./report/$orga/js-files/$option.txt | grep -o "local" | wc -l); 
echo "Number of occurrences of the local in ./report/$orga/js-files/$option.txt : $local times"
localdomain=$(cat ./report/$orga/js-files/$option.txt | grep -o "localdomain" | wc -l); 
echo "Number of occurrences of the localdomain in ./report/$orga/js-files/$option.txt : $localdomain times"
echo ""
localdomainA=$(cat ./report/$orga/js-files/$option.txt | grep -o "localdomain.$domaine" | wc -l); 
echo "Number of occurrences of the localdomain.$domaine in ./report/$orga/js-files/$option.txt : $localdomainA times"
localA=$(cat ./report/$orga/js-files/$option.txt | grep -o "local.$domaine" | wc -l); 
echo "Number of occurrences of the local.$domaine in ./report/$orga/js-files/$option.txt : $localA times"
internalA=$(cat ./report/$orga/js-files/$option.txt | grep -o "$org.internal" | wc -l); 
echo "Number of occurrences of the $org.internal in ./report/$orga/js-files/$option.txt : $internalA times"
localB=$(cat ./report/$orga/js-files/$option.txt | grep -o "$org.local" | wc -l); 
echo "Number of occurrences of the $org.local in ./report/$orga/js-files/$option.txt : $localB times"