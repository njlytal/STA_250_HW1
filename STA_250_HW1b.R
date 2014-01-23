# STA 250 HW 1 Part 2: Method 2
# Author: Nicholas Lytal (991834259)


# *** Method 2: Using SQLite to calculate values ***

# open RSQLite
# First set working directory to the one containing
# your CSV files.
setwd("~/Desktop/STA_250_HW1")

start = proc.time() # Begins timing
db = dbConnect('SQLite', dbname = "Airline.sqlite")

# As explained in HW1a, this contains all necessary
# shell commands to isolate arrival delays
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

# Converts piped in data to a data frame for insertion
# into a database
delays = as.data.frame(delays)

# Creates table
dbWriteTable(db, name = "ArrDelay", value = delays)

# Takes average
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
# Here, variance is "expected value of delays squared" minus
# the "square of expected value of delays"
sd = as.numeric(sqrt(dbGetQuery(db, 'SELECT (AVG(delays*delays) -
                AVG(delays)*AVG(delays))
                FROM ArrDelay;')))

# Disconnects from database
dbDisconnect(db)
time = proc.time() - start # Ends time recording

# Creates list with all important values
results2 = list(time = time, results = c(mean = mu, median = med, sd = sd),
               system = Sys.info(),  session = sessionInfo(),
               computer = c(RAM = "16 GB 1600 MHz DDR3",
                            CPU = "2.6 GHz Intel Core i7",
                            Software = "OS X 10.8.5 (12F45)"))

# ************************************************************
# ************************************************************
# *** Method 3: Using a frequency table to calculate values ***

start = proc.time() # Begins timing

# As explained in HW1a, this contains all necessary
# shell commands to isolate arrival delays
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

# Converts values into a frequency table
delays = data.frame(table(delays))

#removes NA counts, contained in last row of table
delays = delays[1:nrow(delays)-1,] 
# All possible delay times
d.time = as.numeric(as.matrix(delays[1])) 
# Frequency of each time
d.count = as.numeric(as.matrix(delays[2])) 

n = sum(d.count) # Number of entries
sum.prod = sum(d.time*d.count) # sum of products
sum.prod2 = sum((d.time^2)*d.count) # sum of counts by time squared

# Mean of the values
# Takes sum of all products and divides by total # entries
mu = mean((sum.prod)/n)

# Median of the values
# Orders all values and takes middle one
med = sort(rep(d.time,d.count))[n/2]

# Std. dev. of the values
# Uses formula for variance (with n-1 correction),
# then takes square root
sd = sqrt((sum.prod2 - (sum.prod^2)/n)/(n-1))

time = proc.time() - start

# Creates list with all important values
results3 = list(time = time, results = c(mean = mu, median = med, sd = sd),
               system = Sys.info(),  session = sessionInfo(),
               computer = c(RAM = "16 GB 1600 MHz DDR3",
                            CPU = "2.6 GHz Intel Core i7",
                            Software = "OS X 10.8.5 (12F45)"))

# ************************************************************
# ************************************************************
# *** Plots ***

# With results files from each of the three methods, we can
# plot the data with these commands:

par(mfrow=c(2,2))
# Mean Results
plot(c(results1$results[1],results2$results[1],results3$results[1]),
     col = c('red','black','blue'), xlab = "Method Used", ylab = "Mean",
     main = "Mean according to Methods", ylim = c(6.4,6.6), pch = 15)

# Median Results
plot(c(results1$results[2],results2$results[2],results3$results[2]),
     col = c('red','black','blue'), xlab = "Method Used", ylab = "Median",
     main = "Median according to Methods", pch = 15)

# Standard Deviation Results
plot(c(results1$results[3],results2$results[3],results3$results[3]),
     col = c('red','black','blue'), xlab = "Method Used", ylab = "Std Dev",
     main = "Standard Deviation according to Methods", ylim = c(31,32),
     pch = 15)

# Time Elapsed
plot(c(results1$time[3],results2$time[3],results3$time[3]),
     col = c('red','black','blue'), xlab = "Method Used", ylim = c(0,3000),
     ylab = "Time (sec)", main = "Time Elapsed by Method", pch = 15)

legend("topright", c("Direct Input", "SQLite", "Freq. Table"),
       col = c('red','black','blue'), pch = 15)

