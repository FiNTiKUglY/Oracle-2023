CREATE OR REPLACE PROCEDURE COMP_PROCEDURES(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2) AS
    dev_procedure_text VARCHAR2(32767);
    prod_procedure_text VARCHAR2(32767);

    CURSOR dev_schema_procedures IS
        SELECT DISTINCT NAME FROM ALL_SOURCE
        WHERE OWNER = dev_schema_name
            AND TYPE = 'PROCEDURE';
BEGIN
    FOR dev_schema_procedure IN dev_schema_procedures
    LOOP
        SELECT LISTAGG(TEXT, '\n ') INTO dev_procedure_text FROM ALL_SOURCE 
        WHERE OWNER = dev_schema_name
            AND TYPE = 'PROCEDURE'
            AND NAME = dev_schema_procedure.NAME;

        SELECT LISTAGG(TEXT, '\n ') INTO prod_procedure_text FROM ALL_SOURCE 
        WHERE OWNER = prod_schema_name
            AND TYPE = 'PROCEDURE'
            AND NAME = dev_schema_procedure.NAME;

        IF dev_procedure_text <> prod_procedure_text OR prod_procedure_text IS NULL THEN
            dbms_output.put_line('PROCEDURE: ' || dev_schema_procedure.NAME);
        END IF;
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE COMP_FUNCTIONS(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2) AS
    dev_procedure_text VARCHAR2(32767);
    prod_procedure_text VARCHAR2(32767);

    CURSOR dev_schema_procedures IS
        SELECT DISTINCT NAME FROM ALL_SOURCE
        WHERE OWNER = dev_schema_name
            AND TYPE = 'FUNCTION';
BEGIN
    FOR dev_schema_procedure IN dev_schema_procedures
    LOOP
        SELECT LISTAGG(TEXT, '\n ') INTO dev_procedure_text FROM ALL_SOURCE 
        WHERE OWNER = dev_schema_name
            AND TYPE = 'FUNCTION'
            AND NAME = dev_schema_procedure.NAME;

        SELECT LISTAGG(TEXT, '\n ') INTO prod_procedure_text FROM ALL_SOURCE 
        WHERE OWNER = prod_schema_name
            AND TYPE = 'FUNCTION'
            AND NAME = dev_schema_procedure.NAME;

        IF dev_procedure_text <> prod_procedure_text OR prod_procedure_text IS NULL THEN
            dbms_output.put_line('FUNCTION: ' || dev_schema_procedure.NAME);
        END IF;
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE COMP_PACKAGES(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2) AS
    dev_procedure_text VARCHAR2(32767);
    prod_procedure_text VARCHAR2(32767);

    CURSOR dev_schema_procedures IS
        SELECT DISTINCT NAME FROM ALL_SOURCE
        WHERE OWNER = dev_schema_name
            AND TYPE = 'PACKAGE';
BEGIN
    FOR dev_schema_procedure IN dev_schema_procedures
    LOOP
        SELECT LISTAGG(TEXT, '\n ') INTO dev_procedure_text FROM ALL_SOURCE 
        WHERE OWNER = dev_schema_name
            AND TYPE = 'PACKAGE'
            AND NAME = dev_schema_procedure.NAME;

        SELECT LISTAGG(TEXT, '\n ') INTO prod_procedure_text FROM ALL_SOURCE 
        WHERE OWNER = prod_schema_name
            AND TYPE = 'PACKAGE'
            AND NAME = dev_schema_procedure.NAME;

        IF dev_procedure_text <> prod_procedure_text OR prod_procedure_text IS NULL THEN
            dbms_output.put_line('PACKAGE: ' || dev_schema_procedure.NAME);
        END IF;
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE COMP_INDEXES(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2) AS
    amount_index NUMBER;

    CURSOR dev_schema_indexes IS
        SELECT * FROM ALL_INDEXES
        WHERE OWNER = dev_schema_name;
BEGIN
    FOR dev_schema_index IN dev_schema_indexes
    LOOP
        SELECT COUNT(*) INTO amount_index FROM
        (
            (SELECT TABLE_NAME, INDEX_TYPE, UNIQUENESS
            FROM ALL_INDEXES
            WHERE OWNER = dev_schema_name AND INDEX_NAME = dev_schema_index.INDEX_NAME
                AND NOT REGEXP_LIKE (INDEX_NAME, '^SYS_|^BIN_')
            MINUS
            SELECT TABLE_NAME, INDEX_TYPE, UNIQUENESS
            FROM ALL_INDEXES
            WHERE OWNER = prod_schema_name AND INDEX_NAME = dev_schema_index.INDEX_NAME
                AND NOT REGEXP_LIKE (INDEX_NAME, '^SYS_|^BIN_'))
            UNION
            (SELECT TABLE_NAME, INDEX_TYPE, UNIQUENESS
            FROM ALL_INDEXES
            WHERE OWNER = prod_schema_name AND INDEX_NAME = dev_schema_index.INDEX_NAME
                AND NOT REGEXP_LIKE (INDEX_NAME, '^SYS_|^BIN_')
            MINUS
            SELECT TABLE_NAME, INDEX_TYPE, UNIQUENESS
            FROM ALL_INDEXES
            WHERE OWNER = dev_schema_name AND INDEX_NAME = dev_schema_index.INDEX_NAME
                AND NOT REGEXP_LIKE (INDEX_NAME, '^SYS_|^BIN_'))
        );

        IF amount_index <> 0 THEN
            dbms_output.put_line('INDEX: ' || dev_schema_index.INDEX_NAME);
        END IF;
    END LOOP;
END;
/
