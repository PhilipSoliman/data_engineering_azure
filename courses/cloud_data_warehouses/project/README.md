# Project Overview
Divvy is a bike sharing program in Chicago, Illinois USA that allows riders to purchase a pass at a kiosk or use a mobile application to unlock a bike at stations around the city and use the bike for a specified amount of time. The bikes can be returned to the same station or to another station. The City of Chicago makes the anonymized bike trip data publicly available for projects like this where we can analyze the data.

Since the data from Divvy are anonymous, we have created fake rider and account profiles along with fake payment data to go along with the data from Divvy. The dataset looks like this:

## Divvy ERD
This image represents the data model for the dataset based on the Divvy Bikeshare data. The tables include: Rider, Account, Payment, Trip, and Station.
Relational ERD for the Divvy Bikeshare Dataset (with fake data tables)
![](../images/divvy-erd.png)

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

### Star Schema Design

| Criteria | Submission Requirements |
|---|---|
| The student will be able to generate fact tables based on a business need and a relational model | The dimensional model should have two fact tables sharing common dimensions where applicable. One should be related to trip facts and another should be related to payment facts. The trip fact should have fields for trip duration and rider age at time of trip. The payment fact should have a field related to amount of payment. |
| The student will be able to generate dimension tables based on business needs and a relational model | The star schema should have dimensions related to the trip fact table that are related to: riders, stations, and dates. The schema should have dimensions related to the payment fact table that are related to: dates and riders. |
| Extract Step | The screenshot will demonstrate the learner is able to extract data from PostgreSQL into Azure Blob Storage. The screenshot should be of the Azure Blob Storage and should contain 4 text files: public.payment, public.rider, public.trip, public.station. |
| Load Step | The student will be able to load data from Azure Blob Storage into external tables in the data warehouse. The student will have uploaded 4 separate script files. The SQL files should create tables using CREATE EXTERNAL TABLE (not just CREATE TABLE). The scripts should point to the four files in Blob Storage from the extract step. |
| Transform Step | The scripts show the student is able to generate fact tables (CETAS) from staging tables. The fact table (CETAS) scripts should contain appropriate keys from the dimensions and should appropriately generate the correct facts based on the diagrams provided in the first step. |
| Dimension Transform Requirements | The scripts show the student can generate dimension tables (CETAS) from staging tables. The dimension scripts (CETAS) should match the schema diagram. Dimensions should generate appropriate keys and should not contain facts. |
| Tips | Ensure the column names match the reference diagrams created in Step 1. For creating fact tables out of joins between dimensions and staging tables, consider using CETAS to materialize joined reference tables to a new file and then join to this single external table in subsequent queries. |

## Star schema Diagram
[Here](./diagrams/divvy_er.pdf) you can find the Star Schema for the Divvy Bikeshare Dataset project; generated using mermaid.js from the corresponding code in the file [divvy_er.mmd](./diagrams/divvy_er.mmd).
