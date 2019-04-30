{
    "metadata": {
        "kernelspec": {
            "name": "SQL",
            "display_name": "SQL",
            "language": "sql"
        },
        "language_info": {
            "name": "sql",
            "version": ""
        }
    },
    "nbformat_minor": 2,
    "nbformat": 4,
    "cells": [
        {
            "cell_type": "markdown",
            "source": "# Join - инструмент объединения данных из нескольких связанных таблиц\r\n\r\nРеляционная модель данных подразумевает отдельное хранение и возможность независимой обработки данных для каждой сущности.\r\n\r\nВместе с тем, часто возникает потребность собрать данные из нескольких, связанных таблиц.\r\n\r\nКак правило, сущности (таблицы) связаны друг с другом внешними связями по принципу (_primary key -- foreign key_).\r\n\r\nСвязи могут быть типа _\"1 к 1\"_ или _\"1 ко многим\"_ (с вариантами _\"1 к 0 или 1\"_, _\"1 к 0 или более\"_, _\"1 к 2\"_ и пр).<br/>\r\nСвязь _\"многие-ко-многим\"_ в реляционной модели обеспечивается с помощью дополнительной таблицы связей (другие названия: Link-таблица, Bridge-таблица, xref-таблица).\r\n\r\nВ зависимости от характера связей между таблицами, _логически операция соединения_ может быть:\r\n- _внутренним соединением_ (INNER JOIN). При этом:\r\n    - если условие соединения отсутствует, то такой INNER JOIN называют декартовым произведением (CROSS JOIN, CARTESIAN PRODUCT)\r\n    - если для описания связи между наборами данных использются корреляционные подзапросы, то такой INNER JOIN называют CROSS APPLY\r\n    \r\n- _внешним соединением_ (OUTER JOIN). Разновидности - LEFT JOIN, RIGHT JOIN, FULL JOIN\r\n    - если для описания связи между наборами данных использются корреляционные подзапросы, то такой OUTER JOIN называют OUTER APPLY\r\n\r\n",
            "metadata": {}
        },
        {
            "cell_type": "markdown",
            "source": "## Пример логической модели данных:\r\n\r\n<img src=\"https://github.com/timoti1/T-SQL/blob/master/SQL/img/SwimmersDB.png?raw=1\" />",
            "metadata": {}
        },
        {
            "cell_type": "markdown",
            "source": "Обратите внимание на данные в наших таблицах. \r\n\r\nУ некоторых спортсменов нет категории, клуба или тренера (или они неизвестны).<br/>\r\nВстречаются спортсмены, которых ведёт несколько тренеров.\r\n\r\nПро одни сущности есть чуть больше информации чем про другие.",
            "metadata": {}
        },
        {
            "cell_type": "code",
            "source": "use tempdb\r\ngo\r\n\r\n--содержимое таблиц:\r\nselect * from dbo.SwimmingClub \r\nselect * from dbo.Swimmer\r\nselect * from dbo.Category ",
            "metadata": {},
            "outputs": [
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Commands completed successfully."
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.0016185"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "(3 rows affected)"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "(7 rows affected)"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "(3 rows affected)"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.0112856"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "execute_result",
                    "metadata": {},
                    "execution_count": 19,
                    "data": {
                        "application/vnd.dataresource+json": {
                            "schema": {
                                "fields": [
                                    {
                                        "name": "SwimmingClubID"
                                    },
                                    {
                                        "name": "Name"
                                    },
                                    {
                                        "name": "City"
                                    },
                                    {
                                        "name": "Address"
                                    },
                                    {
                                        "name": "Phone"
                                    },
                                    {
                                        "name": "YearEstablished"
                                    },
                                    {
                                        "name": "ModifiedDate"
                                    }
                                ]
                            },
                            "data": [
                                {
                                    "0": "2",
                                    "1": "ГЦОР Трактор",
                                    "2": "Минск",
                                    "3": "NULL",
                                    "4": "NULL",
                                    "5": "NULL",
                                    "6": "2019-04-29 12:40:51.780"
                                },
                                {
                                    "0": "3",
                                    "1": "ДЮСШ Янтарь",
                                    "2": "Minsk",
                                    "3": "NULL",
                                    "4": "NULL",
                                    "5": "NULL",
                                    "6": "2019-04-29 12:40:51.780"
                                },
                                {
                                    "0": "4",
                                    "1": "СК Олимпик-2011",
                                    "2": "Молодечно",
                                    "3": "NULL",
                                    "4": "NULL",
                                    "5": "NULL",
                                    "6": "2019-04-29 12:40:51.780"
                                }
                            ]
                        },
                        "text/html": "<table><tr><th>SwimmingClubID</th><th>Name</th><th>City</th><th>Address</th><th>Phone</th><th>YearEstablished</th><th>ModifiedDate</th></tr><tr><td>2</td><td>ГЦОР Трактор</td><td>Минск</td><td>NULL</td><td>NULL</td><td>NULL</td><td>2019-04-29 12:40:51.780</td></tr><tr><td>3</td><td>ДЮСШ Янтарь</td><td>Minsk</td><td>NULL</td><td>NULL</td><td>NULL</td><td>2019-04-29 12:40:51.780</td></tr><tr><td>4</td><td>СК Олимпик-2011</td><td>Молодечно</td><td>NULL</td><td>NULL</td><td>NULL</td><td>2019-04-29 12:40:51.780</td></tr></table>"
                    }
                },
                {
                    "output_type": "execute_result",
                    "metadata": {},
                    "execution_count": 19,
                    "data": {
                        "application/vnd.dataresource+json": {
                            "schema": {
                                "fields": [
                                    {
                                        "name": "SwimmerID"
                                    },
                                    {
                                        "name": "FirstName"
                                    },
                                    {
                                        "name": "LastName"
                                    },
                                    {
                                        "name": "YearOfBirth"
                                    },
                                    {
                                        "name": "Gender"
                                    },
                                    {
                                        "name": "SwimmingClubID"
                                    },
                                    {
                                        "name": "CategoryId"
                                    },
                                    {
                                        "name": "ModifiedDate"
                                    },
                                    {
                                        "name": "isdeleted"
                                    }
                                ]
                            },
                            "data": [
                                {
                                    "0": "2",
                                    "1": "Анна",
                                    "2": "Высоцкая",
                                    "3": "2007",
                                    "4": "ж",
                                    "5": "3",
                                    "6": "4",
                                    "7": "2019-04-29 12:40:51.810",
                                    "8": "1"
                                },
                                {
                                    "0": "3",
                                    "1": "Илья",
                                    "2": "Гавриленко",
                                    "3": "2006",
                                    "4": "м",
                                    "5": "2",
                                    "6": "3",
                                    "7": "2019-04-29 12:40:51.810",
                                    "8": "0"
                                },
                                {
                                    "0": "4",
                                    "1": "Максим",
                                    "2": "Кликушин",
                                    "3": "2007",
                                    "4": "м",
                                    "5": "2",
                                    "6": "3",
                                    "7": "2019-04-29 12:40:51.810",
                                    "8": "0"
                                },
                                {
                                    "0": "5",
                                    "1": "Матвей",
                                    "2": "Данкевич",
                                    "3": "2006",
                                    "4": "м",
                                    "5": "4",
                                    "6": "2",
                                    "7": "2019-04-29 12:40:51.810",
                                    "8": "0"
                                },
                                {
                                    "0": "6",
                                    "1": "Никита",
                                    "2": "Клюй",
                                    "3": "2005",
                                    "4": "м",
                                    "5": "3",
                                    "6": "3",
                                    "7": "2019-04-29 12:40:51.810",
                                    "8": "0"
                                },
                                {
                                    "0": "9",
                                    "1": "Gleb",
                                    "2": "Bondarec",
                                    "3": "2007",
                                    "4": "м",
                                    "5": "2",
                                    "6": "NULL",
                                    "7": "2019-04-29 15:38:38.427",
                                    "8": "0"
                                },
                                {
                                    "0": "11",
                                    "1": "Алексей",
                                    "2": "Рылько",
                                    "3": "2005",
                                    "4": "м",
                                    "5": "3",
                                    "6": "NULL",
                                    "7": "2019-04-30 10:58:20.420",
                                    "8": "1"
                                }
                            ]
                        },
                        "text/html": "<table><tr><th>SwimmerID</th><th>FirstName</th><th>LastName</th><th>YearOfBirth</th><th>Gender</th><th>SwimmingClubID</th><th>CategoryId</th><th>ModifiedDate</th><th>isdeleted</th></tr><tr><td>2</td><td>Анна</td><td>Высоцкая</td><td>2007</td><td>ж</td><td>3</td><td>4</td><td>2019-04-29 12:40:51.810</td><td>1</td></tr><tr><td>3</td><td>Илья</td><td>Гавриленко</td><td>2006</td><td>м</td><td>2</td><td>3</td><td>2019-04-29 12:40:51.810</td><td>0</td></tr><tr><td>4</td><td>Максим</td><td>Кликушин</td><td>2007</td><td>м</td><td>2</td><td>3</td><td>2019-04-29 12:40:51.810</td><td>0</td></tr><tr><td>5</td><td>Матвей</td><td>Данкевич</td><td>2006</td><td>м</td><td>4</td><td>2</td><td>2019-04-29 12:40:51.810</td><td>0</td></tr><tr><td>6</td><td>Никита</td><td>Клюй</td><td>2005</td><td>м</td><td>3</td><td>3</td><td>2019-04-29 12:40:51.810</td><td>0</td></tr><tr><td>9</td><td>Gleb</td><td>Bondarec</td><td>2007</td><td>м</td><td>2</td><td>NULL</td><td>2019-04-29 15:38:38.427</td><td>0</td></tr><tr><td>11</td><td>Алексей</td><td>Рылько</td><td>2005</td><td>м</td><td>3</td><td>NULL</td><td>2019-04-30 10:58:20.420</td><td>1</td></tr></table>"
                    }
                },
                {
                    "output_type": "execute_result",
                    "metadata": {},
                    "execution_count": 19,
                    "data": {
                        "application/vnd.dataresource+json": {
                            "schema": {
                                "fields": [
                                    {
                                        "name": "CategoryID"
                                    },
                                    {
                                        "name": "Name"
                                    },
                                    {
                                        "name": "ModifiedDate"
                                    }
                                ]
                            },
                            "data": [
                                {
                                    "0": "2",
                                    "1": "I",
                                    "2": "2019-04-29 12:40:51.767"
                                },
                                {
                                    "0": "3",
                                    "1": "II",
                                    "2": "2019-04-29 12:40:51.767"
                                },
                                {
                                    "0": "4",
                                    "1": "кмс",
                                    "2": "2019-04-29 12:40:51.767"
                                }
                            ]
                        },
                        "text/html": "<table><tr><th>CategoryID</th><th>Name</th><th>ModifiedDate</th></tr><tr><td>2</td><td>I</td><td>2019-04-29 12:40:51.767</td></tr><tr><td>3</td><td>II</td><td>2019-04-29 12:40:51.767</td></tr><tr><td>4</td><td>кмс</td><td>2019-04-29 12:40:51.767</td></tr></table>"
                    }
                }
            ],
            "execution_count": 19
        },
        {
            "cell_type": "markdown",
            "source": "<b>Пример #1</b>. Найти всех спортсменов из клуба Янтарь, имеющих II спортивный разряд.\r\n\r\nИспользуя старую нотацию:",
            "metadata": {}
        },
        {
            "cell_type": "code",
            "source": "use tempdb\r\ngo\r\n\r\nselect s.SwimmerID, s.FirstName, s.LastName, s.YearOfBirth, s.Gender, \r\n       sc.[Name] Club, sc.City, c.[Name] Category\r\nfrom dbo.SwimmingClub sc, dbo.Swimmer s, dbo.Category c\r\nwhere sc.[Name] like N'%Янтарь%' \r\n      and sc.SwimmingClubID = s.SwimmingClubID\r\n      and s.CategoryID     = c.CategoryID\r\n      and c.[Name]         = N'II'",
            "metadata": {},
            "outputs": [
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Commands completed successfully."
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.0012785"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "(1 row affected)"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.0048865"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "execute_result",
                    "metadata": {},
                    "execution_count": 20,
                    "data": {
                        "application/vnd.dataresource+json": {
                            "schema": {
                                "fields": [
                                    {
                                        "name": "SwimmerID"
                                    },
                                    {
                                        "name": "FirstName"
                                    },
                                    {
                                        "name": "LastName"
                                    },
                                    {
                                        "name": "YearOfBirth"
                                    },
                                    {
                                        "name": "Gender"
                                    },
                                    {
                                        "name": "Club"
                                    },
                                    {
                                        "name": "City"
                                    },
                                    {
                                        "name": "Category"
                                    }
                                ]
                            },
                            "data": [
                                {
                                    "0": "6",
                                    "1": "Никита",
                                    "2": "Клюй",
                                    "3": "2005",
                                    "4": "м",
                                    "5": "ДЮСШ Янтарь",
                                    "6": "Minsk",
                                    "7": "II"
                                }
                            ]
                        },
                        "text/html": "<table><tr><th>SwimmerID</th><th>FirstName</th><th>LastName</th><th>YearOfBirth</th><th>Gender</th><th>Club</th><th>City</th><th>Category</th></tr><tr><td>6</td><td>Никита</td><td>Клюй</td><td>2005</td><td>м</td><td>ДЮСШ Янтарь</td><td>Minsk</td><td>II</td></tr></table>"
                    }
                }
            ],
            "execution_count": 20
        },
        {
            "cell_type": "markdown",
            "source": "Используя новую нотацию:",
            "metadata": {}
        },
        {
            "cell_type": "code",
            "source": "use tempdb\r\ngo\r\n\r\nselect s.SwimmerID, s.FirstName, s.LastName, s.YearOfBirth, s.Gender, \r\n       sc.[Name] Club, sc.City, c.[Name] Category\r\nfrom dbo.SwimmingClub sc\r\ninner join dbo.Swimmer s  on s.SwimmingClubID = sc.SwimmingClubID\r\ninner join dbo.Category c on s.CategoryID     = c.CategoryID\r\nwhere sc.[Name] like N'%Янтарь%' and c.[Name] = N'II'",
            "metadata": {},
            "outputs": [
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Commands completed successfully."
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.0020676"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "(1 row affected)"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.0045204"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "execute_result",
                    "metadata": {},
                    "execution_count": 21,
                    "data": {
                        "application/vnd.dataresource+json": {
                            "schema": {
                                "fields": [
                                    {
                                        "name": "SwimmerID"
                                    },
                                    {
                                        "name": "FirstName"
                                    },
                                    {
                                        "name": "LastName"
                                    },
                                    {
                                        "name": "YearOfBirth"
                                    },
                                    {
                                        "name": "Gender"
                                    },
                                    {
                                        "name": "Club"
                                    },
                                    {
                                        "name": "City"
                                    },
                                    {
                                        "name": "Category"
                                    }
                                ]
                            },
                            "data": [
                                {
                                    "0": "6",
                                    "1": "Никита",
                                    "2": "Клюй",
                                    "3": "2005",
                                    "4": "м",
                                    "5": "ДЮСШ Янтарь",
                                    "6": "Minsk",
                                    "7": "II"
                                }
                            ]
                        },
                        "text/html": "<table><tr><th>SwimmerID</th><th>FirstName</th><th>LastName</th><th>YearOfBirth</th><th>Gender</th><th>Club</th><th>City</th><th>Category</th></tr><tr><td>6</td><td>Никита</td><td>Клюй</td><td>2005</td><td>м</td><td>ДЮСШ Янтарь</td><td>Minsk</td><td>II</td></tr></table>"
                    }
                }
            ],
            "execution_count": 21
        },
        {
            "cell_type": "markdown",
            "source": "Используя CROSS JOIN:",
            "metadata": {}
        },
        {
            "cell_type": "code",
            "source": "use tempdb\r\ngo\r\n\r\nselect s.SwimmerID, s.FirstName, s.LastName, s.YearOfBirth, s.Gender, \r\n       sc.[Name] Club, sc.City, c.[Name] Category\r\nfrom dbo.SwimmingClub sc\r\ncross join dbo.Swimmer s\r\ncross join dbo.Category c\r\nwhere sc.[Name] like N'%Янтарь%' \r\n      and sc.SwimmingClubID = s.SwimmingClubID\r\n      and s.CategoryID     = c.CategoryID\r\n      and c.[Name]         = N'II'",
            "metadata": {},
            "outputs": [
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Commands completed successfully."
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.0013390"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "(1 row affected)"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.0101498"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "execute_result",
                    "metadata": {},
                    "execution_count": 30,
                    "data": {
                        "application/vnd.dataresource+json": {
                            "schema": {
                                "fields": [
                                    {
                                        "name": "SwimmerID"
                                    },
                                    {
                                        "name": "FirstName"
                                    },
                                    {
                                        "name": "LastName"
                                    },
                                    {
                                        "name": "YearOfBirth"
                                    },
                                    {
                                        "name": "Gender"
                                    },
                                    {
                                        "name": "Club"
                                    },
                                    {
                                        "name": "City"
                                    },
                                    {
                                        "name": "Category"
                                    }
                                ]
                            },
                            "data": [
                                {
                                    "0": "6",
                                    "1": "Никита",
                                    "2": "Клюй",
                                    "3": "2005",
                                    "4": "м",
                                    "5": "ДЮСШ Янтарь",
                                    "6": "Minsk",
                                    "7": "II"
                                }
                            ]
                        },
                        "text/html": "<table><tr><th>SwimmerID</th><th>FirstName</th><th>LastName</th><th>YearOfBirth</th><th>Gender</th><th>Club</th><th>City</th><th>Category</th></tr><tr><td>6</td><td>Никита</td><td>Клюй</td><td>2005</td><td>м</td><td>ДЮСШ Янтарь</td><td>Minsk</td><td>II</td></tr></table>"
                    }
                }
            ],
            "execution_count": 30
        },
        {
            "cell_type": "markdown",
            "source": "Вообще, вариантов решения задачи много. Но не все они оптимальны;)\r\n\r\nНапример, порой начинающие программисты для решения первой задачи создают что-то вроде этого:",
            "metadata": {}
        },
        {
            "cell_type": "code",
            "source": "use tempdb\r\ngo\r\n\r\ndeclare @ClubId     int,\r\n        @ClubCity   nvarchar(30), \r\n        @ClubName   nvarchar(100),\r\n        @CategoryId int\r\n\r\nset @ClubId = (select SwimmingClubId from dbo.SwimmingClub where [Name] like N'%Янтарь%')\r\n\r\nset @ClubCity = (select City from dbo.SwimmingClub where [Name] like N'%Янтарь%')\r\nset @ClubName = (select [Name] from dbo.SwimmingClub where [Name] like N'%Янтарь%')\r\n\r\nset @CategoryId = (select CategoryId from dbo.Category where [Name] = N'II')\r\n\r\nselect SwimmerID, FirstName, LastName, YearOfBirth, Gender, \r\n       @ClubName Club, @ClubCity City, N'II' Category\r\nfrom dbo.Swimmer \r\nwhere SwimmingClubID = @ClubId and CategoryId = @CategoryId\r\n",
            "metadata": {},
            "outputs": [
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Commands completed successfully."
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.0011336"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "(1 row affected)"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.0046176"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "execute_result",
                    "metadata": {},
                    "execution_count": 33,
                    "data": {
                        "application/vnd.dataresource+json": {
                            "schema": {
                                "fields": [
                                    {
                                        "name": "SwimmerID"
                                    },
                                    {
                                        "name": "FirstName"
                                    },
                                    {
                                        "name": "LastName"
                                    },
                                    {
                                        "name": "YearOfBirth"
                                    },
                                    {
                                        "name": "Gender"
                                    },
                                    {
                                        "name": "Club"
                                    },
                                    {
                                        "name": "City"
                                    },
                                    {
                                        "name": "Category"
                                    }
                                ]
                            },
                            "data": [
                                {
                                    "0": "6",
                                    "1": "Никита",
                                    "2": "Клюй",
                                    "3": "2005",
                                    "4": "м",
                                    "5": "ДЮСШ Янтарь",
                                    "6": "Minsk",
                                    "7": "II"
                                }
                            ]
                        },
                        "text/html": "<table><tr><th>SwimmerID</th><th>FirstName</th><th>LastName</th><th>YearOfBirth</th><th>Gender</th><th>Club</th><th>City</th><th>Category</th></tr><tr><td>6</td><td>Никита</td><td>Клюй</td><td>2005</td><td>м</td><td>ДЮСШ Янтарь</td><td>Minsk</td><td>II</td></tr></table>"
                    }
                }
            ],
            "execution_count": 33
        },
        {
            "cell_type": "markdown",
            "source": "<b>Пример #2.</b> Вывести спортсменов из клуба Янтарь с теми же атрибутами что и выше, но без требования иметь II спортивный разряд.\r\n\r\nИспользуя старую нотацию:",
            "metadata": {}
        },
        {
            "cell_type": "code",
            "source": "use tempdb\r\ngo\r\n\r\n--это код с багом! в случае если у спортсмена нет разряда, запись о нем не выводится\r\nselect s.SwimmerID, s.FirstName, s.LastName, s.YearOfBirth, s.Gender, \r\n       sc.[Name] Club, sc.City, c.[Name] Category\r\nfrom dbo.SwimmingClub sc, dbo.Swimmer s, dbo.Category c\r\nwhere sc.[Name] like N'%Янтарь%' \r\n      and sc.SwimmingClubID = s.SwimmingClubID\r\n      and s.CategoryID     = c.CategoryID      \r\n\r\n--подправленный код\r\nselect s.SwimmerID, s.FirstName, s.LastName, s.YearOfBirth, s.Gender, \r\n       sc.[Name] Club, sc.City, \r\n       (select c.[Name] from dbo.Category c where c.CategoryID = s.CategoryID) Category\r\nfrom dbo.SwimmingClub sc, dbo.Swimmer s\r\nwhere sc.[Name] like N'%Янтарь%' \r\n      and sc.SwimmingClubID = s.SwimmingClubID         \r\n",
            "metadata": {},
            "outputs": [
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Commands completed successfully."
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.0009234"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "(2 rows affected)"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "(3 rows affected)"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.0084284"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "execute_result",
                    "metadata": {},
                    "execution_count": 23,
                    "data": {
                        "application/vnd.dataresource+json": {
                            "schema": {
                                "fields": [
                                    {
                                        "name": "SwimmerID"
                                    },
                                    {
                                        "name": "FirstName"
                                    },
                                    {
                                        "name": "LastName"
                                    },
                                    {
                                        "name": "YearOfBirth"
                                    },
                                    {
                                        "name": "Gender"
                                    },
                                    {
                                        "name": "Club"
                                    },
                                    {
                                        "name": "City"
                                    },
                                    {
                                        "name": "Category"
                                    }
                                ]
                            },
                            "data": [
                                {
                                    "0": "2",
                                    "1": "Анна",
                                    "2": "Высоцкая",
                                    "3": "2007",
                                    "4": "ж",
                                    "5": "ДЮСШ Янтарь",
                                    "6": "Minsk",
                                    "7": "кмс"
                                },
                                {
                                    "0": "6",
                                    "1": "Никита",
                                    "2": "Клюй",
                                    "3": "2005",
                                    "4": "м",
                                    "5": "ДЮСШ Янтарь",
                                    "6": "Minsk",
                                    "7": "II"
                                }
                            ]
                        },
                        "text/html": "<table><tr><th>SwimmerID</th><th>FirstName</th><th>LastName</th><th>YearOfBirth</th><th>Gender</th><th>Club</th><th>City</th><th>Category</th></tr><tr><td>2</td><td>Анна</td><td>Высоцкая</td><td>2007</td><td>ж</td><td>ДЮСШ Янтарь</td><td>Minsk</td><td>кмс</td></tr><tr><td>6</td><td>Никита</td><td>Клюй</td><td>2005</td><td>м</td><td>ДЮСШ Янтарь</td><td>Minsk</td><td>II</td></tr></table>"
                    }
                },
                {
                    "output_type": "execute_result",
                    "metadata": {},
                    "execution_count": 23,
                    "data": {
                        "application/vnd.dataresource+json": {
                            "schema": {
                                "fields": [
                                    {
                                        "name": "SwimmerID"
                                    },
                                    {
                                        "name": "FirstName"
                                    },
                                    {
                                        "name": "LastName"
                                    },
                                    {
                                        "name": "YearOfBirth"
                                    },
                                    {
                                        "name": "Gender"
                                    },
                                    {
                                        "name": "Club"
                                    },
                                    {
                                        "name": "City"
                                    },
                                    {
                                        "name": "Category"
                                    }
                                ]
                            },
                            "data": [
                                {
                                    "0": "2",
                                    "1": "Анна",
                                    "2": "Высоцкая",
                                    "3": "2007",
                                    "4": "ж",
                                    "5": "ДЮСШ Янтарь",
                                    "6": "Minsk",
                                    "7": "кмс"
                                },
                                {
                                    "0": "6",
                                    "1": "Никита",
                                    "2": "Клюй",
                                    "3": "2005",
                                    "4": "м",
                                    "5": "ДЮСШ Янтарь",
                                    "6": "Minsk",
                                    "7": "II"
                                },
                                {
                                    "0": "11",
                                    "1": "Алексей",
                                    "2": "Рылько",
                                    "3": "2005",
                                    "4": "м",
                                    "5": "ДЮСШ Янтарь",
                                    "6": "Minsk",
                                    "7": "NULL"
                                }
                            ]
                        },
                        "text/html": "<table><tr><th>SwimmerID</th><th>FirstName</th><th>LastName</th><th>YearOfBirth</th><th>Gender</th><th>Club</th><th>City</th><th>Category</th></tr><tr><td>2</td><td>Анна</td><td>Высоцкая</td><td>2007</td><td>ж</td><td>ДЮСШ Янтарь</td><td>Minsk</td><td>кмс</td></tr><tr><td>6</td><td>Никита</td><td>Клюй</td><td>2005</td><td>м</td><td>ДЮСШ Янтарь</td><td>Minsk</td><td>II</td></tr><tr><td>11</td><td>Алексей</td><td>Рылько</td><td>2005</td><td>м</td><td>ДЮСШ Янтарь</td><td>Minsk</td><td>NULL</td></tr></table>"
                    }
                }
            ],
            "execution_count": 23
        },
        {
            "cell_type": "markdown",
            "source": "Используя новую нотацию:",
            "metadata": {}
        },
        {
            "cell_type": "code",
            "source": "use tempdb\r\ngo\r\n\r\nselect s.SwimmerID, s.FirstName, s.LastName, s.YearOfBirth, s.Gender, \r\n       sc.[Name] Club, sc.City, c.[Name] Category\r\nfrom dbo.SwimmingClub sc\r\ninner join dbo.Swimmer s  on s.SwimmingClubID = sc.SwimmingClubID\r\nleft join dbo.Category c on s.CategoryID     = c.CategoryID\r\nwhere sc.[Name] like N'%Янтарь%' ",
            "metadata": {},
            "outputs": [
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Commands completed successfully."
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.0013412"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "(3 rows affected)"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.0090951"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "execute_result",
                    "metadata": {},
                    "execution_count": 24,
                    "data": {
                        "application/vnd.dataresource+json": {
                            "schema": {
                                "fields": [
                                    {
                                        "name": "SwimmerID"
                                    },
                                    {
                                        "name": "FirstName"
                                    },
                                    {
                                        "name": "LastName"
                                    },
                                    {
                                        "name": "YearOfBirth"
                                    },
                                    {
                                        "name": "Gender"
                                    },
                                    {
                                        "name": "Club"
                                    },
                                    {
                                        "name": "City"
                                    },
                                    {
                                        "name": "Category"
                                    }
                                ]
                            },
                            "data": [
                                {
                                    "0": "2",
                                    "1": "Анна",
                                    "2": "Высоцкая",
                                    "3": "2007",
                                    "4": "ж",
                                    "5": "ДЮСШ Янтарь",
                                    "6": "Minsk",
                                    "7": "кмс"
                                },
                                {
                                    "0": "6",
                                    "1": "Никита",
                                    "2": "Клюй",
                                    "3": "2005",
                                    "4": "м",
                                    "5": "ДЮСШ Янтарь",
                                    "6": "Minsk",
                                    "7": "II"
                                },
                                {
                                    "0": "11",
                                    "1": "Алексей",
                                    "2": "Рылько",
                                    "3": "2005",
                                    "4": "м",
                                    "5": "ДЮСШ Янтарь",
                                    "6": "Minsk",
                                    "7": "NULL"
                                }
                            ]
                        },
                        "text/html": "<table><tr><th>SwimmerID</th><th>FirstName</th><th>LastName</th><th>YearOfBirth</th><th>Gender</th><th>Club</th><th>City</th><th>Category</th></tr><tr><td>2</td><td>Анна</td><td>Высоцкая</td><td>2007</td><td>ж</td><td>ДЮСШ Янтарь</td><td>Minsk</td><td>кмс</td></tr><tr><td>6</td><td>Никита</td><td>Клюй</td><td>2005</td><td>м</td><td>ДЮСШ Янтарь</td><td>Minsk</td><td>II</td></tr><tr><td>11</td><td>Алексей</td><td>Рылько</td><td>2005</td><td>м</td><td>ДЮСШ Янтарь</td><td>Minsk</td><td>NULL</td></tr></table>"
                    }
                }
            ],
            "execution_count": 24
        },
        {
            "cell_type": "markdown",
            "source": "Вариант решения задачи с outer apply:",
            "metadata": {}
        },
        {
            "cell_type": "code",
            "source": "use tempdb\r\ngo\r\n\r\nselect s.SwimmerID, s.FirstName, s.LastName, s.YearOfBirth, s.Gender, \r\n       sc.[Name] Club, sc.City, c.[Name] Category\r\nfrom dbo.SwimmingClub sc\r\ninner join dbo.Swimmer s  on s.SwimmingClubID = sc.SwimmingClubID\r\nouter apply (select [Name] from dbo.Category c where c.CategoryID = s.CategoryId) c \r\nwhere sc.[Name] like N'%Янтарь%' ",
            "metadata": {},
            "outputs": [
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Commands completed successfully."
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.0016745"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "(3 rows affected)"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.0052674"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "execute_result",
                    "metadata": {},
                    "execution_count": 27,
                    "data": {
                        "application/vnd.dataresource+json": {
                            "schema": {
                                "fields": [
                                    {
                                        "name": "SwimmerID"
                                    },
                                    {
                                        "name": "FirstName"
                                    },
                                    {
                                        "name": "LastName"
                                    },
                                    {
                                        "name": "YearOfBirth"
                                    },
                                    {
                                        "name": "Gender"
                                    },
                                    {
                                        "name": "Club"
                                    },
                                    {
                                        "name": "City"
                                    },
                                    {
                                        "name": "Category"
                                    }
                                ]
                            },
                            "data": [
                                {
                                    "0": "2",
                                    "1": "Анна",
                                    "2": "Высоцкая",
                                    "3": "2007",
                                    "4": "ж",
                                    "5": "ДЮСШ Янтарь",
                                    "6": "Minsk",
                                    "7": "кмс"
                                },
                                {
                                    "0": "6",
                                    "1": "Никита",
                                    "2": "Клюй",
                                    "3": "2005",
                                    "4": "м",
                                    "5": "ДЮСШ Янтарь",
                                    "6": "Minsk",
                                    "7": "II"
                                },
                                {
                                    "0": "11",
                                    "1": "Алексей",
                                    "2": "Рылько",
                                    "3": "2005",
                                    "4": "м",
                                    "5": "ДЮСШ Янтарь",
                                    "6": "Minsk",
                                    "7": "NULL"
                                }
                            ]
                        },
                        "text/html": "<table><tr><th>SwimmerID</th><th>FirstName</th><th>LastName</th><th>YearOfBirth</th><th>Gender</th><th>Club</th><th>City</th><th>Category</th></tr><tr><td>2</td><td>Анна</td><td>Высоцкая</td><td>2007</td><td>ж</td><td>ДЮСШ Янтарь</td><td>Minsk</td><td>кмс</td></tr><tr><td>6</td><td>Никита</td><td>Клюй</td><td>2005</td><td>м</td><td>ДЮСШ Янтарь</td><td>Minsk</td><td>II</td></tr><tr><td>11</td><td>Алексей</td><td>Рылько</td><td>2005</td><td>м</td><td>ДЮСШ Янтарь</td><td>Minsk</td><td>NULL</td></tr></table>"
                    }
                }
            ],
            "execution_count": 27
        },
        {
            "cell_type": "markdown",
            "source": "Вариант решения задачи с пользовательской скалярной функцией:",
            "metadata": {}
        },
        {
            "cell_type": "code",
            "source": "use tempdb\r\ngo\r\n\r\ncreate or alter function dbo.fn_GetCategoryName(@CategoryID int) returns nvarchar\r\nas\r\nbegin\r\n  return (select [Name] from dbo.Category where CategoryId = @CategoryID)\r\nend\r\ngo\r\n\r\nselect s.SwimmerID, s.FirstName, s.LastName, s.YearOfBirth, s.Gender, \r\n       sc.[Name] Club, sc.City, dbo.fn_GetCategoryName(s.CategoryId) Category\r\nfrom dbo.SwimmingClub sc\r\ninner join dbo.Swimmer s  on s.SwimmingClubID = sc.SwimmingClubID\r\nwhere sc.[Name] like N'%Янтарь%' \r\n",
            "metadata": {},
            "outputs": [
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Commands completed successfully."
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.0013008"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Commands completed successfully."
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.0033548"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "(3 rows affected)"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.0265345"
                    },
                    "metadata": {}
                },
                {
                    "output_type": "execute_result",
                    "metadata": {},
                    "execution_count": 29,
                    "data": {
                        "application/vnd.dataresource+json": {
                            "schema": {
                                "fields": [
                                    {
                                        "name": "SwimmerID"
                                    },
                                    {
                                        "name": "FirstName"
                                    },
                                    {
                                        "name": "LastName"
                                    },
                                    {
                                        "name": "YearOfBirth"
                                    },
                                    {
                                        "name": "Gender"
                                    },
                                    {
                                        "name": "Club"
                                    },
                                    {
                                        "name": "City"
                                    },
                                    {
                                        "name": "Category"
                                    }
                                ]
                            },
                            "data": [
                                {
                                    "0": "2",
                                    "1": "Анна",
                                    "2": "Высоцкая",
                                    "3": "2007",
                                    "4": "ж",
                                    "5": "ДЮСШ Янтарь",
                                    "6": "Minsk",
                                    "7": "к"
                                },
                                {
                                    "0": "6",
                                    "1": "Никита",
                                    "2": "Клюй",
                                    "3": "2005",
                                    "4": "м",
                                    "5": "ДЮСШ Янтарь",
                                    "6": "Minsk",
                                    "7": "I"
                                },
                                {
                                    "0": "11",
                                    "1": "Алексей",
                                    "2": "Рылько",
                                    "3": "2005",
                                    "4": "м",
                                    "5": "ДЮСШ Янтарь",
                                    "6": "Minsk",
                                    "7": "NULL"
                                }
                            ]
                        },
                        "text/html": "<table><tr><th>SwimmerID</th><th>FirstName</th><th>LastName</th><th>YearOfBirth</th><th>Gender</th><th>Club</th><th>City</th><th>Category</th></tr><tr><td>2</td><td>Анна</td><td>Высоцкая</td><td>2007</td><td>ж</td><td>ДЮСШ Янтарь</td><td>Minsk</td><td>к</td></tr><tr><td>6</td><td>Никита</td><td>Клюй</td><td>2005</td><td>м</td><td>ДЮСШ Янтарь</td><td>Minsk</td><td>I</td></tr><tr><td>11</td><td>Алексей</td><td>Рылько</td><td>2005</td><td>м</td><td>ДЮСШ Янтарь</td><td>Minsk</td><td>NULL</td></tr></table>"
                    }
                }
            ],
            "execution_count": 29
        },
        {
            "cell_type": "markdown",
            "source": "## Создавайте качественный код!",
            "metadata": {}
        }
    ]
}