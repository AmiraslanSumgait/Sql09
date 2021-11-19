--1. Kitabxanada olmayan kitabları , kitabxanadan götürmək olmaz.

CREATE TRIGGER StudentBooks
ON S_Cards
AFTER INSERT
AS
BEGIN
    DECLARE @id int=0;
    SELECT @id=Id_Book FROM inserted
	IF EXISTS
	(
	  SELECT * FROM Books
	  WHERE Books.Id=@id AND Books.Quantity=0
	)
	BEGIN
	  PRINT 'Quantity=0'
	  ROLLBACK TRAN
	END
	
END



CREATE TRIGGER TeacherBooks
ON T_Cards
AFTER INSERT
AS
BEGIN
    DECLARE @id int=0;
    SELECT @id=Id_Book FROM inserted
	IF EXISTS
	(
	  SELECT * FROM Books
	  WHERE Books.Id=@id AND Books.Quantity=0
	)
	BEGIN
	  PRINT 'Quantity=0'
	  ROLLBACK TRAN
	END
END

 INSERT INTO S_Cards VALUES (155,13,26,'2019.12.12',NULL,2)

 --2. Müəyyən kitabı qaytardıqda, onun Quantity-si (sayı) artmalıdır.

CREATE TRIGGER StudentBookReturn
ON S_Cards
AFTER UPDATE
AS
BEGIN
    DECLARE @id int=0;
	SELECT @id=Id_Book FROM inserted
	UPDATE Books
	SET Quantity+=1
	WHERE Books.Id=@id
END


CREATE TRIGGER TeacherBookReturn
ON T_Cards
AFTER UPDATE
AS
BEGIN
    DECLARE @id int=0;
	SELECT @id=Id_Book FROM inserted
	UPDATE Books
	SET Quantity+=1
	WHERE Books.Id=@id
END

SELECT*FROM T_Cards
 UPDATE T_Cards
 SET DateIn='2010.07.07'
 WHERE T_Cards.Id=8

 --3. Kitab kitabxanadan verildikdə onun sayı azalmalıdır.
CREATE TRIGGER StudentTakeBook
ON S_Cards
AFTER INSERT
AS
BEGIN
    DECLARE @id int=0;
    SELECT @id=Id_Book FROM inserted
	
	UPDATE Books
	SET Quantity-=1
	WHERE Books.Id=@id
END


CREATE TRIGGER TeacherTakeBook
ON T_Cards
AFTER INSERT
AS
BEGIN
    DECLARE @id int=0;
    SELECT @id=Id_Book FROM inserted
	
	UPDATE Books
	SET Quantity-=1
	WHERE Books.Id=@id
END

INSERT INTO T_Cards VALUES (10,8,14,'2021.11.15',NULL,1)


--4. Bir tələbə artıq 3 kitab götütürübsə ona yeni kitab vermək olmaz.
CREATE TRIGGER StudentTakeThreeBook
ON S_Cards
AFTER INSERT
AS
BEGIN
	DECLARE @bookCount int
	DECLARE @idStudent int
	SELECT @idStudent = Id_Student FROM inserted
	
	SELECT @bookCount = COUNT(*) FROM S_Cards
	WHERE Id_Student = @idStudent
	

	IF(@bookCount > 3)
	BEGIN
		PRINT 'Taken books more than 3!'
		ROLLBACK TRAN
	END
END




--5. Əgər tələbə bir kitabı 2aydan çoxdur oxuyursa, bu halda tələbəyə yeni kitab vermək olmaz.

CREATE TRIGGER StudentReadBookMoreThanTwoMonths
ON S_Cards
AFTER INSERT
AS
BEGIN
	DECLARE @idStd int
	SELECT @idStd = Id_Student FROM inserted

	IF EXISTS(SELECT * FROM S_Cards INNER JOIN Books 
	          ON Books.Id = S_Cards.Id
			  WHERE Id_Student = @idStd AND DateIn IS NULL AND DATEDIFF(MONTH,DateOut,CONVERT(date,GETDATE())) > 2)
	BEGIN
		PRINT 'you used book more than two years'
		ROLLBACK TRAN
	END

END

INSERT INTO S_Cards VALUES (111,22,13,'2018.14.21',NULL,1)


--6. Kitabı bazadan sildikdə, onun haqqında data LibDeleted cədvəlinə köçürülməlidir./

CREATE TRIGGER DeleteBook
ON Books
AFTER DELETE
AS
BEGIN
	DECLARE @LibDeleted TABLE(ID int, Name nvarchar(30), Pages int, YearPress date, ThemesID int,CategoryID int,AuthorID int,PressID int,Comment nvarchar(MAX),Quantity int)
	INSERT @LibDeleted
	SELECT Id, Name, Pages, YearPress, Id_Themes, 
	Id_Category, Id_Author, Id_Press, Comment, Quantity
	FROM deleted
END