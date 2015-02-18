## This script assumes that you already have the required data downloaded and in
## your working directory.

## Read all data

subject_train <- read.table(paste(getwd(),"/UCI HAR Dataset/train/subject_train.txt",sep=""))
x_train <- read.table(paste(getwd(),"/UCI HAR Dataset/train/X_train.txt",sep=""))
y_train <- read.table(paste(getwd(),"/UCI HAR Dataset/train/y_train.txt",sep=""))
labels <- read.table(paste(getwd(),"/UCI HAR Dataset/activity_labels.txt",sep=""))
feats <- read.table(paste(getwd(),"/UCI HAR Dataset/features.txt",sep=""))
subject_test <- read.table(paste(getwd(),"/UCI HAR Dataset/test/subject_test.txt",sep=""))
x_test <- read.table(paste(getwd(),"/UCI HAR Dataset/test/X_test.txt",sep=""))
y_test <- read.table(paste(getwd(),"/UCI HAR Dataset/test/y_test.txt",sep=""))

## Set column names to the applicable features

colnames(x_train) <- feats[,2]
colnames(x_test) <- feats[,2]

## Insert the subject into the applicable table

x_train$subject <- subject_train[,1]
x_test$subject <- subject_test[,1]

## Insert the activity code into the applicable table

x_train$activity <- y_train[,1]
x_test$activity <- y_test[,1]

## Combine the two sets of data

x_final <- rbind(x_test,x_train)

## Clear data no longer needed

rm(list = c("feats","subject_test","subject_train","x_test","x_train","y_test","y_train"))

## Drop all data but the means, averages, subject, and activity

x_tidy <- x_final[,grep("subject",colnames(x_final))]
x_tidy <- cbind(x_tidy,x_final[,grep("activity",colnames(x_final))])
x_tidy <- cbind(x_tidy,x_final[,grep("mean",colnames(x_final))])
x_tidy <- cbind(x_tidy,x_final[,grep("std",colnames(x_final))])
x_tidy <- x_tidy[,-grep("meanFreq",colnames(x_tidy))]
names(x_tidy)[1:2] <- c("subject","activity")

## Add activity names

x_tidy <- merge(x_tidy,labels,by.x = "activity",by.y = "V1")
x_tidy$activity <- x_tidy$V2
x_tidy <- x_tidy[,1:68]
rm(labels)

## Get averages

tidy <- x_tidy %>% subset(subject == 1) %>% group_by(activity) %>% summarise_each(funs(mean), -activity)
for(i in 2:30){
    hold <- x_tidy %>% subset(subject == i) %>% group_by(activity) %>% summarise_each(funs(mean), -activity)
    tidy <- rbind(tidy,hold)
}
rm(list = c("x_final","x_tidy","hold","i"))

## Create the .txt file with the tidy dataset

write.table(tidy,"tidyproject.txt",row.names = FALSE)