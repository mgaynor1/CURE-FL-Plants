# Bash make the folders
cat specieslist.txt | while read line 
do 
mkdir training/$line
done