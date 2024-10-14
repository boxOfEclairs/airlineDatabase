This database was created for my Oracle/SQL class, as a demonstration of my SQL skills.

It is created as a simulation of an airlines operations, with tables for everything that would be needed for customer-facing operation. With this, you are able to sell tickets between two cities, give refunds, create delays, track luggage, and more. An explanation of the most important parts are given below the build instructions. Sample data for every table is given.

![test](https://github.com/boxOfEclairs/airlineDatabase/blob/main/AirlineERdiagram.png)
Here is the ER diagram of the database.

To build with just one file, run **createAll.sql**.

To build the database individually, run the files in the following order in Oracle:

**1) createSequences.sql**

	Creates the sequences used for the primary key in select tables.

**2) createTables.sql**

	This will create all of the base tables of the database.

**3) createTriggers.sql**

	Creates triggers for primary key sequences and loyalty program.

**4) addData.sql**

	Adds the data to all of the tables.

**5) createIndexes.sql**

	Creates indexes on commonly accessed values.
**6) createViews.sql**

	Creates views.

To drop the database, simply run **dropAll.sql**.

  

## Tables

**States**
Lookup table for state abbreviations.

**Seats**
Describes layout of plane, has row and column of seat each seat.

**Customers**
Stores customer information such as name, email, phone and address.

**Airports**
Lookup table for major airports.

**Managers**
List of people with privileges in database.

**Schedules**
Flight schedules with departure and arrival dates.

**Flights**
Location information for a given flight, such as departure and arrival airports.

**Loyalty**
Tracks loyalty points for customers who have signed up for the loyalty program.

**Delays**
Tracks delays (if any) for a flight.

**Refunds**
Keeps track of any refunds given, and which manager authorized it. Used for both ticket and luggage refunds.

**Tickets**
Links customer, flight, seat and refund information together.

**Luggage**
Tracks customer luggage and which flight it is on.
  

## Views

**DepartureBoard**
Shows departure gate, destination, time of departure, arrival time and flight status for a given airport. The flights shown will be all of the flights which depart the given airport. All times are adjusted if there is any delay present for the flight.
This view is preset to Chicago O'Hare.

**SeatMap**
Shows a visual representation of sold seats on a plane. An ASCII image is shown where there are 6 columns and 16 rows. Each empty seat is represented by an 'O', and the sold seat is represented by an 'X'. This view is preset to the flight with a FlightID of 2.

**LoyaltyProgram**
Shows customer name, their total spend with the airline, their total refund amount with the airline and amount of loyalty points in their account.

**Finances**
Shows sum of sales, average amount of a sale, sum of refunds and average amount of a refund. This is separated into ticket and luggage sales.

**CustomerLocation**
This view shows how many passengers of a city pair live in the state the flight originated from, or outside of it. The columns of this view are time of departure, the city pair, number of in state customers and number of out of state customers. This would be useful information in deciding groups of people to market a certain route to.
  

## Triggers

**AddPoints**
Adds points to the customers loyalty account for each purchase they make. In actuality, loyalty points are added for the customer whenever a ticket row is added to the tickets table and the customer has a loyalty account. Loyalty points are based on the mileage of the flight that they purchased a ticket for.

**RemovePoints**
Does the opposite of the previous trigger. When a ticket row is deleted from the tickets table, the points are removed from the customers loyalty account if they have one.
