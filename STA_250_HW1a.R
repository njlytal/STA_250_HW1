# STA 250 HW 1 Part 1: Method 1
# Author: Nicholas Lytal (991834259)

# Method 1: Piping in shell commands through R to
# read columns of CSV files and create a vector
# of arrival delays.

# In this case, all .csv files have already been extracted
# from Delays1987_2013.tar.bz2 with the shell command
# "tar -xjvf Delays1987_2013.tar.bz2"

# All CSV files should be placed in the same directory
# NOTE: Due to difficulty piping in sed commands to R, we construct a 
# separate file for the 2001 and 2002 data.

# Shell code to make this separate file
cat $specfiles | sed -e 's/\xe4\xe6//g' | cut -f 15 -d , |
  egrep -v '^$' | egrep -v 'ArrDelay' > 2001-2002.csv


# *** For only pre-2008 files ***
# This connection concatenates every CSV file in the
# directory, removing the 15th column (which has
# arrival delays), and removing the column title

# NOTE: con1 and con2 are not used, merely shown to
# demonstrate how they WOULD work
con1 = pipe("cat *.csv | cut -f 15 -d, | egrep -v '^$' |
            egrep -v 'ArrDelay'")

# *** For only 2008-onward files ***

# Due to a change in format, the arrival delays are in
# column 43 now. The titles also don't match up due to
# the existence of commas in both ORIGIN and DEST columns.
# Thus, we move over two spaces to "column 45" for the
# correct values according to the comma delimiter.

# This connection concatenates every CSV file in the
# directory, removing the 45th column (which has
# arrival delays), and removing the column title.
# It also removes NULL values, which can appear in this
# new format
# NOTE: grep to remove NULL taken from Piazza

con2 = pipe('cat *.csv | cut -f 45 -d, | egrep -v "^$" |
            egrep -v "ARR_DEL15"')

# Since we would prefer to keep the files together in the
# same directory, we must take a different approach, rather
# than applying these commands to every single CSV file.


# This next connection combines the above, taking all CSVs in
# the same folder and performing different shell operations
# depending on which category the file falls into.

# Regular expressions are used to differentiate between
# "oldfiles" (pre-2008) and "newfiles" (2008-onward)

#specfiles=$(ls | egrep '[0-9]{4}.csv')

con = pipe("oldfiles=$(ls | egrep '1[0-9]{3}.csv|200[^1|2].csv') \
           newfiles=$(ls | egrep '[a-z].csv') \
           cat $oldfiles | cut -f 15 -d, | egrep -v '^$' |
           egrep -v 'ArrDelay' \
           cat 2001-2002.csv | cut -f 15 -d , | egrep -v '^$' |
           egrep -v 'ArrDelay' \
           cat $newfiles | cut -f 45 -d, | egrep -v '^$' |
           egrep -v 'ARR_DEL15'")

open(con, open="r") # Opens the defined connection to read
delays = readLines(con) # contains all arrival delays
close(con) # Closes defined connection

# At this point we can use built in functions to find the
# mean, median, and standard deviation.

# First, we convert the vector to numeric form to remove
# the inherent parentheses. This will coerce NA terms.
delays = as.numeric(delays)

# To take the desired values, we consider all non-NA
# values (but don't discard the NAs altogether).
mu = mean(delays, na.rm = TRUE)
med = median(delays, na.rm = TRUE)
sd = sd(delays, na.rm = TRUE)

# NOTE: This method is not ideal due to the possibility of
# overflow or numerical inaccuracy with such a large
# dataset. Subsequent methods will take this into account
# and pursue more reliable calculations.

# Time to perform all operations calculated here:
start = proc.time()
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

  delays = as.numeric(delays)
  
  mu = mean(delays, na.rm = TRUE)
  med = median(delays, na.rm = TRUE)
  sd = sd(delays, na.rm = TRUE)

time = proc.time() - start

# Creates list with all important values
results1 = list(time = time, results = c(mean = mu, median = med, sd = sd),
               system = Sys.info(),  session = sessionInfo(),
               computer = c(RAM = "16 GB 1600 MHz DDR3",
                            CPU = "2.6 GHz Intel Core i7",
                            Software = "OS X 10.8.5 (12F45)"))