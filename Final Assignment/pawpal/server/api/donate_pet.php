<?php
Header("Access-Control-Allow-Origin: *");
include("dbconnect.php");

if ($_SERVER["REQUEST_METHOD"] != "POST") {
    http_response_code(405);
    echo json_encode(array("success" => false, "message" => "Method Not Allowed"));
    exit();
}

if (
    !isset($_POST["pet_id"]) || !isset($_POST["user_id"]) || !isset($_POST["donation_type"]) || !isset($_POST["amount"])
    || !isset($_POST["description"])
) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Bad Request"));
    exit();
}

$pet_id = $_POST["pet_id"];
$userid = $_POST["user_id"];
$donation_type = $_POST["donation_type"];
$amount = $_POST["amount"];
$description = $_POST["description"];

// Insert new pet into database
$sqlinsertdonate = "INSERT INTO `tbl_donation`(`user_id`, `pet_id`, `donation_type`, `amount`, `donation_description`) 
VALUES ($userid,$pet_id,'$donation_type','$amount','$description')";

$sqldeducebalance = "UPDATE `tbl_users` SET `wallet_balance`= `wallet_balance` - $amount WHERE  WHERE user_id = $userid";

try {
    // Check if user has sufficient balance (only for Money donations)
    if ($donation_type === 'Money') {
        $checkBalance = "SELECT wallet_balance FROM tbl_users WHERE user_id = $userid";
        $result = $conn->query($checkBalance);

        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            $currentBalance = floatval($row['wallet_balance']);

            if ($currentBalance < $amount) {
                throw new Exception("Insufficient wallet balance. You have RM " . number_format($currentBalance, 2) . " but need RM " . number_format($amount, 2));
            }
        } else {
            throw new Exception("User not found");
        }
    }

    // Insert donation record (store amount in RM in database)
    $sqlinsertdonate = "INSERT INTO `tbl_donation`(`user_id`, `pet_id`, `donation_type`, `amount`, `donation_description`) 
                        VALUES ($userid, $pet_id, '$donation_type', $amount, '$description')";

    if (!$conn->query($sqlinsertdonate)) {
        throw new Exception("Failed to insert donation: " . $conn->error);
    }

    // Deduct balance only for Money donations (in RM)
    if ($donation_type === 'Money') {
        $sqldeducebalance = "UPDATE `tbl_users` SET `wallet_balance` = `wallet_balance` - $amount WHERE user_id = $userid";

        if (!$conn->query($sqldeducebalance)) {
            throw new Exception("Failed to update wallet balance: " . $conn->error);
        }
    }
    $response = array('success' => true, 'message' => 'Donation successful! Thank you for your kindness.');
    sendJsonResponse($response);

} catch (Exception $e) {
    $response = array('success' => 'false', 'message' => $e->getMessage());
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>