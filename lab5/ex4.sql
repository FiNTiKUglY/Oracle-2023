CREATE OR REPLACE PROCEDURE MAKE_REPORT(begin_time TIMESTAMP) is
    CURSOR ct1 IS
        SELECT *
        FROM LOGS_PERSON
        WHERE TIME >= begin_time
        ORDER BY TIME;

    CURSOR ct2 IS
        SELECT *
        FROM LOGS_PUBLISHER
        WHERE TIME >= begin_time
        ORDER BY TIME;

    CURSOR ct3 IS
        SELECT *
        FROM LOGS_BOOK
        WHERE TIME >= begin_time
        ORDER BY TIME;
    result CLOB;
BEGIN
    result := '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Report</title>
</head>
<body>';

    result := result || '<h1>' || 'COMPANIES' || '</h1>';
    result := result || '<table>
        <tr>
            <th>Action</ht>
            <th>Time</th>
            <th>ID</th>
            <th>Old name</th>
            <th>Old birthday_date</th>
            <th>Old books_amount</th>
            <th>New name</th>
            <th>New birthday_date</th>
            <th>New books_amount</th>
        </tr>';

    FOR record IN ct1
    LOOP
        result := result || '<tr>
            <td>' || record.ACTION || '</td>
            <td>' || record.TIME || '</td>
            <td>' || record.PERSON_ID || '</td>
            <td>' || record.OLD_PERSON_NAME || '</td>
            <td>' || record.OLD_PERSON_BIRTHDAY || '</td>
            <td>' || record.OLD_PERSON_AMOUNT || '</td>
            <td>' || record.NEW_PERSON_NAME || '</td>
            <td>' || record.NEW_PERSON_BIRTHDAY || '</td>
            <td>' || record.NEW_PERSON_AMOUNT || '</td>
        </tr>';
    end loop;

    result := result || '</table>';

    result := result || '<h1>' || 'PERSONS' || '</h1>';
    result := result || '<table>
        <tr>
            <th>Action</ht>
            <th>Time</th>
            <th>ID</th>
            <th>Old name</th>
            <th>Old opening_date</th>
            <th>Old books_amount</th>
            <th>New name</th>
            <th>New opening_date</th>
            <th>New books_amount</th>
        </tr>';

    for record in ct2
    loop
        result := result || '<tr>
            <td>' || record.ACTION || '</td>
            <td>' || record.TIME || '</td>
            <td>' || record.PUBLISHER_ID || '</td>
            <td>' || record.OLD_PUBLISHER_NAME || '</td>
            <td>' || record.OLD_PUBLISHER_OPENING || '</td>
            <td>' || record.OLD_PUBLISHER_AMOUNT || '</td>
            <td>' || record.NEW_PUBLISHER_NAME || '</td>
            <td>' || record.NEW_PUBLISHER_OPENING || '</td>
            <td>' || record.NEW_PUBLISHER_AMOUNT || '</td>
        </tr>';
    end loop;

    result := result || '</table>';

    result := result || '<h1>' || 'CARS' || '</h1>';
    result := result || '<table>
        <tr>
            <th>Action</ht>
            <th>Time</th>
            <th>ID</th>
            <th>Old name</th>
            <th>Old release_date</th>
            <th>Old person_id</th>
            <th>Old publisher_id</th>
            <th>New name</th>
            <th>New release_date</th>
            <th>New person_id</th>
            <th>New publisher_id</th>
        </tr>';

    for record in ct3
    loop
        result := result || '<tr>
            <td>' || record.ACTION || '</td>
            <td>' || record.TIME || '</td>
            <td>' || record.BOOK_ID || '</td>
            <td>' || record.OLD_BOOK_TITLE || '</td>
            <td>' || record.OLD_BOOK_RELEASE || '</td>
            <td>' || record.OLD_BOOK_PERSON_ID || '</td>
            <td>' || record.OLD_BOOK_PUBLISHER_ID || '</td>
            <td>' || record.NEW_BOOK_TITLE || '</td>
            <td>' || record.NEW_BOOK_RELEASE || '</td>
            <td>' || record.NEW_BOOK_PERSON_ID || '</td>
            <td>' || record.NEW_BOOK_PUBLISHER_ID || '</td>
        </tr>';
    end loop;

    result := result || '</table>';

    result := result || '</body>
</html>';

    dbms_output.put_line(result);
end;