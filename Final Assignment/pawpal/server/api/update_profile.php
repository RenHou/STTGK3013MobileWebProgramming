<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    echo json_encode(['status' => 'failed', 'message' => 'Method Not Allowed']);
    exit();
}

// ---------- Get POST data ----------
$userid = $_POST['user_id'];
$name = addslashes($_POST['user_name']);
$phone = addslashes($_POST['user_phone']);
$email = $_POST['user_email'];
$image = $_POST['user_image'];
if ($image == "NA") {
    $decodedImage = "NA";
} else {
    $decodedImage = base64_decode($image);
}

// ---------- SQL UPDATE ----------
$sqlupdateprofile = "
UPDATE tbl_users 
SET 
    name      = '$name',
    phone     = '$phone',
    email   = '$email'
WHERE user_id = '$userid'
";

try {
    if ($conn->query($sqlupdateprofile) === TRUE) {

        if ($decodedImage != "NA") {
            
            $filename = "userimages/" . $userid . ".png";
            file_put_contents($filename, $decodedImage);
        }

        sendJsonResponse([
            'success' => true,
            'message' => 'Profile updated successfully'
        ]);
    } else {
        sendJsonResponse([
            'success' => false,
            'message' => 'Profile update failed'
        ]);
    }
} catch (Exception $e) {
    sendJsonResponse([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}

// ---------- JSON response ----------
function sendJsonResponse($sentArray)
{
    echo json_encode($sentArray);
}
?>