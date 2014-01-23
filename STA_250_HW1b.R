# STA 250 HW 1 Part 2: Method 2
# Author: Nicholas Lytal (991834259)


# NOTE: Due to difficulty piping in sed commands to R, we construct a 
# separate file for the 2001 and 2002 data.

# Shell code to make separate file
cat $specfiles | sed -e 's/\xe4\xe6//g' | cut -f 15 -d , |
  egrep -v '^$' | egrep -v 'ArrDelay' > 2001-2002.csv

# Method 1 Correction:
con3 = pipe("oldfiles=$(ls | egrep '1[0-9]{3}.csv|200[^1|2].csv') \
           newfiles=$(ls | egrep '[a-z].csv') \
           cat $oldfiles | cut -f 15 -d, | egrep -v '^$' |
           egrep -v 'ArrDelay' \
           cat 2001-2002.csv | cut -f 15 -d , | egrep -v '^$' |
           egrep -v 'ArrDelay' \
           cat $newfiles | cut -f 45 -d, | egrep -v '^$' |
           egrep -v 'ARR_DEL15'")

# Method 2: Using a frequency table to calculate values




# Method 3: Using SQL - COMPLETE

# open RSQLite
setwd("~/Desktop/STA_250_HW1")
db = dbConnect('SQLite', dbname = "Airline.sqlite")

# SAMPLE: Writes a table for one CSV file
# dbWriteTable(db, name="Y1987", value = "1987.csv",
#             header = TRUE)
# grep('[0-9]{4}.csv', "~/Desktop/STA_250_HW1")
# x = dbGetQuery(db, 'SELECT AVG(ArrDelay) FROM Data;')


con = pipe(" cat 2001-2002.csv | cut -f 15 -d , | egrep -v '^$' | egrep -v 'ArrDelay'")
open(con, open="r") 
delays = readLines(con) 
close(con) 

start = proc.time()

db = dbConnect('SQLite', dbname = "Airline.sqlite")
con = pipe("oldfiles=$(ls | egrep '1[0-9]{3}.csv|200[^1|2].csv') \
           newfiles=$(ls | egrep '[a-z].csv') \
           cat $oldfiles | cut -f 15 -d, | egrep -v '^$' |
           egrep -v 'ArrDelay' \
           cat 2001-2002.csv | cut -f 15 -d , | egrep -v '^$' |
           egrep -v 'ArrDelay' \
           cat $newfiles | cut -f 45 -d, | egrep -v '^$' |
           egrep -v 'ARR_DEL15'")


open(con, open="r") 
delays = readLines(con) 
close(con) 

delays = as.data.frame(delays)
dbWriteTable(db, name = "ArrDelay", value = delays)

mu = as.numeric(dbGetQuery(db, 'SELECT AVG(delays) FROM ArrDelay;'))

# This orders the values (ORDER BY), then chooses either
# LIMIT 1 if an odd number of values exists, or LIMIT 2
# if an even number of values exists. After this,
# OFFSET (SELECT (COUNT*) - 1)/2 skips to the middle column/s
# and takes their average.
# NOTE: code from http://stackoverflow.com/questions/15763965/
# how-can-i-calculate-the-median-of-values-in-sqlite

med = as.numeric(dbGetQuery(db, 'SELECT AVG(delays)
      FROM (SELECT delays
            FROM ArrDelay
            ORDER BY delays
            LIMIT 2 - (SELECT COUNT(*) FROM ArrDelay) % 2
            OFFSET (SELECT (COUNT(*) - 1) / 2
            FROM ArrDelay))'))

# Queries the variance, then takes square root to get sd
sd = as.numeric(sqrt(dbGetQuery(db, 'SELECT (AVG(delays*delays) -
                AVG(delays)*AVG(delays))
                FROM ArrDelay;')))
dbDisconnect(db)
time = proc.time() - start

# Creates list with all important values
results = list(time = time, results = c(mean = mu, median = med, sd = sd),
               system = Sys.info(),  session = sessionInfo(),
               computer = c(RAM = "16 GB 1600 MHz DDR3",
                            CPU = "2.6 GHz Intel Core i7",
                            Software = "OS X 10.8.5 (12F45)"))