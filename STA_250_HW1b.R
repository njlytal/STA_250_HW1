# STA 250 HW 1 Part 2: Method 2
# Author: Nicholas Lytal (991834259)


# Method 1 Correction:
con3 = pipe("oldfiles=$(ls | egrep '(1[0-9]{3}.csv|200[^1|2].csv)' \
           specfiles=$(ls | egrep '200[1|2].csv') \
           newfiles=$(ls | egrep '[a-z].csv') \
           cat $oldfiles | cut -f 15 -d, | egrep -v '^$' |
           egrep -v 'ArrDelay' \
           cat $specfiles | cut -f 15 -d , | egrep -v '^$' |
           egrep -v 'ArrDelay'
           cat $newfiles | cut -f 45 -d, | egrep -v '^$' |
            egrep -v 'ARR_DEL15'")

# Method 2: Using a frequency table to calculate values



# Method 3: Using SQL
# open RSQLite
setwd("~/Desktop/STA_250_HW1")
db = dbConnect('SQLite', dbname = "Airline.sqlite")

# Writes a table for one CSV file
dbWriteTable(db, name="1987Y", value = "1987.csv",
             header = TRUE)
grep('[0-9]{4}.csv', "~/Desktop/STA_250_HW1")

x = dbGetQuery(db, 'SELECT AVG(ArrDelay) FROM Year1987;')


conSQL = pipe("ls | egrep '[0-9]{4}.csv' ")
open(conSQL, open="r") # Opens the defined connection to read
files = readLines(conSQL) # files to load into database
# Replaces csv file names with valid table titles
Yfiles = gsub("([0-9]{4}).csv", "Y\\1", files)

close(conSQL) # Closes defined connection

# Sample for uploading 3 files (Works!)
for(i in 1:3)
{
  dbWriteTable(db, name = Yfiles[i], value = files[i] )
}





# Consider using C
