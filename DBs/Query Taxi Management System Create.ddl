CREATE TABLE Customer (
  Customer_ID  int(10) NOT NULL AUTO_INCREMENT, 
  First_name   varchar(255) NOT NULL, 
  Last_name    varchar(255) NOT NULL, 
  Address      varchar(255) NOT NULL, 
  Phone_number int(12) NOT NULL, 
  Joined_date  date NOT NULL, 
  CONSTRAINT Customer_ID 
    PRIMARY KEY (Customer_ID));
CREATE TABLE Driver (
  Driver_ID    int(10) NOT NULL AUTO_INCREMENT, 
  Driver_name  varchar(255) NOT NULL, 
  Address      varchar(255) NOT NULL, 
  Email        varchar(255) NOT NULL, 
  Phone_number int(12) NOT NULL, 
  Joined_date  date NOT NULL, 
  Rating       float NOT NULL, 
  CONSTRAINT Driver_ID 
    PRIMARY KEY (Driver_ID));
CREATE TABLE Location (
  Location_ID   int(10) NOT NULL AUTO_INCREMENT, 
  Latitude      decimal(8, 0) NOT NULL, 
  Longitude     decimal(9, 0) NOT NULL, 
  Landmark_city varchar(255), 
  Landmark_Name varchar(255), 
  CONSTRAINT Location_ID 
    PRIMARY KEY (Location_ID));
CREATE TABLE Trip (
  Vendor_ID             int(10) NOT NULL AUTO_INCREMENT, 
  Location_ID           int(10) NOT NULL, 
  Customer_ID           int(10) NOT NULL, 
  Driver_ID             int(10) NOT NULL, 
  Tpep_pickup_datetime  date NOT NULL, 
  Tpep_dropoff_datetime date NOT NULL, 
  Passenger_count       int(10), 
  Trip_distance         float NOT NULL, 
  Ratecode_ID           int(10) NOT NULL, 
  Store_and_fwd_flag    varchar(1) NOT NULL, 
  PULocationID          int(10) NOT NULL, 
  DOLocationID          int(10) NOT NULL, 
  Payment_type          int(10) NOT NULL, 
  Fare_amount           float NOT NULL, 
  Extra                 float NOT NULL, 
  MTA_tax               float NOT NULL, 
  Tip_amount            float, 
  Tolls_amount          float NOT NULL, 
  Improvement_surcharge float NOT NULL, 
  Total_amount          float NOT NULL, 
  Congestion_surcharge  float, 
  CONSTRAINT Vendor_ID 
    PRIMARY KEY (Vendor_ID));
ALTER TABLE Trip ADD CONSTRAINT FKTrip695312 FOREIGN KEY (Driver_ID) REFERENCES Driver (Driver_ID);
ALTER TABLE Trip ADD CONSTRAINT FKTrip47564 FOREIGN KEY (Customer_ID) REFERENCES Customer (Customer_ID);
ALTER TABLE Trip ADD CONSTRAINT FKTrip712101 FOREIGN KEY (Location_ID) REFERENCES Location (Location_ID);

