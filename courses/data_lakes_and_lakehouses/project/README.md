# Project Overview
In this project, you'll build a data lake solution for Divvy bikeshare.

Divvy is a bike sharing program in Chicago, Illinois USA that allows riders to purchase a pass at a kiosk or use a mobile application to unlock a bike at stations around the city and use the bike for a specified amount of time. The bikes can be returned to the same station or to another station. The City of Chicago makes the anonymized bike trip data publicly available for projects like this where we can analyze the data.

Since the data from Divvy are anonymous, we have generated fake rider and account profiles along with fake payment data to go along with the data from Divvy.

## Divvy ERD
This image represents the data model for the dataset based on the Divvy Bikeshare data. The tables include: Rider, Account, Payment, Trip, and Station.
Relational ERD for the Divvy Bikeshare Dataset (with fake data tables)
![](../../cloud_data_warehouses/images/divvy-erd.png)

## Goal
The goal of this project is to develop a data warehouse solution using Azure Synapse Analytics. You will:

1. Design a star schema based on the business outcomes listed below;
2. Import the data into Synapse;
3. Transform the data into the star schema;
4. and finally, view the reports from Analytics.

## The business outcomes you are designing for are as follows:
Analyze how much time is spent per ride
- Based on date and time factors such as day of week and time of day
- Based on which station is the starting and / or ending station
- Based on age of the rider at time of the ride
- Based on whether the rider is a member or a casual rider

Analyze how much money is spent
- Per month, quarter, year
- Per member, based on the age of the rider at account start

EXTRA CREDIT - Analyze how much money is spent per member
- Based on how many rides the rider averages per month
- Based on how many minutes the rider spends on a bike per month

## Requirements
Use this project rubric to understand and assess the project criteria.

| Criteria | Submission Requirements | Deliverable |
|---|---|---|
| **Star Schema Design** <br> The student will be able to generate fact tables based on a business need and a relational model | The dimensional model should have two fact tables sharing common dimensions where applicable. One should be related to trip facts and another should be related to payment facts. The trip fact should have fields for trip duration and rider age at time of trip. The payment fact should have a field related to amount of payment. | See [Star Schema Design](#star-schema-diagram) |
| **Star Schema Design** <br> The student will be able to generate dimension tables based on business needs and a relational model | The star schema should have dimensions related to the trip fact table that are related to: riders, stations, and dates. The schema should have dimensions related to the payment fact table that are related to: dates and riders. | See [Star Schema Design](#star-schema-diagram) |
| **Extract Step**<br> Produce Spark code in Databricks using Jupyter Notebooks and Python scripts | The notebook should contain Python code to extract information from CSV files stored in Databricks and write it to the Delta file system. | See corresponding section in [divvy_bikeshare](./divvy_bikeshare.ipynb) notebook |
| **Extract Step**<br> Use distributed data storage using Azure Data Storage options | The notebook should contain Python code that picks files up from the Databricks file system storage and writes it out to Delta file locations. | See corresponding section in [divvy_bikeshare](./divvy_bikeshare.ipynb) notebook |
| **Load Step**<br> Implement key features of data lakes on Azure | The notebook should contain code that creates tables and loads data from Delta files. The learner should use spark.sql statements to create the tables and then load data from the files that were extracted in the Extract step. | See corresponding section in [divvy_bikeshare](./divvy_bikeshare.ipynb) notebook |
| **Transform Step**<br> Use Spark and Databricks to run ELT processes by creating fact tables | The fact table Python scripts should contain appropriate keys from the dimensions. In addition, the fact table scripts should appropriately generate the correct facts based on the diagrams provided in the first step. | See corresponding section in [divvy_bikeshare](./divvy_bikeshare.ipynb) notebook |
| **Transform Step**<br> Use Spark and Databricks to run ELT processes by creating fact tables | The dimension Python scripts should match the schema diagram. Dimensions should generate appropriate keys and should not contain facts. | See corresponding section in [divvy_bikeshare](./divvy_bikeshare.ipynb) notebook |
| **Transform Step**<br> Produce Spark code in Databricks using Jupyter Notebooks and Python scripts | The transform scripts should at minimum adhere to the following: should write to delta; should use overwrite mode; save as a table in delta. | See corresponding section in [divvy_bikeshare](./divvy_bikeshare.ipynb) notebook |

## Star schema Diagram
[Here](../../cloud_data_warehouses/project/diagrams/divvy_erd.pdf) you can find the Star Schema for the Divvy Bikeshare Dataset project; generated using mermaid.js from the corresponding code in the file [divvy_erd.mmd](../../cloud_data_warehouses/project/diagrams/divvy_erd.mmd).
```mermaid
erDiagram
    DIM_RIDER {
        int rider_id PK 
        bigint rider_key "surrogate key"
        string first
        string last
        string address
        date birthday_date
        int account_start_date_key "REFERENCES DIM_DATE(date_key)"
        int account_end_date_key "REFERENCES DIM_DATE(date_key)"
        bit is_member
        int rider_age_at_account_start
    }

    DIM_STATION {
        int station_id PK
        string station_KEY "surrogate key"
        string name
        float latitude
        float longitude
    }

    DIM_DATE {
        int date_key PK "surrogate key"
        date date_date
        int year
        int quarter
        int month
        int week_of_year
        int weekday
        bit is_weekend
    }

    DIM_TIME {
        int time_key PK "surrogate key"
        time time
        int hour
        int minute
        string time_of_day
        bit is_rush_hour
    }

    FACT_TRIP {
        string trip_id
        bigint rider_key "Rerences DIM_RIDER(rider_key)"
        int start_date_key "Rerences DIM_DATE(date_key)"
        int start_time_key "Rerences DIM_TIME(time_key)"
        int end_date_key "Rerences DIM_DATE(date_key)"
        int end_time_key "Rerences DIM_TIME(time_key)"
        int trip_duration_minutes
        string start_station_key "Rerences DIM_STATION(station_KEY)"
        string end_station_key "Rerences DIM_STATION(station_KEY)"
        int rider_age_at_trip_start
    }

    FACT_PAYMENT {
        bigint payment_id PK 
        int date_key "Rerences DIM_DATE(date_key)"
        bigint rider_key "Rerences DIM_RIDER(rider_key)"
        float amount
    }

    DIM_RIDER ||--o{ FACT_TRIP : "rider_key"
    DIM_STATION ||--o{ FACT_TRIP : "start_station_key / end_station_key"
    DIM_DATE ||--o{ FACT_TRIP : "start_date_key / end_date_key"
    DIM_TIME ||--o{ FACT_TRIP : "start_time_key / end_time_key"
    DIM_RIDER ||--o{ FACT_PAYMENT : "rider_key"
    DIM_DATE ||--o{ FACT_PAYMENT : "date_key"
```

## Screen shots
Here are some screenshots of the successful completion of the project in Databricks:
- DBFS showing the ingested data + (some early failed attempts... whoops) ![](../images/dbfs.png)
- All tables created in the database ![](../images/all_tables_in_hive.png)
- Notebook in shared workspace ![](../images/notebook.png)