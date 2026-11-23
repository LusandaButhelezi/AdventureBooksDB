#### AdventureBooks SQL

T-SQL scripts for the AdventureBooksDB database (SQL Server). 

#### Contents

RollBackQuest_and_BookRating.sql contains two database objects: 

#### RollBackQuest (stored procedure)

Rolls back a set of quests for a reader's book and sets a new current quest. 

ParameterTypeDescription
**@ReaderBookId**
INTThe reader's book to update
**@NewCurrentQuestNo**
INTThe quest to set as the new current quest (status set to NULL)
**@RollbackQuest**
VARCHAR(300)Comma-separated quest numbers to roll back, e.g. '3,4,5'
**@Count**
INT OUTPUTNumber of quests rolled back

Rolled-back quests receive the status whose QuestStatusText is 'R'. 

**Example** 

sql

DECLARE @Count INT;
EXEC RollBackQuest
    @ReaderBookId = 1,
    @NewCurrentQuestNo = 3,
    @RollbackQuest = '3,4,5',
    @Count = @Count OUTPUT;
SELECT @Count AS QuestsRolledBack;

Use code with caution.

Copy code text to clipboard.

#### trg_UpdateBookRating (trigger)

Fires after an INSERT or UPDATE on Review and recalculates Book.BookRating as the average review rating (RatingRanking) for each affected book. 

#### Usage

1. Open the script in SQL Server Management Studio (or Azure Data Studio).
2. Make sure AdventureBooksDB exists with the Book, ReaderBook, ReaderQuest, QuestStatus, Review and ReviewRating tables.
3. Run the script.
