STA 250 HW 1 Notes

# This file contains tidbits of previous attempts at methods
# for personal reference.

# append this to existing method 1 code
# DON'T just use built in functions for mean/med/sd
| sort | uniq -c > file)

# Regular Expressions Notes

ls | egrep '(1[0-9]{3}.csv|200[^1|2].csv)'
# Identifies all old files except for 2001.csv and 2002.csv

ls | egrep '200[1|2].csv'
# Identifies 2001.csv and 2002.csv


# *** For only pre-2008 files ***
# This connection concatenates every CSV file in the
# directory, removing the 15th column (which has
# arrival delays), and removing the column title

con1 = pipe("cat *.csv | cut -f 15 -d, | egrep -v '^$' |
            egrep -v 'ArrDelay'")
open(con1, open="r")
del.old = readLines(con1)
# system.time(readLines(con1))
close(con1)

# Convert to numeric to remove quotes and perform calcs
# This will coerce NAs
del.old = as.numeric(del.old)

# At this point we can use built in functions to find the
# mean, median, and standard deviation
mean(del.old, na.rm = TRUE)
median(del.old, na.rm = TRUE)
sd(del.old, na.rm = TRUE)

# NOTE: This method is not ideal due to the possibility of
# overflow or numerical inaccuracy with such a large
# dataset. Subsequent methods will take this into account
# and pursue more reliable calculations.

# *** For only 2008-onward files ***

# Due to a change in format, the arrival delays are in
# column 43 now. The titles also don't match up due to
# the existence of commas in both ORIGIN and DEST columns.
# Thus, we move over two spaces to column 45 for the values.

# This connection concatenates every CSV file in the
# directory, removing the 45th column (which has
# arrival delays), and removing the column title.
# It also removes NULL values, which can appear in this
# new format
# NOTE: grep to remove NULL taken from Piazza

con2 = pipe('cat *.csv | cut -f 45 -d, | egrep -v "^$" |
            egrep -v "ARR_DEL15"')
open(con2, open="r")
del.new = readLines(con2)
# time = system.time(readLines(con2))
close(con2)

del.new = as.numeric(del.new)
mean(del.new)
median(del.new)


# *** OLD WORK ***
# Before combining the two types

# Since data format differs between pre-2008 and 2008-onward
# files, we perform TWO readings

# For pre-2008 files
ls | egrep '[0-9]{4}.csv'

$oldfiles=$(ls | egrep '[0-9]{4}.csv')

# For 2008-onward files
ls | egrep '[a-z].csv'

$newfiles=$(ls | egrep '[a-z].csv')

# Reads data from files, isolates 15th column of
# Arrival Delays, and removes the column's "ArrDelay" title 
# Repeats for all files with only numbers in name (pre-2008)

# First set working directory to be the one with the CSV files.

con1 = pipe("oldfiles=$(ls | egrep '[0-9]{4}.csv') \
           cat $oldfiles | cut -f 15 -d, | egrep -v '^$' |
           egrep -v 'ArrDelay'")
open(con1, open="r")
del.old = readLines(con1)

# system.time(readLines(con))
close(con1)

# Reads data from files, isolates 45th column of
# Arrival Delays, and removes the column's "ArrDelay" title 
# Repeats for all files with letters in name (2008-onward)

con2 = pipe("newfiles=$(ls | egrep '[a-z].csv') \
            cat $newfiles | cut -f 45 -d, | egrep -v '^$' |
            egrep -v 'ARR_DEL15'")
open(con2, open="r")
del.new = readLines(con2)
close(con2)




# Shell code
# Unzips the chosen .bz2 file and returns the 15th column's
# values only, while delimiting the commas (",")
# bunzip2 -c 1990.csv.bz2 | cut -f 15 -d "," | grep -v ArrDelay


# Using in R - now defines, opens, and closes connections
con = pipe("bunzip2 -c 199* | cut -f 15 -d, | grep -v ArrDelay")
open(con, open="r")
x = readLines(con)
# TIME: (21.5, 0.224, 13.699) - actual = 13.699 (?)
# system.time(readLines(pipe("bunzip2 -c 1990.csv.bz2 | cut -f 15 -d,")))
close(con)

x.mod = as.numeric(x)

# These work for one file, but could lead to overflow
# for larger data sets.
mean(x.mod, na.rm = TRUE)
median(x.mod, na.rm = TRUE)
sd(x.mod, na.rm = TRUE)




# ** Working with .tar.bz2

# This observes which files are within. Note that this
# takes several minutes due to the size of the files!
tar -jtvf Delays1987_2013.tar.bz2


# Attempting to apply to all files

con2 = pipe("tar -xjvf -O Delays1987_2013.tar.bz2 1990.csv |
            cut -f 15 -d "," | grep -v ArrDelay")



# Frequency Tables (may include as a later method)

x.tab = data.frame(table(x.mod))
x.tab = x.tab[1:738,] #(removes NA counts - don't always do!)
x.time = as.numeric(as.matrix(x.tab[1]))
x.count = as.numeric(as.matrix(x.tab[2]))

# Mean of the values (simplify this!)
mean((sum(x.time*x.count))/sum(x.count))
# result is same as mean(x.mod, na.rm = TRUE)
# CLOSE YOUR CONNECTIONS!

# Identifies NA values
x.mod[is.na(x.mod) == TRUE]




# Separate test
con2 = pipe('cat 2008_April.csv 2009_April.csv | cut -f 45 -d, | egrep -v "^$"')
open(con2, open="r")
del.new = readLines(con2)
close(con2)

head(del.new)
del.new = del.new[2:length(del.new)]
del.new = as.numeric(del.new)
mean(del.new, na.rm = TRUE)

con2 = pipe("cat 2010_April.csv | cut -f 45 -d, | egrep -v '^$' |
              egrep -v 'ARR_DEL15' ")
open(con2, open="r")
del.new2 = readLines(con2)
close(con2)

head(del.new2)
del.new2 = del.new2[2:length(del.new2)]
del.new2 = as.numeric(del.new2)
del.combo = c(del.new,)

con2 = pipe("newfiles=$(ls | egrep '[a-z].csv') \
           cat $newfiles | cut -f 45 -d, | egrep -v '^$'")
open(con2, open="r")
del.new = readLines(con2)
close(con2)