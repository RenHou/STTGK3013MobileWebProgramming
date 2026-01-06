<?php
Header("Access-Control-Allow-Origin: *");
include("dbconnect.php");

if ($_SERVER["REQUEST_METHOD"] != "POST") {
    http_response_code(405);
    echo json_encode(array("success" => false, "message" => "Method Not Allowed"));
    exit();
}

if (
    !isset($_POST["pet_id"]) || !isset($_POST["user_id"]) || !isset($_POST["reason"]) ) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Bad Request"));
    exit();
}

$userid = $_POST["user_id"];
$petid = $_POST["pet_id"];
$reason = $_POST["reason"];

$sqlcheckrepeatedrequest = "SELECT 1 FROM `tbl_adoptions` WHERE `pet_id` = '$petid' AND `adopter_user_id` = '$userid' LIMIT 1";
if($conn-> query($sqlcheckrepeatedrequest)-> num_rows > 0) {
    $response = array("success" => false, "message" => "You have already requested adoption for this pet");
    sendJsonResponse($response);
    exit();
}

// Insert new adoption request into database
$sqlrequestadopt = "INSERT INTO tbl_adoptions (pet_id, adopter_user_id, reason) VALUES ('$petid', '$userid', '$reason')";
try{
    if($conn-> query($sqlrequestadopt) ===true) {
        $response = array("success" => true, "message" => "Successfully Requested Adoption");
        sendJsonResponse($response);
        
    }else{
        $response = array("success" => false, "message" => "Requested Adoption Failed");
        sendJsonResponse($response);
    }
}catch(Exception $e){
    $response = array("success"=> false, "message" => "Error Occurred: " . $e-> getMessage());
    sendJsonResponse($response);
}


function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>