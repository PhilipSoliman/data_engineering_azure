# NYC Data Analytics Platform
The City of New York would like to develop a Data Analytics platform on Azure Synapse Analytics to accomplish two primary objectives:

Analyze how the City's financial resources are allocated and how much of the City's budget is being devoted to overtime.
Make the data available to the interested public to show how the City’s budget is being spent on salary and overtime pay for all municipal employees.
You have been hired as a Data Engineer to create high-quality data pipelines that are dynamic, can be automated, and monitored for efficient operation. The project team also includes the city’s quality assurance experts who will test the pipelines to find any errors and improve overall data quality.

The source data resides in Azure Data Lake and needs to be processed in a NYC data warehouse. The source datasets consist of CSV files with Employee master data and monthly payroll data entered by various City agencies.

## Requirements
Use this project rubric to understand and assess the project criteria.

| Criteria | Submission Requirements | Deliverable |
|---|---|---|
| **1. Linked Services** <br> The learner will be able to create a Linked Service to configure a connection to Azure Data Lake Gen2 containing master data and payroll data. | A Linked Service object is present in the data pipeline repository of type "AzureBlobFS" that configures a connection to Azure Data Lake Gen2 containing master data and payroll data. | ... |
| **2. Linked Services** <br> The learner will be able to create a Linked Service in Azure Data Factory from Azure SQL Database to configure a connection to Azure SQL Database containing master data and payroll data. | A Linked Service object is present in the data pipeline repository of type "AzureSQLDatabase" that configures a connection to Azure SQL Database containing master data and payroll data. | ... |
| **3. Datasets**<br> The learner will be able to create datasets to provide views of master data and payroll data in Azure Data Lake Gen2. | Multiple dataset objects are present in the data pipeline repository of type "AzureBlobFSLocation" with schemas from "AgencyMaster.csv", "TitleMaster.csv", "EmpMaster.csv", “nycpayroll_2020.csv” and "nycpayroll_2021.csv" to provide datasets for data views from Azure Data Lake Gen2. | ... |
| **4. Datasets**<br> The learner will be able to create a dataset to provide a view of master data and payroll data in the Azure SQL DB table. | Multiple dataset objects are present in the data pipeline repository of type "AzureSqlTable" with schemas from the NYC Payroll Data, Agency, Employee, Title SQL DB tables SQL DB tables to provide a dataset for a data view. | ... |
| **5. Data Flows**<br> The learner will be able to create data flows to aggregate payroll data from Azure SQL DB and NYC Payroll history files o the SQL DB destination table and dirstaging Datalake Gen2 storage. | A Dataflow object is present in the data pipeline repository of type "MappingDataFlow" with a union to create a derived aggregated column with the total amount paid to an employee (TotalPaid = RegularGrossPaid + TotalOTPaid + TotalOtherPay). The data sources for this aggregate column should be the data from Azure SQL DB tables | ... |
| **6. Data Flows**<br> The learner should be able to create data flows to move data from one data storage system to another. | Multiple Dataflow objects are present in the data pipeline repository of type "MappingDataFlow". Data flows should map data in datasets from Azure Data Lake Gen2 to Azure SQL DB. Data flows should map data from Azure SQL DB and Data Lake Gen2 to move it to the Data Lake staging directory and SQL DB destination table. | ... |
| **7. Pipeline**<br> The student will be able to create a data pipeline containing Dataflow activities. | Multiple pipeline objects are present in the data pipeline repository with activities of type "ExecuteDataFlow" in the pipeline directory which contain Dataflow objects. | ... |
| **8. Pipeline**<br> The learner should be able to trigger a pipeline and execute the Dataflows in it. | A screenshot is present showing a successful pipeline execution in Azure Data Factory | ... |
| **9. Data Verification**<br> The student will be able to verify the final data after pipeline run in Datalake Gen2 storage, SQL DB table and Synapse table | Screenshots are present to show the data is saved in Gen2 storage, and query on SQL DB table and Synapse external table returns results. | ... |


## Create and configure resources
1. Create the data lake and upload data: <span style="color: green;">✓</span>. ![](../images/data_lake_uploaded_files_history.png) ![](../images/data_lake_uploaded_files_payroll.png)
2. Create an Azure Data Factory Resource: <span style="color: green;">✓</span>.
3. Create a SQL Database <span style="color: green;">✓</span>.
4. Create Synapse Analytics Workspace and configure external table: <span style="color: green;">✓</span>. 
5. Create summary data external table in Synapse Analytics workspace: <span style="color: green;">✓</span>. See [create_external_table.sql](./sql/create_external_table.sql) and ![](../images/external_table_created_in_synapse.png)
6. Create master data tables and payroll transaction tables in SQL DB: <span style="color: green;">✓</span>. See [create_master_tables.sql](./sql/create_master_tables.sql) and ![](../images/tables_in_sql_db.png)

## Create linked services
1.Create a Linked Service for Azure Data Lake: <span style="color: green;">✓</span>. ![](../images/adl_config_adf.png)
2. Create a Linked Service to SQL Database that has the current (2021) data: <span style="color: green;">✓</span>. ![](../images/asqldb_config_adf.png)
3. Screenshot of all linked services in ADF: <span style="color: green;">✓</span>. ![](../images/linked_services_in_adf.png)

## Step 3: Create datasets in ADF
1. Create the datasets for the 2021 Payroll file on Azure Data Lake Gen2: <span style="color: green;">✓</span>.
2. Repeat the same process to create datasets for the rest of the data files in the Data Lake: <span style="color: green;">✓</span>.
3. Create the dataset for all the data tables in SQL DB: <span style="color: green;">✓</span>.
4. Create the datasets for destination (target) table in Synapse Analytics: <span style="color: green;">✓</span>.
5. Capture screenshots of datasets in Data Factory: <span style="color: green;">✓</span>. ![](../images/datasets_in_adf.png)
6. Save configs of datasets from Data Factory: <span style="color: green;">✓</span>. See [datasets](./datasets/) folder.

## Step 4: Create Data Flows
1. Create a new data flow: <span style="color: green;">✓</span>.
2. Select the dataset for 2020 payroll file as the source: <span style="color: green;">✓</span>.
3. Click on the + icon at the bottom right of the source, from the options choose sink. A sink will get added in the dataflow: <span style="color: green;">✓</span>.
4. Select the sink dataset as 2020 payroll table created in SQL db: <span style="color: green;">✓</span>.
5. Repeat the same process to add data flow to load data for each file in Azure DataLake to the corresponding SQL DB tables: <span style="color: green;">✓</span>.6. Capture screenshots of data flows in Data Factory: <span style="color: green;">✓</span>. ![](../images/dataflows_in_adf.png)
7. Save configs of data flows from Data Factory: <span style="color: green;">✓</span>. See [dataflows](./dataflows/) folder.