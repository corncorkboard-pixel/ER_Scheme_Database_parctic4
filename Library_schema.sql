CREATE DATABASE library;
USE library;

CREATE TABLE publisher (
    publisher_id  INT GENERATED ALWAYS AS IDENTITY,
    name          VARCHAR(150) NOT NULL,
    city          VARCHAR(80),
    country       VARCHAR(80),
    CONSTRAINT pk_publisher PRIMARY KEY (publisher_id),
    CONSTRAINT ck_publisher_name CHECK (length(trim(name)) > 0)
);

CREATE TABLE author (
    author_id   INT GENERATED ALWAYS AS IDENTITY,
    last_name   VARCHAR(80) NOT NULL,
    first_name  VARCHAR(80) NOT NULL,
    birth_year  SMALLINT,
    country     VARCHAR(80),
    CONSTRAINT pk_author PRIMARY KEY (author_id),
    CONSTRAINT ck_author_birth_year CHECK (birth_year BETWEEN 1 AND 2100)
);

CREATE TABLE reader (
    reader_id    INT GENERATED ALWAYS AS IDENTITY,
    card_number  VARCHAR(10)  NOT NULL,
    full_name    VARCHAR(150) NOT NULL,
    email        VARCHAR(120),
    phone        VARCHAR(20),
    reg_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT pk_reader PRIMARY KEY (reader_id),
    CONSTRAINT uq_reader_card_number UNIQUE (card_number),
    CONSTRAINT uq_reader_email UNIQUE (email),
    CONSTRAINT ck_reader_email CHECK (email IS NULL OR email LIKE '%_@_%')
);

CREATE TABLE book (
    book_id       INT GENERATED ALWAYS AS IDENTITY,
    isbn          CHAR(13)     NOT NULL,
    title         VARCHAR(255) NOT NULL,
    publish_year  SMALLINT,
    pages         SMALLINT,
    copies_total  INT NOT NULL DEFAULT 1,
    publisher_id  INT NOT NULL,
    CONSTRAINT pk_book PRIMARY KEY (book_id),
    CONSTRAINT uq_book_isbn UNIQUE (isbn),
    CONSTRAINT ck_book_isbn CHECK (length(isbn) = 13),
    CONSTRAINT ck_book_year CHECK (publish_year BETWEEN 1400 AND 2100),
    CONSTRAINT ck_book_pages CHECK (pages > 0),
    CONSTRAINT ck_book_copies CHECK (copies_total >= 0),
    CONSTRAINT fk_book_publisher FOREIGN KEY (publisher_id)
        REFERENCES publisher (publisher_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE book_author (
    book_id       INT      NOT NULL,
    author_id     INT      NOT NULL,
    author_order  SMALLINT NOT NULL DEFAULT 1,
    CONSTRAINT pk_book_author PRIMARY KEY (book_id, author_id),
    CONSTRAINT uq_book_author_order UNIQUE (book_id, author_order),
    CONSTRAINT ck_book_author_order CHECK (author_order >= 1),
    CONSTRAINT fk_book_author_book FOREIGN KEY (book_id)
        REFERENCES book (book_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_book_author_author FOREIGN KEY (author_id)
        REFERENCES author (author_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE loan (
    loan_id      INT GENERATED ALWAYS AS IDENTITY,
    reader_id    INT  NOT NULL,
    book_id      INT  NOT NULL,
    issue_date   DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date     DATE NOT NULL,
    return_date  DATE,
    CONSTRAINT pk_loan PRIMARY KEY (loan_id),
    CONSTRAINT ck_loan_due CHECK (due_date >= issue_date),
    CONSTRAINT ck_loan_return CHECK (return_date IS NULL OR return_date >= issue_date),
    CONSTRAINT fk_loan_reader FOREIGN KEY (reader_id)
        REFERENCES reader (reader_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_loan_book FOREIGN KEY (book_id)
        REFERENCES book (book_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX ix_book_publisher     ON book (publisher_id);
CREATE INDEX ix_book_author_author ON book_author (author_id);
CREATE INDEX ix_loan_reader        ON loan (reader_id);
CREATE INDEX ix_loan_book          ON loan (book_id);
CREATE INDEX ix_loan_active        ON loan (book_id) WHERE return_date IS NULL;
