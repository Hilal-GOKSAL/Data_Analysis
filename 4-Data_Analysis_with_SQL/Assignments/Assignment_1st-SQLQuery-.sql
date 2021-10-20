Use SampleSales

----///////------

--1. Transaction Logs
--Below, you see a transaction table where the logs of transactions between accounts are stored. Write a query to return the change in net worth for each user, ordered by decreasing net change.

--Transactions:
--Sender_ID		Receiver_ID		Amount		Transaction_Date
--55				22			500			18.05.2021
--11				33			350			19.05.2021
--22				11			650			19.05.2021
--22				33			900			20.05.2021
--33				11			500			21.05.2021
--33				22			750			21.05.2021
--11				44			300			22.05.2021

--Desired Output
--Account_ID	Net_Change
--11				500
--44				300
--33				0
--22			   -300
--55			   -500

--Create above table (transactions) and insert values,

CREATE TABLE Transactions (
    Sender_ID int  ,
    Receiver_ID int   ,
    Amount int ,
    Transaction_Date DATE NOT NULL ,
    );
INSERT INTO Transactions(Sender_ID ,Receiver_ID ,Amount,Transaction_Date)
VALUES(55,22,500,'20210518'),
(11,33,350,'20210519'),
(22,11,650,'20210519'),
(22,33,900,'20210520'),
(33,11,500,'20210521'),
(33,22,750,'20210521'),
(11,44,300,'20210522')
 
 /*
 SELECT *
 FROM Transactions;
 */

/* DROP TABLE Transactions */


--	Sum amounts for each sender (debits) and receiver (credits),


SELECT			Sender_ID, SUM(Amount) AS Sender
FROM			Transactions
GROUP BY		Sender_ID;


SELECT			Receiver_ID, SUM(Amount) AS Receiver
FROM			Transactions
GROUP BY		Receiver_ID

--Full (outer) join debits and credits tables on account id, taking net change as difference between credits and debits, coercing nulls to zeros with coalesce()

--Desired Output
--Account_ID	Net_Change
--11				500
--44				300
--33				0
--22			   -300
--55			   -500


SELECT				COALESCE(S.Sender_ID, R.Receiver_Id) AS Acount_ID ,(COALESCE(R.Receiver,0)-COALESCE(S.Sender,0)) AS Net_Change

FROM				(SELECT Sender_ID, SUM (Amount) AS Sender FROM Transactions GROUP BY Sender_ID) AS S

FULL OUTER JOIN		(SELECT Receiver_ID, SUM (Amount) AS Receiver FROM Transactions GROUP BY Receiver_ID) AS R ON S.Sender_ID=R.Receiver_ID

Order BY			Net_Change DESC;
