USE AdventureBooksDB;
GO

CREATE PROC RollBackQuest
   @ReaderBookId INT,
   @NewCurrentQuestNo INT,
   @RollbackQuest VARCHAR(300),
   @Count INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Pos INT;
    DECLARE @QuestNo VARCHAR(10);
    DECLARE @RolledBackStatusId INT;

    SET @Count = 0;

    SELECT @RolledBackStatusId = QuestStatusId
    FROM QuestStatus
    WHERE QuestStatusText = 'R';

    WHILE LEN(@RollbackQuest) > 0
    BEGIN
        SET @Pos = CHARINDEX(',', @RollbackQuest);

        IF @Pos = 0
            SET @Pos = LEN(@RollbackQuest) + 1;

        SET @QuestNo = LTRIM(RTRIM(LEFT(@RollbackQuest, @Pos - 1)));

        UPDATE ReaderQuest
        SET QuestStatusId = @RolledBackStatusId
        WHERE ReaderBookId = @ReaderBookId
        AND QuestNo = CAST(@QuestNo AS INT);

        SET @Count = @Count + @@ROWCOUNT;

        SET @RollbackQuest = SUBSTRING(@RollbackQuest, @Pos + 1, LEN(@RollbackQuest));
    END

    UPDATE ReaderQuest
    SET QuestStatusId = NULL
    WHERE ReaderBookId = @ReaderBookId
    AND QuestNo = @NewCurrentQuestNo;

END;
GO


CREATE TRIGGER trg_UpdateBookRating
ON Review
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE b
    SET b.BookRating = AvgTable.AvgRating
    FROM Book b
    INNER JOIN (
        SELECT rb.BookId,
               AVG(rr.RatingRanking) AS AvgRating
        FROM Review r
        INNER JOIN ReaderBook rb ON r.ReaderBookId = rb.ReaderBookId
        INNER JOIN ReviewRating rr ON r.RatingId = rr.RatingId
        GROUP BY rb.BookId
    ) AS AvgTable
    ON b.BookId = AvgTable.BookId
    WHERE b.BookId IN (
        SELECT rb.BookId
        FROM inserted i
        INNER JOIN ReaderBook rb ON i.ReaderBookId = rb.ReaderBookId
    );

END;
GO