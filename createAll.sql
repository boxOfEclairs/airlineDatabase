CREATE SEQUENCE customerIDseq
   START WITH 1
   INCREMENT BY 1
   NOMAXVALUE;

CREATE SEQUENCE managerIDseq
   START WITH 1
   INCREMENT BY 1
   NOMAXVALUE;

CREATE SEQUENCE scheduleIDseq
   START WITH 1
   INCREMENT BY 1
   NOMAXVALUE;

CREATE SEQUENCE flightIDseq
   START WITH 1
   INCREMENT BY 1
   NOMAXVALUE;

CREATE SEQUENCE loyaltyIDseq
   START WITH 1
   INCREMENT BY 1
   NOMAXVALUE;

CREATE SEQUENCE delayIDseq
   START WITH 1
   INCREMENT BY 1
   NOMAXVALUE;

CREATE SEQUENCE refundIDseq
   START WITH 1
   INCREMENT BY 1
   NOMAXVALUE;

CREATE SEQUENCE ticketIDseq
   START WITH 1
   INCREMENT BY 1
   NOMAXVALUE;

CREATE SEQUENCE luggageIDseq
   START WITH 1
   INCREMENT BY 1
   NOMAXVALUE;

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

--basic triggers for sequences

CREATE OR REPLACE TRIGGER customerIDtrigger
   BEFORE INSERT ON CUSTOMERS
   FOR EACH ROW
BEGIN
   SELECT customerIDseq.NEXTVAL
   INTO :new.CustomerID
   FROM dual;
END;
/

CREATE OR REPLACE TRIGGER managerIDtrigger
   BEFORE INSERT ON MANAGERS
   FOR EACH ROW
BEGIN
   SELECT managerIDseq.NEXTVAL
   INTO :new.ManagerID
   FROM dual;
END;
/

CREATE OR REPLACE TRIGGER scheduleIDtrigger
   BEFORE INSERT ON SCHEDULES
   FOR EACH ROW
BEGIN
   SELECT scheduleIDseq.NEXTVAL
   INTO :new.ScheduleID
   FROM dual;
END;
/

CREATE OR REPLACE TRIGGER flightIDtrigger
   BEFORE INSERT ON FLIGHTS
   FOR EACH ROW
BEGIN
   SELECT flightIDseq.NEXTVAL
   INTO :new.FlightID
   FROM dual;
END;
/

CREATE OR REPLACE TRIGGER loyaltyIDtrigger
   BEFORE INSERT ON LOYALTY
   FOR EACH ROW
BEGIN
   SELECT loyaltyIDseq.NEXTVAL
   INTO :new.LoyaltyID
   FROM dual;
END;
/

CREATE OR REPLACE TRIGGER delayIDtrigger
   BEFORE INSERT ON DELAYS
   FOR EACH ROW
BEGIN
   SELECT delayIDseq.NEXTVAL
   INTO :new.DelayID
   FROM dual;
END;
/

CREATE OR REPLACE TRIGGER refundIDtrigger
   BEFORE INSERT ON REFUNDS
   FOR EACH ROW
BEGIN
   SELECT refundIDseq.NEXTVAL
   INTO :new.RefundID
   FROM dual;
END;
/

CREATE OR REPLACE TRIGGER ticketIDtrigger
   BEFORE INSERT ON TICKETS
   FOR EACH ROW
BEGIN
   SELECT ticketIDseq.NEXTVAL
   INTO :new.TicketID
   FROM dual;
END;
/

CREATE OR REPLACE TRIGGER luggageIDtrigger
   BEFORE INSERT ON LUGGAGE
   FOR EACH ROW
BEGIN
   SELECT luggageIDseq.NEXTVAL
   INTO :new.LuggageID
   FROM dual;
END;
/

--Add points to users loyalty account on addition of ticket with their info to tickets table
--Important to keep track of the loyalty accounts automatically
CREATE OR REPLACE TRIGGER addPointsTrigger
   AFTER INSERT ON TICKETS
   FOR EACH ROW
DECLARE
    localFlightID NUMBER;
    localCustomerID NUMBER;
    AddPoints NUMBER;
BEGIN
    --Get flightid of ticket
    localFlightID := :NEW.FlightID;
    --Get holderid of ticket
    localCustomerID := :NEW.HolderID;
    --Get miles from flightID
    SELECT Miles INTO AddPoints FROM FLIGHTS WHERE FlightID = localFlightID;
    --Add miles to loyalty points using matching customerID
    UPDATE LOYALTY SET POINTS = POINTS + AddPoints WHERE CUSTOMERID = localCustomerID;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Error editing loyalty points on ticket creation.');
END;
/

--Remove points from users loyalty account on deletion of ticket with their info from tickets table
--Important to keep track of the loyalty accounts automatically
CREATE OR REPLACE TRIGGER removePointsTrigger
   AFTER DELETE ON TICKETS
   FOR EACH ROW
DECLARE
    localFlightID NUMBER;
    localCustomerID NUMBER;
    removePoints NUMBER;
BEGIN
    --Get flightid of ticket
    localFlightID := :OLD.FlightID;
    --Get holderid of ticket
    localCustomerID := :OLD.HolderID;
    --Get miles from flightID
    SELECT Miles INTO removePoints FROM FLIGHTS WHERE FlightID = localFlightID;
    --Subtract miles from loyalty points using matching customerID
    UPDATE LOYALTY SET POINTS = POINTS - removePoints WHERE CUSTOMERID = localCustomerID;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Error editing loyalty points on ticket deletion.');
END;
/

INSERT ALL
INTO STATES(StateID, Name) VALUES ('AL', 'Alabama')
INTO STATES(StateID, Name) VALUES ('AK', 'Alaska')
INTO STATES(StateID, Name) VALUES ('AZ', 'Arizona')
INTO STATES(StateID, Name) VALUES ('AR', 'Arkansas')
INTO STATES(StateID, Name) VALUES ('CA', 'California')
INTO STATES(StateID, Name) VALUES ('CO', 'Colorado')
INTO STATES(StateID, Name) VALUES ('CT', 'Connecticut')
INTO STATES(StateID, Name) VALUES ('DE', 'Delaware')
INTO STATES(StateID, Name) VALUES ('DC', 'District of Columbia')
INTO STATES(StateID, Name) VALUES ('FL', 'Florida')
INTO STATES(StateID, Name) VALUES ('GA', 'Georgia')
INTO STATES(StateID, Name) VALUES ('HI', 'Hawaii')
INTO STATES(StateID, Name) VALUES ('ID', 'Idaho')
INTO STATES(StateID, Name) VALUES ('IL', 'Illinois')
INTO STATES(StateID, Name) VALUES ('IN', 'Indiana')
INTO STATES(StateID, Name) VALUES ('IA', 'Iowa')
INTO STATES(StateID, Name) VALUES ('KS', 'Kansas')
INTO STATES(StateID, Name) VALUES ('KY', 'Kentucky')
INTO STATES(StateID, Name) VALUES ('LA', 'Louisiana')
INTO STATES(StateID, Name) VALUES ('ME', 'Maine')
INTO STATES(StateID, Name) VALUES ('MT', 'Montana')
INTO STATES(StateID, Name) VALUES ('NE', 'Nebraska')
INTO STATES(StateID, Name) VALUES ('NV', 'Nevada')
INTO STATES(StateID, Name) VALUES ('NH', 'New Hampshire')
INTO STATES(StateID, Name) VALUES ('NJ', 'New Jersey')
INTO STATES(StateID, Name) VALUES ('NM', 'New Mexico')
INTO STATES(StateID, Name) VALUES ('NY', 'New York')
INTO STATES(StateID, Name) VALUES ('NC', 'North Carolina')
INTO STATES(StateID, Name) VALUES ('ND', 'North Dakota')
INTO STATES(StateID, Name) VALUES ('OH', 'Ohio')
INTO STATES(StateID, Name) VALUES ('OK', 'Oklahoma')
INTO STATES(StateID, Name) VALUES ('OR', 'Oregon')
INTO STATES(StateID, Name) VALUES ('MD', 'Maryland')
INTO STATES(StateID, Name) VALUES ('MA', 'Massachusetts')
INTO STATES(StateID, Name) VALUES ('MI', 'Michigan')
INTO STATES(StateID, Name) VALUES ('MN', 'Minnesota')
INTO STATES(StateID, Name) VALUES ('MS', 'Mississippi')
INTO STATES(StateID, Name) VALUES ('MO', 'Missouri')
INTO STATES(StateID, Name) VALUES ('PA', 'Pennsylvania')
INTO STATES(StateID, Name) VALUES ('RI', 'Rhode Island')
INTO STATES(StateID, Name) VALUES ('SC', 'South Carolina')
INTO STATES(StateID, Name) VALUES ('SD', 'South Dakota')
INTO STATES(StateID, Name) VALUES ('TN', 'Tennessee')
INTO STATES(StateID, Name) VALUES ('TX', 'Texas')
INTO STATES(StateID, Name) VALUES ('UT', 'Utah')
INTO STATES(StateID, Name) VALUES ('VT', 'Vermont')
INTO STATES(StateID, Name) VALUES ('VA', 'Virginia')
INTO STATES(StateID, Name) VALUES ('WA', 'Washington')
INTO STATES(StateID, Name) VALUES ('WV', 'West Virginia')
INTO STATES(StateID, Name) VALUES ('WI', 'Wisconsin')
INTO STATES(StateID, Name) VALUES ('WY', 'Wyoming')
SELECT 1 FROM dual;

--96 Seats: 19 rows of 6 seats--
INSERT ALL
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('1A', 1, 'A')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('1B', 1, 'B')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('1C', 1, 'C')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('1D', 1, 'D')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('1E', 1, 'E')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('1F', 1, 'F')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('2A', 2, 'A')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('2B', 2, 'B')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('2C', 2, 'C')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('2D', 2, 'D')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('2E', 2, 'E')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('2F', 2, 'F')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('3A', 3, 'A')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('3B', 3, 'B')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('3C', 3, 'C')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('3D', 3, 'D')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('3E', 3, 'E')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('3F', 3, 'F')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('4A', 4, 'A')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('4B', 4, 'B')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('4C', 4, 'C')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('4D', 4, 'D')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('4E', 4, 'E')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('4F', 4, 'F')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('5A', 5, 'A')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('5B', 5, 'B')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('5C', 5, 'C')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('5D', 5, 'D')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('5E', 5, 'E')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('5F', 5, 'F')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('6A', 6, 'A')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('6B', 6, 'B')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('6C', 6, 'C')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('6D', 6, 'D')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('6E', 6, 'E')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('6F', 6, 'F')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('7A', 7, 'A')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('7B', 7, 'B')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('7C', 7, 'C')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('7D', 7, 'D')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('7E', 7, 'E')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('7F', 7, 'F')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('8A', 8, 'A')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('8B', 8, 'B')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('8C', 8, 'C')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('8D', 8, 'D')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('8E', 8, 'E')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('8F', 8, 'F')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('9A', 9, 'A')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('9B', 9, 'B')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('9C', 9, 'C')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('9D', 9, 'D')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('9E', 9, 'E')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('9F', 9, 'F')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('10A', 10, 'A')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('10B', 10, 'B')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('10C', 10, 'C')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('10D', 10, 'D')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('10E', 10, 'E')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('10F', 10, 'F')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('11A', 11, 'A')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('11B', 11, 'B')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('11C', 11, 'C')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('11D', 11, 'D')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('11E', 11, 'E')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('11F', 11, 'F')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('12A', 12, 'A')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('12B', 12, 'B')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('12C', 12, 'C')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('12D', 12, 'D')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('12E', 12, 'E')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('12F', 12, 'F')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('13A', 13, 'A')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('13B', 13, 'B')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('13C', 13, 'C')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('13D', 13, 'D')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('13E', 13, 'E')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('13F', 13, 'F')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('14A', 14, 'A')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('14B', 14, 'B')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('14C', 14, 'C')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('14D', 14, 'D')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('14E', 14, 'E')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('14F', 14, 'F')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('15A', 15, 'A')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('15B', 15, 'B')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('15C', 15, 'C')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('15D', 15, 'D')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('15E', 15, 'E')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('15F', 15, 'F')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('16A', 16, 'A')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('16B', 16, 'B')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('16C', 16, 'C')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('16D', 16, 'D')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('16E', 16, 'E')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('16F', 16, 'F')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('17A', 17, 'A')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('17B', 17, 'B')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('17C', 17, 'C')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('17D', 17, 'D')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('17E', 17, 'E')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('17F', 17, 'F')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('18A', 18, 'A')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('18B', 18, 'B')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('18C', 18, 'C')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('18D', 18, 'D')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('18E', 18, 'E')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('18F', 18, 'F')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('19A', 19, 'A')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('19B', 19, 'B')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('19C', 19, 'C')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('19D', 19, 'D')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('19E', 19, 'E')
INTO SEATS(SeatID, RowPosition, ColumnPosition) VALUES ('19F', 19, 'F')
SELECT 1 FROM dual;

INSERT ALL
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL,'Jose', 'Jackson', 3093033305, 'JoseJackson@dayrep.com', '2240 Apple Lane', 'Peoria', 'IL', 61602)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL,'Amanda', 'Dawson', 6033677164, 'AmandaDawson@rhyta.com', '1492 Grasselli Street', 'Madison', 'NH', 03849)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL,'John', 'Smith', 5551234567, 'JohnSmith@example.com', '456 Oak Street', 'Springfield', 'OH', 43001)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL,'Emily', 'Johnson', 4087654321, 'EmilyJohnson@example.com', '789 Pine Avenue', 'Riverside', 'CA', 92501)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL,'Daniel', 'Miller', 2125556789, 'DanielMiller@example.com', '567 Maple Drive', 'Baltimore', 'MD', 21201)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL,'Sophia', 'Wilson', 4155554321, 'SophiaWilson@example.com', '890 Cedar Court', 'San Francisco', 'CA', 94105)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL,'Elijah', 'Anderson', 7135559876, 'ElijahAnderson@example.com', '123 Elm Street', 'Houston', 'TX', 77002)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL,'Olivia', 'Thompson', 2815551234, 'OliviaThompson@example.com', '456 Birch Lane', 'Houston', 'TX', 77003)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL,'Liam', 'Hernandez', 6342085691, 'LiamHernandez@example.com', '789 Oak Avenue', 'Dallas', 'TX', 75201)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Emma', 'Garcia', 9725553456, 'EmmaGarcia@example.com', '101 Pine Road', 'Dallas', 'TX', 75202)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Mia', 'Davis', 4085557890, 'MiaDavis@example.com', '202 Cedar Avenue', 'San Jose', 'CA', 95101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Ethan', 'Moore', 2815552345, 'EthanMoore@example.com', '303 Maple Street', 'Houston', 'TX', 77001)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Isabella', 'Miller', 4909171409, 'IsabellaMiller@example.com', '404 Walnut Lane', 'Dallas', 'TX', 75203)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Aiden', 'Johnson', 3452777499, 'AidenJohnson@example.com', '505 Pine Road', 'San Jose', 'CA', 95102)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Ava', 'Hernandez', 7934278209, 'AvaHernandez@example.com', '606 Birch Avenue', 'Dallas', 'TX', 75204)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Mason', 'Brown', 6305558765, 'MasonBrown@example.com', '707 Oak Lane', 'Chicago', 'IL', 60601)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Amelia', 'Clark', 3125552345, 'AmeliaClark@example.com', '808 Pine Street', 'New York', 'NY', 10001)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Logan', 'Hill', 7735557890, 'LoganHill@example.com', '909 Elm Road', 'Los Angeles', 'CA', 90001)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Ella', 'Baker', 8475553456, 'EllaBaker@example.com', '1010 Maple Avenue', 'Houston', 'TX', 77001)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Carter', 'Turner', 7085554321, 'CarterTurner@example.com', '1111 Cedar Drive', 'Chicago', 'IL', 60602)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Grace', 'Ward', 2245559876, 'GraceWard@example.com', '1212 Birch Street', 'San Francisco', 'CA', 94105)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Sebastian', 'Evans', 8475558765, 'SebastianEvans@example.com', '1313 Walnut Lane', 'Miami', 'FL', 33101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Lily', 'Cooper', 8231675086, 'LilyCooper@example.com', '1414 Grasselli Road', 'Atlanta', 'GA', 30301)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Grayson', 'Reed', 9215825227, 'GraysonReed@example.com', '1515 Pine Drive', 'Dallas', 'TX', 75201)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Zoe', 'Fisher', 3125553456, 'ZoeFisher@example.com', '1616 Elm Avenue', 'Boston', 'MA', 02101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Nolan', 'Cruz', 8475554321, 'NolanCruz@example.com', '1717 Oak Road', 'Denver', 'CO', 80202)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Avery', 'Bryant', 7085558765, 'AveryBryant@example.com', '1818 Cedar Lane', 'Seattle', 'WA', 98101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Scarlett', 'Perez', 2245557890, 'ScarlettPerez@example.com', '1919 Maple Street', 'Phoenix', 'AZ', 85001)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Levi', 'Stewart', 6305552345, 'LeviStewart@example.com', '2020 Birch Drive', 'New Orleans', 'LA', 70112)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Hazel', 'Russell', 7735559876, 'HazelRussell@example.com', '2121 Walnut Road', 'Chicago', 'IL', 60603)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Gabriel', 'Watson', 6645996091, 'GabrielWatson@example.com', '2222 Pine Avenue', 'Austin', 'TX', 73301)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Penelope', 'Ford', 7085553456, 'PenelopeFord@example.com', '2323 Elm Street', 'Philadelphia', 'PA', 19101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Jackson', 'Reyes', 2972714738, 'JacksonReyes@example.com', '2424 Oak Lane', 'Detroit', 'MI', 48201)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Violet', 'Dunn', 2245552345, 'VioletDunn@example.com', '2525 Cedar Drive', 'Las Vegas', 'NV', 89101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Luke', 'Gordon', 6305557890, 'LukeGordon@example.com', '2626 Birch Road', 'Minneapolis', 'MN', 55401)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Aria', 'Fleming', 9099975253, 'AriaFleming@example.com', '2727 Pine Avenue', 'Orlando', 'FL', 32801)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Wyatt', 'Fisher', 7085559876, 'WyattFisher@example.com', '2828 Elm Road', 'Portland', 'OR', 97201)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Evelyn', 'Barnes', 993749332, 'EvelynBarnes@example.com', '2929 Maple Lane', 'Chicago', 'IL', 60604)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Landon', 'Sullivan', 6305553456, 'LandonSullivan@example.com', '3030 Cedar Drive', 'San Diego', 'CA', 92101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Aubrey', 'Matthews', 2488382009, 'AubreyMatthews@example.com', '3131 Walnut Lane', 'Tampa', 'FL', 33601)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Aaron', 'Gibson', 2245558765, 'AaronGibson@example.com', '3232 Pine Street', 'Raleigh', 'NC', 27601)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Sadie', 'Wells', 9186438432, 'SadieWells@example.com', '3333 Elm Avenue', 'St. Louis', 'MO', 63101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Owen', 'Diaz', 6145251545, 'OwenDiaz@example.com', '3434 Oak Road', 'Cleveland', 'OH', 44101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Audrey', 'Hayes', 6305554321, 'AudreyHayes@example.com', '3535 Cedar Drive', 'Kansas CityName', 'MO', 64101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Christian', 'Myers', 7735552345, 'ChristianMyers@example.com', '3636 Pine Drive', 'Indianapolis', 'IN', 46201)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Samantha', 'Ford', 3048891109, 'SamanthaFord@example.com', '3737 Elm Street', 'Charlotte', 'NC', 28201)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Connor', 'Ward', 9108203920, 'ConnorWard@example.com', '3838 Maple Lane', 'Milwaukee', 'WI', 53201)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Bella', 'Fisher', 9755295808, 'BellaFisher@example.com', '3939 Walnut Road', 'Memphis', 'TN', 38101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Eli', 'Reyes', 7735554321, 'EliReyes@example.com', '4040 Pine Avenue', 'Salt Lake CityName', 'UT', 84101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Mila', 'Dunn', 9691652159, 'MilaDunn@example.com', '4141 Oak Lane', 'Baltimore', 'MD', 21201)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Brayden', 'Gordon', 8475552345, 'BraydenGordon@example.com', '4242 Cedar Drive', 'Louisville', 'KY', 40201)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Nova', 'Matthews', 7085557890, 'NovaMatthews@example.com', '4343 Elm Avenue', 'Nashville', 'TN', 37201)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Parker', 'Barnes', 7912819324, 'ParkerBarnes@example.com', '4444 Maple Lane', 'Oklahoma CityName', 'OK', 73101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Aaliyah', 'Sullivan', 2791653672, 'AaliyahSullivan@example.com', '4545 Walnut Road', 'Albuquerque', 'NM', 87101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Ezra', 'Gibson', 8475557890, 'EzraGibson@example.com', '4646 Pine Street', 'Tucson', 'AZ', 85701)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Addison', 'Wells', 7085552345, 'AddisonWells@example.com', '4747 Oak Road', 'Honolulu', 'HI', 96801)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Elena', 'Diaz', 3125557890, 'ElenaDiaz@example.com', '4848 Cedar Lane', 'Anchorage', 'AK', 99501)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Colton', 'Hayes', 6066798781, 'ColtonHayes@example.com', '4949 Elm Street', 'Fargo', 'ND', 58102)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Luna', 'Myers', 5269842616, 'LunaMyers@example.com', '5050 Maple Lane', 'Bismarck', 'ND', 58501)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Mateo', 'Ford', 2997295170, 'MateoFord@example.com', '5151 Pine Drive', 'Sioux Falls', 'SD', 57101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Isaac', 'Ward', 6829242850, 'IsaacWard@example.com', '5252 Birch Street', 'Billings', 'MT', 59101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Everly', 'Fisher', 3125558765, 'EverlyFisher@example.com', '5353 Walnut Lane', 'Cheyenne', 'WY', 82001)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Santiago', 'Barnes', 2717457804, 'SantiagoBarnes@example.com', '5454 Cedar Drive', 'Boise', 'ID', 83701)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Eleanor', 'Sullivan', 9899504727, 'EleanorSullivan@example.com', '5555 Oak Road', 'Juneau', 'AK', 99801)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Lucas', 'Matthews', 6195313158, 'LucasMatthews@example.com', '5656 Pine Avenue', 'Helena', 'MT', 59601)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Stella', 'Gibson', 1986259159, 'StellaGibson@example.com', '5757 Elm Lane', 'Dover', 'DE', 19901)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Zachary', 'Wells', 8926260660, 'ZacharyWells@example.com', '5858 Maple Road', 'Hartford', 'CT', 06101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Maya', 'Diaz', 2904746743, 'MayaDiaz@example.com', '5959 Pine Street', 'Dover', 'DE', 19902)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Axel', 'Hayes', 6709989721, 'AxelHayes@example.com', '6060 Oak Drive', 'Hartford', 'CT', 06102)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Aiden', 'Myers', 4812019330, 'AidenMyers@example.com', '6161 Cedar Lane', 'Providence', 'RI', 02901)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Avery', 'Fletcher', 2055551234, 'AveryFletcher@example.com', '7878 Oak Drive', 'Mobile', 'AL', 36601)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Peyton', 'Harrison', 5045552345, 'PeytonHarrison@example.com', '7979 Pine Avenue', 'New Orleans', 'LA', 70113)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Lydia', 'Hudson', 2765848260, 'LydiaHudson@example.com', '8080 Cedar Lane', 'Houston', 'TX', 77004)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Owen', 'Gill', 8325554567, 'OwenGill@example.com', '8181 Elm Street', 'Denver', 'CO', 80202)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Eva', 'Horton', 2815555678, 'EvaHorton@example.com', '8282 Maple Avenue', 'Seattle', 'WA', 98101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Landon', 'Beck', 5125556789, 'LandonBeck@example.com', '8383 Walnut Road', 'Chicago', 'IL', 60605)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Brooklyn', 'Hale', 2145557890, 'BrooklynHale@example.com', '8484 Pine Drive', 'Phoenix', 'AZ', 85001)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Parker', 'Keller', 8175558901, 'ParkerKeller@example.com', '8585 Elm Drive', 'Nashville', 'TN', 37201)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Aria', 'Barnett', 6825559012, 'AriaBarnett@example.com', '8686 Oak Lane', 'Miami', 'FL', 33101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Catherine', 'Minteer', 7735550123, 'CatherineMinteer@example.com', '8787 Cedar Road', 'Atlanta', 'GA', 30301)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Avery', 'Bishop', 2055552345, 'AveryBishop@example.com', '8888 Pine Avenue', 'Mobile', 'AL', 35201)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Harper', 'Daniels', 6333739145, 'HarperDaniels@example.com', '8989 Cedar Lane', 'Juneau', 'AK', 99501)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Leo', 'Floyd', 6515554567, 'LeoFloyd@example.com', '9090 Elm Drive', 'Phoenix', 'AZ', 85001)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Zoey', 'Hamilton', 5155555678, 'ZoeyHamilton@example.com', '9191 Oak Road', 'Little Rock', 'AR', 72201)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Elijah', 'Ingram', 8165556789, 'ElijahIngram@example.com', '9292 Maple Street', 'Los Angeles', 'CA', 90001)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Ivy', 'Johnston', 9135557890, 'IvyJohnston@example.com', '9393 Walnut Avenue', 'Denver', 'CO', 80202)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Josiah', 'Kramer', 4025558901, 'JosiahKramer@example.com', '9494 Cedar Drive', 'Hartford', 'CT', 06101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Aubrey', 'Lopez', 5315559012, 'AubreyLopez@example.com', '9595 Pine Lane', 'Dover', 'DE', 19901)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Lucy', 'Mann', 6055550123, 'LucyMann@example.com', '9696 Elm Road', 'Miami', 'FL', 33101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Easton', 'Owens', 7015551234, 'EastonOwens@example.com', '9797 Oak Lane', 'Atlanta', 'GA', 30301)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Nora', 'Parsons', 7015552345, 'NoraParsons@example.com', '9898 Cedar Lane', 'Honolulu', 'HI', 96801)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Liam', 'Ray', 8085553456, 'LiamRay@example.com', '9999 Maple Avenue', 'Boise', 'ID', 83701)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL, 'Zara', 'Saunders', 5549950233, 'ZaraSaunders@example.com', '10101 Pine Avenue', 'Chicago', 'IL', 60601)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL,  'Jaxon', 'Taylor', 3793664088, 'JaxonTaylor@example.com', '11111 Elm Drive', 'Indianapolis', 'IN', 46201)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL,  'Kylie', 'Underwood', 5777275975, 'KylieUnderwood@example.com', '12121 Walnut Road', 'Des Moines', 'IA', 50301)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL,  'Maddox', 'Vaughn', 796193195, 'MaddoxVaughn@example.com', '13131 Cedar Drive', 'Wichita', 'KS', 66101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL,  'Olivia', 'Wagner', 9135558901, 'OliviaWagner@example.com', '14141 Pine Lane', 'Louisville', 'KY', 40201)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL,  'Xander', 'Xiong', 5025559012, 'XanderXiong@example.com', '15151 Elm Road', 'Baton Rouge', 'LA', 70112)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL,  'Yara', 'Young', 5045550123, 'YaraYoung@example.com', '16161 Oak Avenue', 'Portland', 'ME', 04101)
INTO CUSTOMERS(CustomerID, FirstName, LastName, PhoneNumber, Email, StreetAddress, CityName, StateID, ZipCode) VALUES (customerIDseq.NEXTVAL,  'Zachariah', 'Zane', 2075551234, 'ZachariahZane@example.com', '17171 Maple Street', 'Baltimore', 'MD', 21201)
SELECT 1 FROM DUAL;

INSERT ALL
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('JFK', 'New York', 'NY')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('LAX', 'Los Angeles', 'CA')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('ORD', 'Chicago', 'IL')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('MIA', 'Miami', 'FL')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('SFO', 'San Francisco', 'CA')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('IAD', 'Washington D.C.', 'DC')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('ATL', 'Atlanta', 'GA')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('EWR', 'Newark', 'NJ')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('MCO', 'Orlando', 'FL')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('BOS', 'Boston', 'MA')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('LAS', 'Las Vegas', 'NV')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('DFW', 'Dallas', 'TX')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('MSY', 'New Orleans', 'LA')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('SEA', 'Seattle', 'WA')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('IAH', 'Houston', 'TX')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('SAN', 'San Diego', 'CA')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('HNL', 'Honolulu', 'HI')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('FLL', 'Ft. Lauderdale', 'FL')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('DEN', 'Denver', 'CO')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('PHX', 'Phoenix', 'AZ')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('DTW', 'Detroit', 'MI')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('PHL', 'Philadelphia', 'PA')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('TPA', 'Tampa', 'FL')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('AUS', 'Austin', 'TX')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('RDU', 'Raleigh', 'NC')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('RSW', 'Ft. Myers', 'FL')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('CLT', 'Charlotte', 'NC')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('MSP', 'Minneapolis', 'MN')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('BWI', 'Baltimore', 'MD')
  INTO AIRPORTS(AirportID, CityName, StateID) VALUES ('DCA', 'Washington D.C.', 'DC')
SELECT * FROM DUAL;

INSERT ALL
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'John', 'Doe', '1234567890', 'john.doe@email.com')
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'Jane', 'Smith', '9876543210', 'jane.smith@email.com')
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'Michael', 'Johnson', '5551234567', 'michael.j@email.com')
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'Emily', 'Davis', '9871234567', 'emily.d@email.com')
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'Christopher', 'Brown', '1239876543', 'chris.b@email.com')
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'Amanda', 'Taylor', '5559876543', 'amanda.t@email.com')
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'Robert', 'Martinez', '9875554321', 'robert.m@email.com')
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'Olivia', 'Garcia', '1235554321', 'olivia.g@email.com')
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'William', 'Rodriguez', '5557890123', 'william.r@email.com')
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'Sophia', 'Lee', '9877890123', 'sophia.l@email.com')
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'Daniel', 'Hernandez', '1232556789', 'daniel.h@email.com')
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'Ella', 'Gonzalez', '5555556789', 'ella.g@email.com')
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'Alexander', 'Wang', '9875557890', 'alexander.w@email.com')
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'Mia', 'Lopez', '1239877890', 'mia.l@email.com')
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'James', 'Kim', '5551237890', 'james.k@email.com')
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'Grace', 'Chen', '9871237890', 'grace.c@email.com')
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'Benjamin', 'Nguyen', '1235557890', 'benjamin.n@email.com')
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'Chloe', 'Smith', '5559877890', 'chloe.s@email.com')
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'Logan', 'Johnson', '9871236789', 'logan.j@email.com')
INTO MANAGERS(ManagerID, FirstName, LastName, PhoneNumber, Email) VALUES (managerIDseq.NEXTVAL, 'Ava', 'Anderson', '1235556789', 'ava.a@email.com')
SELECT * FROM DUAL;

INSERT ALL

--Chicago to NYC
INTO SCHEDULES(ScheduleID, Departure, Arrival) VALUES(scheduleIDseq.NEXTVAL,TO_DATE('2024-05-01 10:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-05-01 12:15', 'YYYY-MM-DD HH24:MI'))
INTO SCHEDULES(ScheduleID, Departure, Arrival) VALUES(scheduleIDseq.NEXTVAL,TO_DATE('2024-05-01 16:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-05-01 18:15', 'YYYY-MM-DD HH24:MI'))

--NYC to Chicago
INTO SCHEDULES(ScheduleID, Departure, Arrival) VALUES(scheduleIDseq.NEXTVAL,TO_DATE('2024-05-01 15:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-05-01 17:15', 'YYYY-MM-DD HH24:MI'))

--Boston to Newark
INTO SCHEDULES(ScheduleID, Departure, Arrival) VALUES(scheduleIDseq.NEXTVAL,TO_DATE('2024-05-01 10:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-05-01 15:15', 'YYYY-MM-DD HH24:MI'))

--NYC to Boston
INTO SCHEDULES(ScheduleID, Departure, Arrival) VALUES(scheduleIDseq.NEXTVAL,TO_DATE('2024-05-01 10:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-05-01 15:15', 'YYYY-MM-DD HH24:MI'))

--Los Angeles to NYC
INTO SCHEDULES(ScheduleID, Departure, Arrival) VALUES(scheduleIDseq.NEXTVAL,TO_DATE('2024-05-01 12:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-05-01 17:15', 'YYYY-MM-DD HH24:MI'))

--NYC to Los Angeles
INTO SCHEDULES(ScheduleID, Departure, Arrival) VALUES(scheduleIDseq.NEXTVAL,TO_DATE('2024-05-01 14:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-05-01 19:15', 'YYYY-MM-DD HH24:MI'))

--Chicago to Los Angeles
INTO SCHEDULES(ScheduleID, Departure, Arrival) VALUES(scheduleIDseq.NEXTVAL,TO_DATE('2024-05-01 9:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-05-01 13:45', 'YYYY-MM-DD HH24:MI'))

--Los Angeles to Chicago
INTO SCHEDULES(ScheduleID, Departure, Arrival) VALUES(scheduleIDseq.NEXTVAL,TO_DATE('2024-05-01 11:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-05-01 15:45', 'YYYY-MM-DD HH24:MI'))

--Los Angeles to Las Vegas
INTO SCHEDULES(ScheduleID, Departure, Arrival) VALUES(scheduleIDseq.NEXTVAL,TO_DATE('2024-05-01 8:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-05-01 09:10', 'YYYY-MM-DD HH24:MI'))

--Las Vegas to Los Angeles
INTO SCHEDULES(ScheduleID, Departure, Arrival) VALUES(scheduleIDseq.NEXTVAL,TO_DATE('2024-05-01 9:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-05-01 10:10', 'YYYY-MM-DD HH24:MI'))

--Atlanta to Chicago
INTO SCHEDULES(ScheduleID, Departure, Arrival) VALUES(scheduleIDseq.NEXTVAL,TO_DATE('2024-05-01 15:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-05-01 17:10', 'YYYY-MM-DD HH24:MI'))

--Seattle to Chicago
INTO SCHEDULES(ScheduleID, Departure, Arrival) VALUES(scheduleIDseq.NEXTVAL,TO_DATE('2024-05-01 16:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-05-01 20:00', 'YYYY-MM-DD HH24:MI'))

--Chicago to Seattle
INTO SCHEDULES(ScheduleID, Departure, Arrival) VALUES(scheduleIDseq.NEXTVAL,TO_DATE('2024-05-01 20:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-05-02 00:00', 'YYYY-MM-DD HH24:MI'))

--Chicago to Denver
INTO SCHEDULES(ScheduleID, Departure, Arrival) VALUES(scheduleIDseq.NEXTVAL,TO_DATE('2024-05-01 16:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-05-01 18:30', 'YYYY-MM-DD HH24:MI'))

SELECT * FROM DUAL;

INSERT ALL 
--Chicago to NYC
INTO FLIGHTS(FlightID,ScheduleID,OriginID,DestinationID,OriginGate,DestinationGate,Miles)
VALUES(flightIDseq.NEXTVAL,2,'ORD','JFK','A22','B16', 740)
INTO FLIGHTS(FlightID,ScheduleID,OriginID,DestinationID,OriginGate,DestinationGate,Miles)
VALUES(flightIDseq.NEXTVAL,3,'ORD','JFK', 'A23', 'C5', 740)
--NYC to Chicago
INTO FLIGHTS(FlightID,ScheduleID,OriginID,DestinationID,OriginGate,DestinationGate,Miles)
VALUES(flightIDseq.NEXTVAL,4,'JFK','ORD', 'B2', 'A22', 740)
--Boston to Newark
INTO FLIGHTS(FlightID,ScheduleID,OriginID,DestinationID,OriginGate,DestinationGate,Miles)
VALUES(flightIDseq.NEXTVAL,5,'BOS','EWR', 'A13', 'B16', 200)
--NYC to Boston
INTO FLIGHTS(FlightID,ScheduleID,OriginID,DestinationID,OriginGate,DestinationGate,Miles)
VALUES(flightIDseq.NEXTVAL,6,'JFK','BOS', 'A12', 'A9', 200)

-----------

--Los Angeles to NYC
INTO FLIGHTS(FlightID,ScheduleID,OriginID,DestinationID,OriginGate,DestinationGate,Miles)
VALUES(flightIDseq.NEXTVAL,7,'LAX','JFK', 'A16', 'D1', 2470)

--NYC to Los Angeles
INTO FLIGHTS(FlightID,ScheduleID,OriginID,DestinationID,OriginGate,DestinationGate,Miles)
VALUES(flightIDseq.NEXTVAL,8,'JFK','LAX', 'A1', 'B6', 2470)

--Chicago to Los Angeles
INTO FLIGHTS(FlightID,ScheduleID,OriginID,DestinationID,OriginGate,DestinationGate,Miles)
VALUES(flightIDseq.NEXTVAL,9,'ORD','LAX', 'C3', 'A13', 1740)

--Los Angeles to Chicago
INTO FLIGHTS(FlightID,ScheduleID,OriginID,DestinationID,OriginGate,DestinationGate,Miles)
VALUES(flightIDseq.NEXTVAL,10,'LAX','ORD', 'C18', 'B9', 1740)

--Los Angeles to Las Vegas
INTO FLIGHTS(FlightID,ScheduleID,OriginID,DestinationID,OriginGate,DestinationGate,Miles)
VALUES(flightIDseq.NEXTVAL,11,'LAX','LAS', 'B9', 'A22', 236)

--Las Vegas to Los Angeles
INTO FLIGHTS(FlightID,ScheduleID,OriginID,DestinationID,OriginGate,DestinationGate,Miles)
VALUES(flightIDseq.NEXTVAL,12,'LAS','LAX', 'A16', 'C5', 236)

--Atlanta to Chicago
INTO FLIGHTS(FlightID,ScheduleID,OriginID,DestinationID,OriginGate,DestinationGate,Miles)
VALUES(flightIDseq.NEXTVAL,13,'ATL','ORD', 'B21', 'C19', 606)

--Seattle to Chicago
INTO FLIGHTS(FlightID,ScheduleID,OriginID,DestinationID,OriginGate,DestinationGate,Miles)
VALUES(flightIDseq.NEXTVAL,14,'SEA','ORD', 'A19', 'B15', 1716)

--Chicago to Seattle
INTO FLIGHTS(FlightID,ScheduleID,OriginID,DestinationID,OriginGate,DestinationGate,Miles)
VALUES(flightIDseq.NEXTVAL,15,'ORD','SEA', 'A4', 'B7', 1716)

--Chicago to Denver
INTO FLIGHTS(FlightID,ScheduleID,OriginID,DestinationID,OriginGate,DestinationGate,Miles)
VALUES(flightIDseq.NEXTVAL,16,'ORD','DEN', 'C5', 'B12', 887)

SELECT * FROM DUAL;

INSERT ALL 
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 80, 400)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 47, 2520)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 64, 2600)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 19, 1880)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 82, 3540)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 9, 4000)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 50, 3320)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 94, 3760)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 35, 4720)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 26, 4400)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 71, 4280)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 95, 4920)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 76, 2520)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 14, 4760)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 44, 1360)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 8, 2880)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 21, 2880)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 83, 4720)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 41, 1680)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 89, 4440)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 68, 2520)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 92, 3200)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 30, 2000)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 74, 3240)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 13, 4760)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 66, 1680)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 56, 4680)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 23, 2080)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 40, 3760)
INTO LOYALTY (LoyaltyID, CustomerID, Points) VALUES (loyaltyIDseq.NEXTVAL, 87, 4240)

SELECT * FROM DUAL;

INSERT ALL
INTO DELAYS(DelayID, DelayedFlightID, DelayHours, DelayMinutes, DelayReason) Values(delayIDseq.NEXTVAL, 5, 2, 20, 'Electrical Failure in Newark Airport.')
INTO DELAYS(DelayID, DelayedFlightID, DelayHours, DelayMinutes, DelayReason) Values(delayIDseq.NEXTVAL, 3, 0, 20, 'Rainy Conditions')
SELECT * FROM DUAL;

INSERT ALL
INTO REFUNDS(RefundID, CustomerID, ManagerID, RefundType, RefundAmount, RefundDate) VALUES (refundIDseq.NEXTVAL, 16, 18, 'PARTIAL', 15, TO_DATE('2024-05-01 11:47', 'YYYY-MM-DD HH24:MI'))
INTO REFUNDS(RefundID, CustomerID, ManagerID, RefundType, RefundAmount, RefundDate) VALUES (refundIDseq.NEXTVAL, 19, 8, 'PARTIAL', 15, TO_DATE('2024-05-01 10:52', 'YYYY-MM-DD HH24:MI'))
INTO REFUNDS(RefundID, CustomerID, ManagerID, RefundType, RefundAmount, RefundDate) VALUES (refundIDseq.NEXTVAL, 25, 16, 'FULL', 20, TO_DATE('2024-05-01 9:26', 'YYYY-MM-DD HH24:MI'))
INTO REFUNDS(RefundID, CustomerID, ManagerID, RefundType, RefundAmount, RefundDate) VALUES (refundIDseq.NEXTVAL, 25, 16, 'FULL', 115, TO_DATE('2024-05-01 9:29', 'YYYY-MM-DD HH24:MI'))
INTO REFUNDS(RefundID, CustomerID, ManagerID, RefundType, RefundAmount, RefundDate) VALUES (refundIDseq.NEXTVAL, 31, 16, 'FULL', 20, TO_DATE('2024-05-01 9:35', 'YYYY-MM-DD HH24:MI'))
INTO REFUNDS(RefundID, CustomerID, ManagerID, RefundType, RefundAmount, RefundDate) VALUES (refundIDseq.NEXTVAL, 31, 16, 'FULL', 115, TO_DATE('2024-05-01 9:42', 'YYYY-MM-DD HH24:MI'))
INTO REFUNDS(RefundID, CustomerID, ManagerID, RefundType, RefundAmount, RefundDate) VALUES (refundIDseq.NEXTVAL, 37, 10, 'PARTIAL', 10, TO_DATE('2024-05-01 10:16', 'YYYY-MM-DD HH24:MI'))
INTO REFUNDS(RefundID, CustomerID, ManagerID, RefundType, RefundAmount, RefundDate) VALUES (refundIDseq.NEXTVAL, 40, 10, 'FULL', 20, TO_DATE('2024-05-01 10:21', 'YYYY-MM-DD HH24:MI'))
INTO REFUNDS(RefundID, CustomerID, ManagerID, RefundType, RefundAmount, RefundDate) VALUES (refundIDseq.NEXTVAL, 52, 4, 'PARTIAL', 15, TO_DATE('2024-05-01 14:47', 'YYYY-MM-DD HH24:MI'))
INTO REFUNDS(RefundID, CustomerID, ManagerID, RefundType, RefundAmount, RefundDate) VALUES (refundIDseq.NEXTVAL,  55, 4, 'PARTIAL', 15, TO_DATE('2024-04-30 14:35', 'YYYY-MM-DD HH24:MI'))
INTO REFUNDS(RefundID, CustomerID, ManagerID, RefundType, RefundAmount, RefundDate) VALUES (refundIDseq.NEXTVAL,  61, 8, 'PARTIAL', 15, TO_DATE('2024-05-01 9:31', 'YYYY-MM-DD HH24:MI'))
SELECT * FROM DUAL;

INSERT ALL
--Chicago to NYC
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 101, 2, '1A', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 2, 2, '2A', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 3, 2, '4A', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 4, 2, '4B', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 5, 2, '4C', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 6, 2, '10E', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 7, 2, '11C', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 8, 2, '11A', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 9, 2, '11F', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 10, 2, '14A', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 11, 2, '15F', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 12, 2, '16B', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 13, 2, '5E', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 14, 2, '5C', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 15, 2, '5A', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 16, 2, '6F', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 17, 2, '6A', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 18, 2, '7F', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 19, 2, '9B', 250)
--Chicago to NticketIDseq.NEXTVAL
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 40, 3, '16B', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 41, 3, '5E', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 42, 3, '5C', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 43, 3, '5A', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 44, 3, '6F', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 45, 3, '6A', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 46, 3, '7F', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 47, 3, '9B', 250)
--Boston to NewaticketIDseq.NEXTVAL
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 20, 5, '1A', 115)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 21, 5, '2A', 115)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 22, 5, '4A', 115)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 23, 5, '4B', 115)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost, RefundID) VALUES (ticketIDseq.NEXTVAL, 24, 5, '4C', 115, 4)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 25, 5, '10E', 115)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 26, 5, '11C', 115)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 27, 5, '11A', 115)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 28, 5, '11F', 115)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 29, 5, '14A', 115)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost, RefundID) VALUES (ticketIDseq.NEXTVAL, 30, 5, '15F', 115, 6)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 31, 5, '16B', 115)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 32, 5, '5E', 115)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 33, 5, '5C', 115)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 34, 5, '5A', 115)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 35, 5, '6F', 115)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 36, 5, '6A', 115)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 37, 5, '7F', 115)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 38, 5, '9B', 115)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 39, 5, '9A', 115)
--NYC to ChicaticketIDseq.NEXTVAL
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 48, 4, '16B', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 49, 4, '5E', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 50, 4, '5C', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 80, 4, '5A', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 51, 4, '6F', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 52, 4, '6A', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 53, 4, '7F', 250)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 54, 4, '9B', 250)
--NYC to BostticketIDseq.NEXTVAL
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 55, 6, '16B', 120)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 56, 6, '5E', 120)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 57, 6, '5C', 120)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 58, 6, '5A', 120)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 59, 6, '6F', 120)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 60, 6, '6A', 120)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 61, 6, '7F', 120)
INTO TICKETS(TicketID, HolderID, FlightID, SeatID, Cost) VALUES (ticketIDseq.NEXTVAL, 62, 6, '9B', 120)
SELECT * FROM DUAL;

INSERT ALL
--Chicago to NYC
INTO LUGGAGE(LuggageID, OwnerID, FlightID, Cost) Values(luggageIDseq.NEXTVAL, 3, 2, 45)
INTO LUGGAGE(LuggageID, OwnerID, FlightID, Cost) Values(luggageIDseq.NEXTVAL, 6, 2, 45)
INTO LUGGAGE(LuggageID, OwnerID, FlightID, Cost) Values(luggageIDseq.NEXTVAL, 9, 2, 45)
INTO LUGGAGE(LuggageID, OwnerID, FlightID, Cost) Values(luggageIDseq.NEXTVAL, 12, 2, 45)
INTO LUGGAGE(LuggageID, OwnerID, FlightID, RefundID, Cost) Values(luggageIDseq.NEXTVAL, 15, 2, 2, 45)
INTO LUGGAGE(LuggageID, OwnerID, FlightID, RefundID, Cost) Values(luggageIDseq.NEXTVAL, 18, 2, 3, 45)
--Boston to Newark
INTO LUGGAGE(LuggageID, OwnerID, FlightID, Cost) Values(luggageIDseq.NEXTVAL, 21, 5, 20)
INTO LUGGAGE(LuggageID, OwnerID, FlightID, RefundID, Cost) Values(luggageIDseq.NEXTVAL, 24, 5, 4, 20)
INTO LUGGAGE(LuggageID, OwnerID, FlightID, Cost) Values(luggageIDseq.NEXTVAL, 27, 5, 20)
INTO LUGGAGE(LuggageID, OwnerID, FlightID, RefundID, Cost) Values(luggageIDseq.NEXTVAL, 30, 5, 6, 20)
INTO LUGGAGE(LuggageID, OwnerID, FlightID, Cost) Values(luggageIDseq.NEXTVAL, 33, 5,  20)
INTO LUGGAGE(LuggageID, OwnerID, FlightID, RefundID, Cost) Values(luggageIDseq.NEXTVAL, 36, 5, 8, 20)
INTO LUGGAGE(LuggageID, OwnerID, FlightID, RefundID, Cost) Values(luggageIDseq.NEXTVAL, 39, 5, 9, 20)
--Chicago to NYC
INTO LUGGAGE(LuggageID, OwnerID, FlightID, Cost) Values(luggageIDseq.NEXTVAL, 42, 3, 30)
INTO LUGGAGE(LuggageID, OwnerID, FlightID, Cost) Values(luggageIDseq.NEXTVAL, 45, 3, 30)
--NYC to Chicago
INTO LUGGAGE(LuggageID, OwnerID, FlightID, Cost) Values(luggageIDseq.NEXTVAL, 48, 4, 50)
INTO LUGGAGE(LuggageID, OwnerID, FlightID, RefundID, Cost) Values(luggageIDseq.NEXTVAL, 51, 4, 10, 50)
INTO LUGGAGE(LuggageID, OwnerID, FlightID, RefundID, Cost) Values(luggageIDseq.NEXTVAL, 54, 4, 11, 50)
--New York to Boston
INTO LUGGAGE(LuggageID, OwnerID, FlightID, Cost) Values(luggageIDseq.NEXTVAL, 57, 6, 15)
INTO LUGGAGE(LuggageID, OwnerID, FlightID, RefundID, Cost) Values(luggageIDseq.NEXTVAL, 60, 6, 12, 15)
SELECT * FROM DUAL;

CREATE INDEX scheduleIndex ON SCHEDULES(Departure, Arrival);

CREATE INDEX flightIndex on FLIGHTS(ScheduleID, OriginID, DestinationID);

CREATE INDEX loyaltyIndex ON LOYALTY(CustomerID);

CREATE INDEX delayIndex ON DELAYS(DelayedFlightID);

CREATE INDEX refundIndex ON REFUNDS(CustomerID);

CREATE INDEX ticketIndex ON TICKETS(HolderID, FlightID, RefundID);

CREATE INDEX luggageIndex ON LUGGAGE(OwnerID, FlightID, RefundID);

CREATE VIEW DepartureBoard AS
SELECT
  OriginGate AS Gate,
  (SELECT CityName FROM AIRPORTS WHERE FLIGHTS.DestinationID = AIRPORTS.AirportID) AS Destination,
  TO_CHAR(
    (SELECT DEPARTURE FROM SCHEDULES WHERE FLIGHTS.ScheduleID = SCHEDULES.ScheduleID) 
    + COALESCE(NUMTODSINTERVAL((SELECT DELAYHOURS FROM DELAYS WHERE FLIGHTS.FlightID = DELAYS.DelayedFlightID), 'HOUR'), INTERVAL '0' HOUR)
    + COALESCE(NUMTODSINTERVAL((SELECT DELAYMINUTES FROM DELAYS WHERE FLIGHTS.FlightID = DELAYS.DelayedFlightID), 'MINUTE'), INTERVAL '0' MINUTE), 
    'HH:MI AM'
  ) AS "Departing At",
  TO_CHAR(
    (SELECT ARRIVAL FROM SCHEDULES WHERE FLIGHTS.ScheduleID = SCHEDULES.ScheduleID) 
    + COALESCE(NUMTODSINTERVAL((SELECT DELAYHOURS FROM DELAYS WHERE FLIGHTS.FlightID = DELAYS.DelayedFlightID), 'HOUR'), INTERVAL '0' HOUR)
    + COALESCE(NUMTODSINTERVAL((SELECT DELAYMINUTES FROM DELAYS WHERE FLIGHTS.FlightID = DELAYS.DelayedFlightID), 'MINUTE'), INTERVAL '0' MINUTE), 
    'HH:MI AM'
  ) AS "Arriving At",
  DECODE((SELECT DELAYEDFLIGHTID FROM DELAYS WHERE FLIGHTS.FlightID = DELAYS.DelayedFlightID), NULL, 'ON TIME', 'DELAYED') AS "STATUS"
FROM FLIGHTS
WHERE ORIGINID = 'ORD'
ORDER BY TO_DATE("Departing At", 'HH:MI AM') ASC;

CREATE VIEW SeatMap AS
SELECT *
FROM (SELECT CASE WHEN (SELECT SeatID FROM TICKETS WHERE TICKETS.SeatID = SEATS.SeatID AND TICKETS.FlightID = '2') IS NOT NULL THEN 'X' ELSE 'O' END AS SeatStatus,
    RowPosition,
    ColumnPosition
  FROM SEATS)
PIVOT (MAX(SeatStatus) FOR ColumnPosition IN ('A' AS A, 'B' AS B, 'C' AS C, 'D' AS D, 'E' AS E, 'F' AS F))
ORDER BY RowPosition;

CREATE VIEW LoyaltyProgram AS
SELECT 
    CONCAT(CONCAT(CUSTOMERS.FIRSTNAME,' '),CUSTOMERS.LASTNAME) AS "Name", 
    (COALESCE((SELECT SUM(TICKETS.COST) FROM TICKETS WHERE TICKETS.HolderID = CUSTOMERS.CustomerID), 0) + COALESCE((SELECT SUM(LUGGAGE.COST) FROM LUGGAGE WHERE LUGGAGE.OwnerID = CUSTOMERS.CustomerID), 0)) AS "TotalSpend",
    COALESCE((SELECT SUM(REFUNDS.REFUNDAMOUNT) FROM REFUNDS WHERE REFUNDS.CUSTOMERID = CUSTOMERS.CUSTOMERID), 0) AS "TOTALREFUND",
    LOYALTY.POINTS
FROM CUSTOMERS
INNER JOIN LOYALTY ON CUSTOMERS.CustomerID = LOYALTY.CustomerID;

CREATE VIEW Finances AS
SELECT 
    'TICKETS' AS "SALE_TYPE",
    SUM(TICKETS.COST) AS "SUM_SALES",
    FLOOR(AVG(TICKETS.COST)) AS "AVG_SALES",
    SUM(REFUNDS.REFUNDAMOUNT) AS "SUM_REFUND",
    FLOOR(AVG(REFUNDS.REFUNDAMOUNT)) AS "AVG_REFUND"
FROM 
    TICKETS
LEFT JOIN 
    REFUNDS ON REFUNDS.REFUNDID = TICKETS.REFUNDID
GROUP BY 'TICKETS'

UNION ALL

SELECT 
    'LUGGAGE' AS "SALE_TYPE",
    SUM(LUGGAGE.COST) AS "SUM_SALES",
    FLOOR(AVG(LUGGAGE.COST)) AS "AVG_SALES",
    SUM(REFUNDS.REFUNDAMOUNT) AS "SUM_REFUND",
    FLOOR(AVG(REFUNDS.REFUNDAMOUNT)) AS "AVG_REFUND"
FROM 
    LUGGAGE
LEFT JOIN 
    REFUNDS ON REFUNDS.REFUNDID = LUGGAGE.REFUNDID;
GROUP BY 'LUGGAGE'

CREATE VIEW CustomerLocation AS
SELECT 
    TO_CHAR(SCHEDULES.DEPARTURE, 'HH:MI AM') AS DepartureTime,
    RPAD(ORIGIN.STATEID || ' to ' || DESTINATION.STATEID, 40, '-') AS "Route",
    SUM(CASE WHEN CUSTOMERS.STATEID = ORIGIN.STATEID THEN 1 WHEN CUSTOMERS.STATEID = DESTINATION.STATEID THEN 1 ELSE 0 END) AS InStateCount,
    SUM(CASE WHEN CUSTOMERS.STATEID != ORIGIN.STATEID AND CUSTOMERS.STATEID != DESTINATION.STATEID THEN 1 ELSE 0 END) AS OutOfStateSum
FROM 
    FLIGHTS
LEFT JOIN 
    TICKETS ON TICKETS.FLIGHTID = FLIGHTS.FLIGHTID
LEFT JOIN 
    CUSTOMERS ON CUSTOMERS.CUSTOMERID = TICKETS.HOLDERID
LEFT JOIN
    SCHEDULES ON SCHEDULES.SCHEDULEID = FLIGHTS.FLIGHTID
LEFT JOIN
    AIRPORTS ORIGIN ON ORIGIN.AIRPORTID = FLIGHTS.ORIGINID
LEFT JOIN
    AIRPORTS DESTINATION ON DESTINATION.AIRPORTID = FLIGHTS.DESTINATIONID
GROUP BY 
    SCHEDULES.DEPARTURE,
    ORIGIN.STATEID,
    DESTINATION.STATEID
HAVING 
    SUM(CASE WHEN CUSTOMERS.STATEID = ORIGIN.STATEID THEN 1 WHEN CUSTOMERS.STATEID = DESTINATION.STATEID THEN 1 ELSE 0 END) > 0
    AND
    SUM(CASE WHEN CUSTOMERS.STATEID != ORIGIN.STATEID AND CUSTOMERS.STATEID != DESTINATION.STATEID THEN 1 ELSE 0 END) > 0;

COMMIT;

