# Merges the training and the test sets to create one data set.
#   Step 1.1 Download data sets:
   
if (!file.exists("./data")){dir.create("./data")}
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile = "./data/hciDataset.zip", method="curl") 
   
#   Step 1.2 Extract files from compressed zip file
unzip("./data/hciDataset.zip", exdir = "./data")
   
#   Step 1.3 Read Data sets in the following files sets:
#   			 (a) Training Data: ./data/UCI HAR Dataset/train/X_train.txt; ./data/UCI HAR Dataset/train/y_train.txt  
#   			 (b) Test Data:     ./data/UCI HAR Dataset/test/X_test.txt;   ./data/UCI HAR Dataset/test/y_test.txt
#   			 (c) Subject Data: 	./data/UCI HAR Dataset/train/subject_train.txt;   ./data/UCI HAR Dataset/test/subject_test.txt 
#   			 (d) Features:		./data/UCI HAR Dataset/features.txt
#   			 (e) Activity Labels ./data/UCI HAR Dataset/activity_labels.txt 
   			 
xTrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
yTrain <- read.table("./data/UCI HAR Dataset/train/Y_train.txt")

xTest <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
yTest <- read.table("./data/UCI HAR Dataset/test/y_test.txt")

subjTrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
subjTest <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
   			 
features <- read.table("./data/UCI HAR Dataset/features.txt")
actLabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
   			 	
#   Step 1.4 Assign appropriate column names to the tables using the features and activity labels:
      			 
#  			 Assign Column names to X tables (instead of V1, V2, etc.) using the features names
#  			 Assign Column names to Y tables (instead of V1) as "actID"
#  			 Assign Column names to Subject tables (instead of V1) as "subjID"
#  			 Assign Column names to Acivity Labels (instead of V1, V2)
   			 
colnames(xTrain) = features[,2] 
colnames(xTest) = features[,2] 
 
colnames(yTrain) = "actID"		  
colnames(yTest) = "actID"
  			 
colnames(subjTest) = "subjID"
colnames(subjTrain) = "subjID"
  			 
colnames(actLabels) = c("actID", "actType")
  			 
#   Step 1.5 Now, merge all the Test and Training data, respectively.
#   		For each of the above, merge (Y, subject, X)
   			
mergeDataTrain <- cbind(yTrain, subjTrain, xTrain)
mergeDataTest <- cbind(yTest, subjTest, xTest) 
			
# 	Merge the complete set of Training and Testing Data
mergeData <- rbind(mergeDataTrain, mergeDataTest)
  			 
#  	Remove all the other table vectors
rm(mergeDataTest)
rm(mergeDataTrain)
			 
   			
#2. Extracts only the measurements on the mean and standard deviation for each measurement.

#	Step 2.1 Search for column names that refer to "mean" or "std"
	
#grep("mean", colnames(mergeData))
#grep("std", colnames(mergeData))
			
#	Step 2.2 Prepare a vector of all columns that provide mean and standard deviation
#			 Also include the first 2 columns with the Activity and Subject IDs
			 
col_mean_std <- c(1,2,grep("\\bstd\\b", colnames(mergeData)), grep("\\bmean\\b", colnames(mergeData)))
			 
#	Step 2.3 Extract all measurements with the above columns
mean_std_data <- mergeData[, col_mean_std]
			
			  
#3. Uses descriptive activity names to name the activities in the data set

#	Step 3.1 Using decsriptive activity names from Activity Labels (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING)
#			 Activity labels are stored in the data frame: actLabels (read in step 1.3)
			 
mean_std_act_data <- merge(actLabels, mean_std_data, by="actID")
			 
#			 Confirm that the number of rows is intact (using nrow); number of columns should now be 82
			 

#4. Appropriately labels the data set with descriptive variable names.

#	This was completed earlier in Step 1.4
	

#5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
	
#	Step 5.1 > 
tidyData2 <- aggregate(.~(subjID+actID+actType), mean_std_act_data, mean)
	
#	Step 5.2 Sort the tidy data by subject,activity
	
tidyDataSorted <- tidyData2[order(tidyData2$subjID, tidyData2$actID), ]

#	Sort 5.3 Label data set with descriptive variable names
			
colDataSorted <- colnames(tidyDataSorted)
colDataSorted <- gsub("act", "Activity", colDataSorted)
colDataSorted <- gsub("subj", "Subject", colDataSorted)
colDataSorted <- gsub("-mean", "Mean", colDataSorted)
colDataSorted <- gsub("-std", "Std", colDataSorted)
colDataSorted <- gsub("[-()]", "", colDataSorted)
colnames(tidyDataSorted) = colDataSorted

#    "tidyDataSorted" provides the mean for every subject (30 subjects or volunteers) for each of the acitivy (6 activities).\
    
#6. Write the Tidy Data set to a text file in "./data"

write.table(tidyDataSorted, "./data/tidyDataSorted.txt", row.name = FALSE)
	