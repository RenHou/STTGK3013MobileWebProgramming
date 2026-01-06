<?php
header("Access-Control-Allow-Origin: *"); // running as chrome app

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    include 'dbconnect.php';

    // Base JOIN query
    $baseQuery = "
        SELECT 
            p.pet_id,
            p.user_id,
            p.pet_name,
            p.age,
            p.gender,
            p.health,
            p.pet_type,
            p.category,
            p.description,
            p.image_paths,
            p.lat,
            p.lng,
            p.created_at,
            u.name,
            u.email,
            u.phone,
            u.reg_date
        FROM tbl_pets p
        JOIN tbl_users u ON p.user_id = u.user_id
        WHERE 1
    ";

    //filter logic
    if (isset($_GET['filterQuery']) && !empty($_GET['filterQuery'])) {
        $filter = $conn->real_escape_string($_GET['filterQuery']);
        $baseQuery .= " AND p.pet_type = '$filter'";
    }

    // Search logic
    if (isset($_GET['searchQuery']) && !empty($_GET['searchQuery'])) {
        $search = $conn->real_escape_string($_GET['searchQuery']);
        $baseQuery .= " AND p.pet_name LIKE '%$search%'";
    }

    $baseQuery .= " ORDER BY p.pet_id DESC";

    // Execute query
    $result = $conn->query($baseQuery);

    if ($result && $result->num_rows > 0) {
        $petdata = array();
        while ($row = $result->fetch_assoc()) {
            $petdata[] = $row;
        }
        $response = array('success' => 'true', 'data' => $petdata);
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