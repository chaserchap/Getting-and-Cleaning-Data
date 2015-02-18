# Getting and Cleaning Data Class Project
Chase Chapman  
Wednesday, February 18, 2015  

# Description

The script assumes that you already have the data downloaded and stored in your
working directory in its original format. This is the starting point as 
prescribed by the assignment. If you do not have the data you can get it from 
[here](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
. Extract the contents directly to your working directory.

## Call necessary packages

Call packages used in the remainder of the code.


```r
require("dplyr")
```

```
## Loading required package: dplyr
## 
## Attaching package: 'dplyr'
## 
## The following object is masked from 'package:stats':
## 
##     filter
## 
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

## Read all data.

The following lines read in all the tables containing data we will need for the
project. The paste() function combines your working directory with the rest of 
the location for the files.


```r
subject_train <- read.table(paste(getwd(),"/UCI HAR Dataset/train/subject_train.txt",sep=""))
x_train <- read.table(paste(getwd(),"/UCI HAR Dataset/train/X_train.txt",sep=""))
y_train <- read.table(paste(getwd(),"/UCI HAR Dataset/train/y_train.txt",sep=""))
labels <- read.table(paste(getwd(),"/UCI HAR Dataset/activity_labels.txt",sep=""))
feats <- read.table(paste(getwd(),"/UCI HAR Dataset/features.txt",sep=""))
subject_test <- read.table(paste(getwd(),"/UCI HAR Dataset/test/subject_test.txt",sep=""))
x_test <- read.table(paste(getwd(),"/UCI HAR Dataset/test/X_test.txt",sep=""))
y_test <- read.table(paste(getwd(),"/UCI HAR Dataset/test/y_test.txt",sep=""))
```

## Set column names to the applicable features

The following adds all the features that were measured to the column names of 
the train and test files containing the normalized measurements


```r
colnames(x_train) <- feats[,2]
colnames(x_test) <- feats[,2]
```

## Insert the subject into the applicable table

Adds the subjects to the data tables


```r
x_train$subject <- subject_train[,1]
x_test$subject <- subject_test[,1]
```

## Insert the activity code into the applicable table

Adds the activity codes to the data tables.


```r
x_train$activity <- y_train[,1]
x_test$activity <- y_test[,1]
```

## Combine the two sets of data

This combines the two sets of data into one, binding them by rows.


```r
x_final <- rbind(x_test,x_train)
```

## Clear data no longer needed

The listed data frames are no longer necessary and can be cleared from the
working directory to free up memory.


```r
rm(list = c("feats","subject_test","subject_train","x_test","x_train","y_test","y_train"))
```

## Drop all data but the means, averages, subject, and activity

Sorts out the data retaining only the subject and activity columns and any 
column containing the string "mean" or "std". Based on the features_info file 
the meanFreq value is not a mean specifically concerning the measured variables,
so they are removed. Finally, renames the subject and activity columns to their
original names.


```r
x_tidy <- x_final[,grep("subject",colnames(x_final))]
x_tidy <- cbind(x_tidy,x_final[,grep("activity",colnames(x_final))])
x_tidy <- cbind(x_tidy,x_final[,grep("mean",colnames(x_final))])
x_tidy <- cbind(x_tidy,x_final[,grep("std",colnames(x_final))])
x_tidy <- x_tidy[,-grep("meanFreq",colnames(x_tidy))]
names(x_tidy)[1:2] <- c("subject","activity")
```

## Add activity names

Merges the labels data frame with the working data frame to include the activity
labels instead of the numbered codes. It then moves the merged column to the 
original activity column and cuts out the added merge column. Finally it removes
the labels data to clear unnecessary data from memory.


```r
x_tidy <- merge(x_tidy,labels,by.x = "activity",by.y = "V1")
x_tidy$activity <- x_tidy$V2
x_tidy <- x_tidy[,1:68]
rm(labels)
```

## Get averages

Gets averages for each measurement for each subject and each activity. The first
line creates the tidy data frame and takes the applicable averages for the first
subject. The for loop takes the averages and rbinds them to the tidy data frame
using an intermediary data frame named "hold." Finally it clears out the rest of
the unneeded data. Note that this data frame is a wide form of the original data
with each variable in a single column and each observation (for each subject and
activity) in a separate row.


```r
tidy <- x_tidy %>% subset(subject == 1) %>% group_by(activity) %>% summarise_each(funs(mean), -activity)
for(i in 2:30){
    hold <- x_tidy %>% subset(subject == i) %>% group_by(activity) %>% summarise_each(funs(mean), -activity)
    tidy <- rbind(tidy,hold)
}
rm(list = c("x_final","x_tidy","hold","i"))
```

## Create the .txt file with the tidy dataset

Writes the data frame to a .txt file without maintaining row names.


```r
write.table(tidy,"tidyproject.txt",row.names = FALSE)
```

## Reading the data

The following code reads the data into R, stores it in variable "data" and 
prints the first 10 rows and four columns. Bear in mind, this is not required by 
the project, but allows you a quick verification that the file produced is the
same as the one uploaded.


```r
data <- read.table("tidyproject.txt",header=TRUE)
data[1:10,1:4]
```

```
##              activity subject tBodyAcc.mean...X tBodyAcc.mean...Y
## 1              LAYING       1         0.2215982      -0.040513953
## 2             SITTING       1         0.2612376      -0.001308288
## 3            STANDING       1         0.2789176      -0.016137590
## 4             WALKING       1         0.2773308      -0.017383819
## 5  WALKING_DOWNSTAIRS       1         0.2891883      -0.009918505
## 6    WALKING_UPSTAIRS       1         0.2554617      -0.023953149
## 7              LAYING       2         0.2813734      -0.018158740
## 8             SITTING       2         0.2770874      -0.015687994
## 9            STANDING       2         0.2779115      -0.018420827
## 10            WALKING       2         0.2764266      -0.018594920
```
