# Day 06 – File Read/Write Practice

Aaj maine basic file read aur write commands practice kiye.  
Ek simple text file banayi aur usme lines add karke read ki.

## Commands Used

touch notes.txt  
Isse ek empty file create hui.

echo "Linux practice start" > notes.txt  
Is command se first line file me add hui. Old content overwrite hota hai.

echo "Practicing file read and write commands" >> notes.txt  
Isse next line file ke end me add hui.

echo "Using tee command also" | tee -a notes.txt  
Is command se line file me bhi add hui aur screen par bhi show hui.

cat notes.txt  
File ka full content check kiya.

head -n 2 notes.txt  
File ki first 2 lines dekhi.

tail -n 2 notes.txt  
File ki last 2 lines dekhi.

## Observation

Redirection commands ka use karke file me data write karna easy laga.  
tee command useful hai jab output screen par bhi dekhna ho aur file me bhi save karna ho.  
Ye basic commands logs aur config files handle karte time daily use honge.
