CREATE INDEX scheduleIndex ON SCHEDULES(Departure, Arrival);

CREATE INDEX flightIndex on FLIGHTS(ScheduleID, OriginID, DestinationID);

CREATE INDEX loyaltyIndex ON LOYALTY(CustomerID);

CREATE INDEX delayIndex ON DELAYS(DelayedFlightID);

CREATE INDEX refundIndex ON REFUNDS(CustomerID);

CREATE INDEX ticketIndex ON TICKETS(HolderID, FlightID, RefundID);

CREATE INDEX luggageIndex ON LUGGAGE(OwnerID, FlightID, RefundID);

COMMIT;