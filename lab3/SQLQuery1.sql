-- ������� ���� ������ MovieNetwork
USE master;
GO
DROP DATABASE IF EXISTS MovieNetwork;
GO
CREATE DATABASE MovieNetwork;
GO
USE MovieNetwork;
GO

-- 1. ������� ��� ������� �����
CREATE TABLE Movie (
    id INT PRIMARY KEY,
    title NVARCHAR(100) NOT NULL,
    year INT,
    rating DECIMAL(3,1)
) AS NODE;

CREATE TABLE Genre (
    id INT PRIMARY KEY,
    name NVARCHAR(50) NOT NULL
) AS NODE;

CREATE TABLE Actor (
    id INT PRIMARY KEY,
    full_name NVARCHAR(100) NOT NULL,
    birth_year INT
) AS NODE;

-- 2. ������� ��� ������� �����
CREATE TABLE BelongsToGenre AS EDGE;    -- ����� ����������� �����
CREATE TABLE StarsIn AS EDGE;          -- ���� ��������� � ������
CREATE TABLE Recommends AS EDGE;       -- ����� ����������� ������ �����

-- ��������� ����������� ����������
ALTER TABLE BelongsToGenre 
ADD CONSTRAINT EC_BelongsToGenre CONNECTION (Movie TO Genre);

ALTER TABLE StarsIn 
ADD CONSTRAINT EC_StarsIn CONNECTION (Actor TO Movie);

ALTER TABLE Recommends 
ADD CONSTRAINT EC_Recommends CONNECTION (Movie TO Movie);
GO

-- 3. ��������� ������� �����
-- ������
INSERT INTO Movie (id, title, year, rating) VALUES
(1, N'�������', 1999, 8.7),
(2, N'������', 2010, 8.8),
(3, N'����� �� ��������', 1994, 9.3),
(4, N'�������� ����', 1972, 9.2),
(5, N'������ ������', 2008, 9.0),
(6, N'������� ����', 1994, 8.8),
(7, N'������������', 2014, 8.6),
(8, N'������ ��������', 1993, 8.9),
(9, N'���������� ����', 1999, 8.8),
(10, N'��������� �����: �������� ������', 2001, 8.8);

-- �����
INSERT INTO Genre (id, name) VALUES
(1, N'����������'),
(2, N'�����'),
(3, N'������'),
(4, N'��������'),
(5, N'�����������'),
(6, N'�������'),
(7, N'������������'),
(8, N'�������'),
(9, N'��������'),
(10, N'���������');

-- ������
INSERT INTO Actor (id, full_name, birth_year) VALUES
(1, N'����� ����', 1964),
(2, N'�������� ��������', 1974),
(3, N'��� �������', 1958),
(4, N'������ ������', 1924),
(5, N'�������� ����', 1974),
(6, N'��� �����', 1956),
(7, N'������ ���������', 1969),
(8, N'���� �����', 1952),
(9, N'������ ������', 1969),
(10, N'������� ���', 1981);

-- 4. ������� ����� ����� ������� �����
-- ����� ������� � �������
INSERT INTO BelongsToGenre ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Movie WHERE id = 1), (SELECT $node_id FROM Genre WHERE id = 1)),
((SELECT $node_id FROM Movie WHERE id = 2), (SELECT $node_id FROM Genre WHERE id = 1)),
((SELECT $node_id FROM Movie WHERE id = 3), (SELECT $node_id FROM Genre WHERE id = 2)),
((SELECT $node_id FROM Movie WHERE id = 4), (SELECT $node_id FROM Genre WHERE id = 4)),
((SELECT $node_id FROM Movie WHERE id = 5), (SELECT $node_id FROM Genre WHERE id = 3)),
((SELECT $node_id FROM Movie WHERE id = 6), (SELECT $node_id FROM Genre WHERE id = 2)),
((SELECT $node_id FROM Movie WHERE id = 7), (SELECT $node_id FROM Genre WHERE id = 1)),
((SELECT $node_id FROM Movie WHERE id = 8), (SELECT $node_id FROM Genre WHERE id = 7)),
((SELECT $node_id FROM Movie WHERE id = 9), (SELECT $node_id FROM Genre WHERE id = 6)),
((SELECT $node_id FROM Movie WHERE id = 10), (SELECT $node_id FROM Genre WHERE id = 8));

-- ����� ������� � ��������
INSERT INTO StarsIn ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Actor WHERE id = 1), (SELECT $node_id FROM Movie WHERE id = 1)),
((SELECT $node_id FROM Actor WHERE id = 2), (SELECT $node_id FROM Movie WHERE id = 2)),
((SELECT $node_id FROM Actor WHERE id = 3), (SELECT $node_id FROM Movie WHERE id = 3)),
((SELECT $node_id FROM Actor WHERE id = 4), (SELECT $node_id FROM Movie WHERE id = 4)),
((SELECT $node_id FROM Actor WHERE id = 5), (SELECT $node_id FROM Movie WHERE id = 5)),
((SELECT $node_id FROM Actor WHERE id = 6), (SELECT $node_id FROM Movie WHERE id = 6)),
((SELECT $node_id FROM Actor WHERE id = 7), (SELECT $node_id FROM Movie WHERE id = 7)),
((SELECT $node_id FROM Actor WHERE id = 8), (SELECT $node_id FROM Movie WHERE id = 8)),
((SELECT $node_id FROM Actor WHERE id = 9), (SELECT $node_id FROM Movie WHERE id = 9)),
((SELECT $node_id FROM Actor WHERE id = 10), (SELECT $node_id FROM Movie WHERE id = 10));

-- ������������ �� ������ � ������
INSERT INTO Recommends ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Movie WHERE id = 1), (SELECT $node_id FROM Movie WHERE id = 2)),
((SELECT $node_id FROM Movie WHERE id = 2), (SELECT $node_id FROM Movie WHERE id = 7)),
((SELECT $node_id FROM Movie WHERE id = 3), (SELECT $node_id FROM Movie WHERE id = 6)),
((SELECT $node_id FROM Movie WHERE id = 4), (SELECT $node_id FROM Movie WHERE id = 5)),
((SELECT $node_id FROM Movie WHERE id = 5), (SELECT $node_id FROM Movie WHERE id = 1)),
((SELECT $node_id FROM Movie WHERE id = 6), (SELECT $node_id FROM Movie WHERE id = 8)),
((SELECT $node_id FROM Movie WHERE id = 7), (SELECT $node_id FROM Movie WHERE id = 10)),
((SELECT $node_id FROM Movie WHERE id = 8), (SELECT $node_id FROM Movie WHERE id = 3)),
((SELECT $node_id FROM Movie WHERE id = 9), (SELECT $node_id FROM Movie WHERE id = 5)),
((SELECT $node_id FROM Movie WHERE id = 10), (SELECT $node_id FROM Movie WHERE id = 9));

--SELECT * FROM Movie;
--SELECT * FROM Genre;
--SELECT * FROM Actor;
--SELECT * FROM BelongsToGenre;
--SELECT * FROM StarsIn;
--SELECT * FROM Recommends;

--5. ���������� ������� MATCH

-- 5.1. ����� ��� �������������� ������
SELECT m.title AS MovieTitle, g.name AS GenreName
FROM Movie m, BelongsToGenre bg, Genre g
WHERE MATCH(m-(bg)->g)
AND g.name = N'����������';

-- 5.2. ����� ���� �������, ����������� � '�������'
SELECT a.full_name AS ActorName, m.title AS MovieTitle
FROM Actor a, StarsIn si, Movie m
WHERE MATCH(a-(si)->m)
AND m.title = N'�������';

-- 5.3. ����� ������, ��������������� '������'
SELECT rec.title AS RecommendedMovie
FROM Movie m, Recommends r, Movie rec
WHERE MATCH(m-(r)->rec)
AND m.title = N'������';

-- 5.4. ����� ������ � �������� �������� � �� �����
SELECT m.title AS MovieTitle, g.name AS GenreName
FROM Actor a, StarsIn si, Movie m, BelongsToGenre bg, Genre g
WHERE MATCH(a-(si)->m-(bg)->g)
AND a.full_name = N'�������� ��������';

-- 5.5. ����� ������� ������������ �� '���������� ����'
SELECT m1.title AS OriginalMovie, 
       m2.title AS RecommendedLevel1, 
       m3.title AS RecommendedLevel2
FROM Movie m1, Recommends r1, Movie m2, 
     Recommends r2, Movie m3
WHERE MATCH(m1-(r1)->m2-(r2)->m3)
AND m1.title = N'���������� ����';

-- 6.1 ���������� ��� ������  "+"

DECLARE @StartMovie NVARCHAR(100) = N'������';
DECLARE @EndMovie NVARCHAR(100) = N'������������';

WITH Recommendations AS (
    SELECT 
        m1.title AS StartTitle,
        STRING_AGG(m2.title, ' -> ') WITHIN GROUP (GRAPH PATH) AS Path,
        LAST_VALUE(m2.title) WITHIN GROUP (GRAPH PATH) AS LastMovie
    FROM 
        Movie AS m1,
        Recommends FOR PATH AS rec,
        Movie FOR PATH AS m2
    WHERE MATCH(SHORTEST_PATH(m1(-(rec)->m2)+))
    AND m1.title = @StartMovie
)
SELECT StartTitle, Path 
FROM Recommendations
WHERE LastMovie = @EndMovie;


-- 6.2  ���������� ��� ������({1,4}) 1 �������
DECLARE @Actor1 NVARCHAR(100) = N'����� ����';
DECLARE @Actor2 NVARCHAR(100) = N'�������� ��������';

WITH ActorConnections AS (
    SELECT 
        a1.full_name AS StartActor,
        STRING_AGG(m.title, ' -> ') WITHIN GROUP (GRAPH PATH) AS ConnectionPath,
        LAST_VALUE(a2.full_name) WITHIN GROUP (GRAPH PATH) AS EndActor
    FROM 
        Actor AS a1,
        StarsIn FOR PATH AS si1,
        Movie FOR PATH AS m,
        Recommends FOR PATH AS rec,  
        Movie FOR PATH AS m2,
        StarsIn FOR PATH AS si2,
        Actor FOR PATH AS a2
    WHERE MATCH(SHORTEST_PATH(a1(-(si1)->m-(rec)->m2<-(si2)-a2){1,4}))
    AND a1.full_name = @Actor1
)
SELECT StartActor, ConnectionPath 
FROM ActorConnections
WHERE EndActor = @Actor2;

go

--------6.2 ���������� ��� ������({1,4}) 2 �������
DECLARE @Actor1 NVARCHAR(100) = N'����� ����';
DECLARE @Actor2 NVARCHAR(100) = N'�������� ��������';

SELECT 
    a1.full_name AS StartActor,
    m1.title + ' -> ' + m2.title AS ConnectionPath,
    a2.full_name AS EndActor
FROM 
    Actor a1
    JOIN StarsIn si1 ON a1.$node_id = si1.$from_id
    JOIN Movie m1 ON si1.$to_id = m1.$node_id
    JOIN Recommends r ON m1.$node_id = r.$from_id
    JOIN Movie m2 ON r.$to_id = m2.$node_id
    JOIN StarsIn si2 ON m2.$node_id = si2.$to_id
    JOIN Actor a2 ON si2.$from_id = a2.$node_id
WHERE 
    a1.full_name = @Actor1
    AND a2.full_name = @Actor2;
	SELECT @@SERVERNAME