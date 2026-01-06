<?php
    $servername = "localhost";
    $db_name = "canortxw_THR_pawpal_db";
    $username = "canortxw_THR";
    $passowrd = "wki6HfVYbZ3P";
    $conn = new mysqli(
        $servername,
        $username,
        $passowrd,
        $db_name
    );
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
?>