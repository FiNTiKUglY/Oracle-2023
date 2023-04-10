CREATE OR REPLACE PROCEDURE COMP_TABLES(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2) AS
    amount_tab NUMBER;
    amount_cons NUMBER;

    CURSOR dev_schema_tables IS
        SELECT * FROM ALL_TABLES
        WHERE OWNER = dev_schema_name;
BEGIN
    FOR dev_schema_table IN dev_schema_tables
    LOOP
        SELECT COUNT(*) INTO amount_tab FROM
        (
            (SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, NULLABLE
            FROM ALL_TAB_COLUMNS
            WHERE OWNER = dev_schema_name AND TABLE_NAME = dev_schema_table.TABLE_NAME
            MINUS
            SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, NULLABLE
            FROM ALL_TAB_COLUMNS
            WHERE OWNER = prod_schema_name AND TABLE_NAME = dev_schema_table.TABLE_NAME)
            UNION
            (SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, NULLABLE
            FROM ALL_TAB_COLUMNS
            WHERE OWNER = prod_schema_name AND TABLE_NAME = dev_schema_table.TABLE_NAME
            MINUS
            SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, NULLABLE
            FROM ALL_TAB_COLUMNS
            WHERE OWNER = dev_schema_name AND TABLE_NAME = dev_schema_table.TABLE_NAME)
        );

        SELECT COUNT(*) INTO amount_cons FROM
        (
            (SELECT ALL_CONS_COLUMNS.COLUMN_NAME, ALL_CONS_COLUMNS.CONSTRAINT_NAME, 
                    ALL_CONSTRAINTS.CONSTRAINT_TYPE
            FROM ALL_CONS_COLUMNS
            JOIN ALL_CONSTRAINTS
            ON ALL_CONSTRAINTS.TABLE_NAME = ALL_CONS_COLUMNS.TABLE_NAME
            WHERE ALL_CONSTRAINTS.OWNER = dev_schema_name 
                AND NOT REGEXP_LIKE (ALL_CONS_COLUMNS.CONSTRAINT_NAME, '^SYS_|^BIN_')
                AND ALL_CONS_COLUMNS.TABLE_NAME = dev_schema_table.TABLE_NAME
            MINUS
            SELECT ALL_CONS_COLUMNS.COLUMN_NAME, ALL_CONS_COLUMNS.CONSTRAINT_NAME, 
                    ALL_CONSTRAINTS.CONSTRAINT_TYPE
            FROM ALL_CONS_COLUMNS
            JOIN ALL_CONSTRAINTS
            ON ALL_CONSTRAINTS.TABLE_NAME = ALL_CONS_COLUMNS.TABLE_NAME
            WHERE ALL_CONSTRAINTS.OWNER = prod_schema_name
                AND NOT REGEXP_LIKE (ALL_CONS_COLUMNS.CONSTRAINT_NAME, '^SYS_|^BIN_')
                AND ALL_CONS_COLUMNS.TABLE_NAME = dev_schema_table.TABLE_NAME)
            UNION ALL
            (SELECT ALL_CONS_COLUMNS.COLUMN_NAME, ALL_CONS_COLUMNS.CONSTRAINT_NAME, 
                    ALL_CONSTRAINTS.CONSTRAINT_TYPE
            FROM ALL_CONS_COLUMNS
            JOIN ALL_CONSTRAINTS
            ON ALL_CONSTRAINTS.TABLE_NAME = ALL_CONS_COLUMNS.TABLE_NAME
            WHERE ALL_CONSTRAINTS.OWNER = prod_schema_name
                AND NOT REGEXP_LIKE (ALL_CONS_COLUMNS.CONSTRAINT_NAME, '^SYS_|^BIN_')
                AND ALL_CONS_COLUMNS.TABLE_NAME = dev_schema_table.TABLE_NAME
            MINUS
            SELECT ALL_CONS_COLUMNS.COLUMN_NAME, ALL_CONS_COLUMNS.CONSTRAINT_NAME, 
                    ALL_CONSTRAINTS.CONSTRAINT_TYPE
            FROM ALL_CONS_COLUMNS
            JOIN ALL_CONSTRAINTS
            ON ALL_CONSTRAINTS.TABLE_NAME = ALL_CONS_COLUMNS.TABLE_NAME
            WHERE ALL_CONSTRAINTS.OWNER = dev_schema_name 
                AND NOT REGEXP_LIKE (ALL_CONS_COLUMNS.CONSTRAINT_NAME, '^SYS_|^BIN_')
                AND ALL_CONS_COLUMNS.TABLE_NAME = dev_schema_table.TABLE_NAME)
        );

        IF amount_tab <> 0 OR amount_cons <> 0 THEN
            dbms_output.put_line('TABLE: ' || dev_schema_table.TABLE_NAME);
            DDL_TABLES(dev_schema_table.TABLE_NAME, dev_schema_name, prod_schema_name);
        END IF;
    END LOOP;
END;
/

