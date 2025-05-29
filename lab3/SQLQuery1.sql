-- Создаем базу данных MovieNetwork
USE master;
GO
DROP DATABASE IF EXISTS MovieNetwork;
GO
CREATE DATABASE MovieNetwork;
GO
USE MovieNetwork;
GO

-- 1. Создаем три таблицы узлов
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

-- 2. Создаем три таблицы ребер
CREATE TABLE BelongsToGenre AS EDGE;    -- Фильм принадлежит жанру
CREATE TABLE StarsIn AS EDGE;          -- Актёр снимается в фильме
CREATE TABLE Recommends AS EDGE;       -- Фильм рекомендует другой фильм

-- Добавляем ограничения соединения
ALTER TABLE BelongsToGenre 
ADD CONSTRAINT EC_BelongsToGenre CONNECTION (Movie TO Genre);

ALTER TABLE StarsIn 
ADD CONSTRAINT EC_StarsIn CONNECTION (Actor TO Movie);

ALTER TABLE Recommends 
ADD CONSTRAINT EC_Recommends CONNECTION (Movie TO Movie);
GO

-- 3. Заполняем таблицы узлов
-- Фильмы
INSERT INTO Movie (id, title, year, rating) VALUES
(1, N'Матрица', 1999, 8.7),
(2, N'Начало', 2010, 8.8),
(3, N'Побег из Шоушенка', 1994, 9.3),
(4, N'Крестный отец', 1972, 9.2),
(5, N'Темный рыцарь', 2008, 9.0),
(6, N'Форрест Гамп', 1994, 8.8),
(7, N'Интерстеллар', 2014, 8.6),
(8, N'Список Шиндлера', 1993, 8.9),
(9, N'Бойцовский клуб', 1999, 8.8),
(10, N'Властелин колец: Братство кольца', 2001, 8.8);

-- Жанры
INSERT INTO Genre (id, name) VALUES
(1, N'Фантастика'),
(2, N'Драма'),
(3, N'Боевик'),
(4, N'Криминал'),
(5, N'Приключения'),
(6, N'Триллер'),
(7, N'Исторический'),
(8, N'Фэнтези'),
(9, N'Детектив'),
(10, N'Мелодрама');

-- Актеры
INSERT INTO Actor (id, full_name, birth_year) VALUES
(1, N'Киану Ривз', 1964),
(2, N'Леонардо ДиКаприо', 1974),
(3, N'Тим Роббинс', 1958),
(4, N'Марлон Брандо', 1924),
(5, N'Кристиан Бейл', 1974),
(6, N'Том Хэнкс', 1956),
(7, N'Мэттью Макконахи', 1969),
(8, N'Лиам Нисон', 1952),
(9, N'Эдвард Нортон', 1969),
(10, N'Элайджа Вуд', 1981);

-- 4. Создаем связи через таблицы ребер
-- Связи фильмов с жанрами
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

-- Связи актеров с фильмами
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

-- Рекомендации от фильма к фильму
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

--5. Используем функцию MATCH

-- 5.1. Найти все фантастические фильмы
SELECT m.title AS MovieTitle, g.name AS GenreName
FROM Movie m, BelongsToGenre bg, Genre g
WHERE MATCH(m-(bg)->g)
AND g.name = N'Фантастика';

-- 5.2. Найти всех актеров, снимавшихся в 'Матрица'
SELECT a.full_name AS ActorName, m.title AS MovieTitle
FROM Actor a, StarsIn si, Movie m
WHERE MATCH(a-(si)->m)
AND m.title = N'Матрица';

-- 5.3. Найти фильмы, рекомендованные 'Начало'
SELECT rec.title AS RecommendedMovie
FROM Movie m, Recommends r, Movie rec
WHERE MATCH(m-(r)->rec)
AND m.title = N'Начало';

-- 5.4. Найти фильмы с Леонардо ДиКаприо и их жанры
SELECT m.title AS MovieTitle, g.name AS GenreName
FROM Actor a, StarsIn si, Movie m, BelongsToGenre bg, Genre g
WHERE MATCH(a-(si)->m-(bg)->g)
AND a.full_name = N'Леонардо ДиКаприо';

-- 5.5. Найти цепочку рекомендаций от 'Бойцовский клуб'
SELECT m1.title AS OriginalMovie, 
       m2.title AS RecommendedLevel1, 
       m3.title AS RecommendedLevel2
FROM Movie m1, Recommends r1, Movie m2, 
     Recommends r2, Movie m3
WHERE MATCH(m1-(r1)->m2-(r2)->m3)
AND m1.title = N'Бойцовский клуб';

-- 6.1 Используем как шаблон  "+"

DECLARE @StartMovie NVARCHAR(100) = N'Начало';
DECLARE @EndMovie NVARCHAR(100) = N'Интерстеллар';

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


-- 6.2  Используем как шаблон({1,4}) 1 Вариант
DECLARE @Actor1 NVARCHAR(100) = N'Киану Ривз';
DECLARE @Actor2 NVARCHAR(100) = N'Леонардо ДиКаприо';

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

--------6.2 Используем как шаблон({1,4}) 2 Вариант
DECLARE @Actor1 NVARCHAR(100) = N'Киану Ривз';
DECLARE @Actor2 NVARCHAR(100) = N'Леонардо ДиКаприо';

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