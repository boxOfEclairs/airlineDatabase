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

COMMIT;