<?php
    $servername = "localhost";
    $db_name = "pawpal_db";
    $username = "root";
    $passowrd = "";
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