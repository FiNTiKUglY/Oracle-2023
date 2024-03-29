CREATE TABLE PERSONS
(
    ID NUMBER,
    NAME VARCHAR2(100),
    BIRTHDAY_DATE DATE,
    BOOKS_AMOUNT NUMBER,

    CONSTRAINT PERSON_ID PRIMARY KEY (ID)
);

CREATE TABLE PUBLISHERS
(
    ID NUMBER,
    NAME VARCHAR2(100),
    OPENING_DATE DATE,
    BOOKS_AMOUNT NUMBER,

    CONSTRAINT PUBLISHER_ID PRIMARY KEY (ID)
);

CREATE TABLE BOOKS
(
    ID NUMBER,
    TITLE VARCHAR2(100),
    RELEASE_DATE DATE,
    PUBLISHER_ID NUMBER,
    PERSON_ID NUMBER,

    CONSTRAINT BOOK_ID PRIMARY KEY (ID),
    CONSTRAINT FK_PUBLIHSER FOREIGN KEY (ID) REFERENCES PUBLISHERS(ID),
    CONSTRAINT FK_PERSON FOREIGN KEY (ID) REFERENCES PERSONS(ID)
);