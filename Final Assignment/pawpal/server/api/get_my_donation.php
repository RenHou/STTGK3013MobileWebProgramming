<?php
header("Access-Control-Allow-Origin: *"); // running as chrome app

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    include 'dbconnect.php';

    if (!isset($_GET['userid'])) {
        sendJsonResponse([
            'success' => 'false',
            'data' => []
        ]);
        exit();
    }
    $userid = $_GET['userid'];

    $sqlmydonation = "
        SELECT 
            d.donation_id,
            d.user_id,
            d.pet_id,
            d.donation_type,
            d.donation_description,
            d.donation_date,
            d.amount,
            p.pet_name
        FROM tbl_donation d
        JOIN tbl_pets p ON d.pet_id = p.pet_id
        WHERE d.user_id = '$userid'
        ORDER BY d.donation_date DESC
    ";

    // Execute query
    $result = $conn->query($sqlmydonation);

    if ($result && $result->num_rows > 0) {
        $donation = array();
        while ($row = $result->fetch_assoc()) {
            $donation[] = $row;
        }
        $response = array('success' => 'true', 'data' => $donation);
        sendJsonResponse($response);
    } else {
        $response = array('success' => 'false', 'data' => []);
        sendJsonResponse($response);
    }

} else {
    $response = array('success' => 'false');
    sendJsonResponse($response);
    exit();
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>