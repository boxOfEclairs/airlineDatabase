CREATE TABLE STATES (
    StateID VARCHAR(2) PRIMARY KEY,
    Name VARCHAR(25) UNIQUE
);

CREATE TABLE SEATS(
SeatID VARCHAR2(3) PRIMARY KEY,
RowPosition Number(2,0),
ColumnPosition VARCHAR2(1)
);

CREATE TABLE CUSTOMERS(
    CustomerID Number PRIMARY KEY,
    FirstName VARCHAR2(50) NOT NULL,
    LastName VARCHAR2(50) NOT NULL,
    PhoneNumber Number(10,0) NOT NULL UNIQUE,
    Email VARCHAR2(50) NOT NULL UNIQUE,
    StreetAddress VARCHAR2(50),
    CityName VARCHAR2(50),
    StateID VARCHAR2(2),
    ZipCode Number(5,0),
    FOREIGN KEY (StateID) REFERENCES STATES(StateID)
);

CREATE TABLE AIRPORTS(
AirportID VARCHAR2(3) PRIMARY KEY,
CityName VARCHAR2(50),
StateID VARCHAR2(2),
FOREIGN KEY (StateID) REFERENCES STATES(StateID)
);

CREATE TABLE MANAGERS (
    ManagerID NUMBER PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    PhoneNumber NUMBER(10,0) NOT NULL UNIQUE,
    Email VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE SCHEDULES(
ScheduleID Number PRIMARY KEY,
Departure DATE,
Arrival DATE
);  

CREATE TABLE FLIGHTS (
  FlightID NUMBER PRIMARY KEY,
  ScheduleID NUMBER(10, 0) NOT NULL,
  OriginID VARCHAR2(3) NOT NULL,
  DestinationID VARCHAR2(3) NOT NULL,
  OriginGate VARCHAR2(5) NOT NULL,
  DestinationGate VARCHAR2(5),
  Miles NUMBER(5, 0),
  
  FOREIGN KEY (ScheduleID) REFERENCES SCHEDULES(ScheduleID),
  FOREIGN KEY (OriginID) REFERENCES AIRPORTS(AirportID),
  FOREIGN KEY (DestinationID) REFERENCES AIRPORTS(AirportID)
);

CREATE TABLE LOYALTY(
    LoyaltyID Number PRIMARY KEY,
    CustomerID Number(10,0) UNIQUE NOT NULL,
    Points Number(9,0) NOT NULL,

    FOREIGN KEY (CustomerID) REFERENCES CUSTOMERS(CustomerID)
);

CREATE TABLE DELAYS (
    DelayID NUMBER PRIMARY KEY,
    DelayedFlightID NUMBER(10,0) NOT NULL,
    DelayHours NUMBER(2,0) NOT NULL,
    DelayMinutes NUMBER(2,0) NOT NULL,
    DelayReason CLOB,
    
    FOREIGN KEY (DelayedFlightID) REFERENCES FLIGHTS(FlightID)
);

CREATE TABLE REFUNDS (
    RefundID NUMBER PRIMARY KEY,
    CustomerID NUMBER(10,0) NOT NULL,
    ManagerID NUMBER(10,0) NOT NULL,
    RefundType VARCHAR2(10) NOT NULL,
    RefundAmount NUMBER(5,2) NOT NULL,
    RefundDate DATE,

    FOREIGN KEY (CustomerID) REFERENCES CUSTOMERS(CustomerID),
    FOREIGN KEY (ManagerID) REFERENCES MANAGERS(ManagerID)
);

CREATE TABLE TICKETS (
    TicketID NUMBER PRIMARY KEY,
    HolderID NUMBER(10,0) NOT NULL,
    FlightID NUMBER(10,0) NOT NULL,
    SeatID VARCHAR2(3) NOT NULL,
    Cost NUMBER(5,2) NOT NULL,
    RefundID NUMBER(10,0),

    FOREIGN KEY (HolderID) REFERENCES CUSTOMERS(CustomerID),
    FOREIGN KEY (FlightID) REFERENCES FLIGHTS(FlightID),
    FOREIGN KEY (SeatID) REFERENCES SEATS(SeatID),
    FOREIGN KEY (RefundID) REFERENCES REFUNDS(RefundID)
);

CREATE TABLE LUGGAGE (
    LuggageID NUMBER PRIMARY KEY,
    OwnerID NUMBER(10,0) NOT NULL,
    FlightID NUMBER(10,0) NOT NULL,
    RefundID NUMBER(10,0),
    Cost NUMBER(4,2) NOT NULL,

    FOREIGN KEY (OwnerID) REFERENCES CUSTOMERS(CustomerID),
    FOREIGN KEY (FlightID) REFERENCES FLIGHTS(FlightID),
    FOREIGN KEY (RefundID) REFERENCES REFUNDS(RefundID)
);

COMMIT;