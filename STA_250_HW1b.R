# STA 250 HW 1 Part 2: Method 2
# Author: Nicholas Lytal (991834259)

# Method 2: Using a frequency table to calculate values

| sort | uniq -c > file)

start = proc.time()
con3 = pipe("oldfiles=$(ls | egrep '(1[0-9]{3}.csv|200[^1|2].csv)' \
           specfiles=$(ls | egrep '200[1|2].csv') \
           newfiles=$(ls | egrep '[a-z].csv') \
           cat $oldfiles | cut -f 15 -d, | egrep -v '^$' |
           egrep -v 'ArrDelay' \
           
           cat $newfiles | cut -f 45 -d, | egrep -v '^$' |
            egrep -v 'ARR_DEL15'")

open(con3, open="r") 
del.both = readLines(con3) 
close(con3) 

del.both = as.numeric(del.both)

mu = mean(del.both, na.rm = TRUE)
med = median(del.both, na.rm = TRUE)
sd = sd(del.both, na.rm = TRUE)

time = proc.time() - start




# Method 3: Using FastCSVSample

# Terminal command to get FastCSVSample
$ git clone https://github.com/duncantl/FastCSVSample.git