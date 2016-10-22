1. Merges the training and the test sets to create one data set.
   Step 1.1 Download data sets:
   
   			> if (!file.exists("./data")){dir.create("./data")}
   			> fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
   			> download.file(fileURL, destfile = "./data/hciDataset.zip", method="curl") 
   
   Step 1.2 Extract files from compressed zip file
   			> ?unzip //view the help for unzip
   			> unzip("./data/hciDataset.zip", exdir = "./data")
   
   Step 1.3 Read Data sets in the following files sets:
   			 (a) Training Data: ./data/UCI HAR Dataset/train/X_train.txt; ./data/UCI HAR Dataset/train/y_train.txt  
   			 (b) Test Data:     ./data/UCI HAR Dataset/test/X_test.txt;   ./data/UCI HAR Dataset/test/y_test.txt
   			 (c) Subject Data: 	./data/UCI HAR Dataset/train/subject_train.txt;   ./data/UCI HAR Dataset/test/subject_test.txt 
   			 (d) Features:		./data/UCI HAR Dataset/features.txt
   			 (e) Activity Labels ./data/UCI HAR Dataset/activity_labels.txt 
   			 
   			 > xTrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
   			 > yTrain <- read.table("./data/UCI HAR Dataset/train/Y_train.txt")

   			 > xTest <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
   			 > yTest <- read.table("./data/UCI HAR Dataset/test/y_test.txt")

   			 > subjTrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
   			 > subjTest <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
   			 
   			 > features <- read.table("./data/UCI HAR Dataset/features.txt")
   			 > actLabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
   			 	
   			 
   			 Dimensions of the above Tables
   			 
   			 xTrain:	7352, 561
   			 Ytrain:	7352, 1
   			 
   			 xTest:		2947, 561
   			 yTest:		2947, 1
   			 
   			 subjTest:	7352, 1
   			 subjTrain:	2947, 1
   			 
   			 features: 	561, 2   (accelerometer and gyroscope; these are the 561 features or column names for X and Y tables)
   			 actLabels: 6,   2     (6 activity types: WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING)

   Step 1.4 Assign appropriate column names to the tables using the features and activity labels:
      			 
   			 Assign Column names to X tables (instead of V1, V2, etc.) using the features names
   			 Assign Column names to Y tables (instead of V1) as "actID"
   			 Assign Column names to Subject tables (instead of V1) as "subjID"
   			 Assign Column names to Acivity Labels (instead of V1, V2)
   			 
   			 > colnames(xTrain) = features[,2] 
   			 > colnames(xTest) = features[,2] 
 
    		 > colnames(yTrain) = "actID"		  
  			 > colnames(yTest) = "actID"
  			 
  			 > colnames(subjTest) = "subjID"
  			 > colnames(subjTrain) = "subjID"
  			 
  			 > colnames(actLabels) = c("actID", "actType")
  			 
   Step 1.5 Now, merge all the Test and Training data, respectively.
   			For each of the above, merge (Y, subject, X)
   			
   			> ?cbind // combine data frames by columns
   			> mergeDataTrain <- cbind(yTrain, subjTrain, xTrain)
			> mergeDataTest <- cbind(yTest, subjTest, xTest) 
			
			> dim(mergeDataTest)
			 [1] 2947  563
			> dim(mergeDataTrain)
			 [1] 7352  563
			 
  			Merge the complete set of Training and Testing Data
  			> mergeData <- rbind(mergeDataTrain, mergeDataTest)
  			 
  			> dim(mergeData)
			  [1] 10299   563
  			 
  			Remove all the other table vectors
  			> rm(mergeDataTest)
			> rm(mergeDataTrain)
			 
   			
2. Extracts only the measurements on the mean and standard deviation for each measurement.

	Step 2.1 Search for column names that refer to "mean" or "std"
	
			> ?grep //returns character vector
			> ?grepl // returns logical vector

			> grep("mean", colnames(mergeData))
			> grep("std", colnames(mergeData))
			
	Step 2.2 Prepare a vector of all columns that provide mean and standard deviation
			 Also include the first 2 columns with the Activity and Subject IDs
			 
			 > col_mean_std <- c(1,2,grep("std", colnames(mergeData)), grep("mean", colnames(mergeData)))
			 
	Step 2.3 Extract all measurements with the above columns
			> mean_std_data <- mergeData[, col_mean_std]
			
			> dim(mean_std_data)
			  [1] 10299    81
			  
			  
3. Uses descriptive activity names to name the activities in the data set

	Step 3.1 Using decsriptive activity names from Activity Labels (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING)
			 Activity labels are stored in the data frame: actLabels (read in step 1.3)
			 
			 > ?merge
			 > mean_std_act_data <- merge(actLabels, mean_std_data, by="actID")
			 
			 > head(mean_std_act_data)
			 
			 Confirm that the number of rows is intact (using nrow); number of columns should now be 82
			 

4. Appropriately labels the data set with descriptive variable names.

	This was completed earlier in Step 1.4
	
			 > colnames(mean_std_act_data)

5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
	
	Step 5.1 > tidyData2 <- aggregate(.~(subjID+actID+actType), mean_std_act_data, mean)
	
	Step 5.2 Sort the tidy data by subject,activity
	
			> tidyDataSorted <- tidyData2[order(tidyData2$subjID, tidyData2$actID), ]
			

    "tidyDataSorted" provides the mean for every subject (30 subjects or volunteers) for each of the acitivy (6 activities).
 
    Step 5.3 Label data set with descriptive variable names
			colDataSorted <- colnames(tidyDataSorted)
			colDataSorted <- gsub("act", "Activity", colDataSorted)
			colDataSorted <- gsub("subj", "Subject", colDataSorted)
			colDataSorted <- gsub("-mean", "Mean", colDataSorted)
			colDataSorted <- gsub("-std", "Std", colDataSorted)
			colDataSorted <- gsub("[-()]", "", colDataSorted)
			colnames(tidyDataSorted) = colDataSorted
          
6. Write the Tidy Data set to a text file in "./data"

			> ?write.table
			> write.table(tidyDataSorted, "./data/tidyDataSorted.txt", row.name = FALSE)
	