CREATE OR REPLACE PROCEDURE DDL_PROCEDURES(procedure_name VARCHAR2, dev_schema_name VARCHAR2, prod_schema_name VARCHAR2) AS
    dev_procedure_text VARCHAR2(32767);
    arg_procedure VARCHAR2(32767);
    whole_text VARCHAR2(32767);
BEGIN
    whole_text := 'CREATE OR REPLACE PROCEDURE ' || prod_schema_name || '.' || procedure_name || '(';

    SELECT LISTAGG(CONCAT(CONCAT(ARGUMENT_NAME, ' '), DATA_TYPE), ', ')
    INTO arg_procedure
    FROM ALL_ARGUMENTS
    WHERE OWNER = dev_schema_name
        AND OBJECT_NAME = procedure_name
        AND POSITION <> 0;

    whole_text := CONCAT(whole_text, arg_procedure || ') AS' || chr(10));
    IF arg_procedure IS NULL THEN
        whole_text := REPLACE(whole_text, '()', '');
    END IF;

    SELECT LISTAGG(TEXT) INTO dev_procedure_text FROM ALL_SOURCE 
    WHERE OWNER = dev_schema_name
        AND TYPE = 'PROCEDURE'
        AND NAME = procedure_name
        AND line <> 1;

    dev_procedure_text := CONCAT(whole_text, dev_procedure_text);
    -- dbms_output.PUT_LINE(dev_procedure_text);
    EXECUTE IMMEDIATE dev_procedure_text;
END;
/

CREATE OR REPLACE PROCEDURE DDL_FUNCTIONS(function_name VARCHAR2, dev_schema_name VARCHAR2, prod_schema_name VARCHAR2) AS
    dev_function_text VARCHAR2(32767);
    type_return VARCHAR(50);
    arg_function VARCHAR2(32767);
    whole_text VARCHAR2(32767);
BEGIN
    whole_text := 'CREATE OR REPLACE FUNCTION ' || prod_schema_name || '.' || function_name || '(';

    SELECT LISTAGG(CONCAT(CONCAT(ARGUMENT_NAME, ' '), DATA_TYPE), ', ')
    INTO arg_function
    FROM ALL_ARGUMENTS
    WHERE OWNER = dev_schema_name
        AND OBJECT_NAME = function_name
        AND POSITION <> 0;

    SELECT DATA_TYPE
    INTO type_return
    FROM ALL_ARGUMENTS
    WHERE OWNER = dev_schema_name
        AND OBJECT_NAME = function_name
        AND POSITION = 0;
    
    whole_text := CONCAT(whole_text, arg_function || ') RETURN ' || type_return || ' AS' || chr(10));
    IF arg_function IS NULL THEN
        whole_text := REPLACE(whole_text, '()', '');
    END IF;

    SELECT LISTAGG(TEXT) INTO dev_function_text FROM ALL_SOURCE 
    WHERE OWNER = dev_schema_name
        AND TYPE = 'FUNCTION'
        AND NAME = function_name
        AND line <> 1;

    dev_function_text := CONCAT(whole_text, dev_function_text);
    -- dbms_output.PUT_LINE(dev_function_text);
    EXECUTE IMMEDIATE dev_function_text;
END;
/

CREATE OR REPLACE PROCEDURE DDL_PACKAGES(package_name VARCHAR2, dev_schema_name VARCHAR2, prod_schema_name VARCHAR2) AS
    dev_package_text VARCHAR2(32767);
    whole_text VARCHAR2(32767);
BEGIN
    whole_text := 'CREATE OR REPLACE PACKAGE ' || prod_schema_name || '.' || package_name || ' AS' || chr(10);

    SELECT LISTAGG(TEXT) INTO dev_package_text FROM ALL_SOURCE 
    WHERE OWNER = dev_schema_name
        AND TYPE = 'PACKAGE'
        AND NAME = package_name
        AND line <> 1;

    dev_package_text := CONCAT(whole_text, dev_package_text);
    -- dbms_output.PUT_LINE(dev_package_text);
    EXECUTE IMMEDIATE dev_package_text;
END;
/
