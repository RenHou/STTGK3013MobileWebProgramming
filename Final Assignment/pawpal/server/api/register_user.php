<?php
Header("Access-Control-Allow-Origin: *");
include("dbconnect.php");

if ($_SERVER["REQUEST_METHOD"] != "POST") {
    http_response_code(405);
    echo json_encode(array("success" => false, "message" => "Method Not Allowed"));
    exit();
}

if (!isset($_POST["name"]) || !isset($_POST["email"]) || !isset($_POST["password"]) || !isset($_POST["phone"])) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Bad Request"));
    exit();
}

$name = $_POST["name"];
$email = $_POST["email"];
$password = $_POST["password"];
$phone = $_POST["phone"];
$encodedpassword = sha1($password);

$sqlcheckemail= "SELECT * FROM `tbl_users` WHERE `email` = '$email'";
$result = $conn-> query($sqlcheckemail);
if($result-> num_rows > 0) {
    $response = array("success" => false, "message" => "Email already registered");
    sendJsonResponse($response);
    exit();
}

$sqlregister = "INSERT INTO `tbl_users`(`name`, `email`, `password`, `phone`) VALUES ('$name', '$email', '$encodedpassword', '$phone')";

try{
    if($conn-> query($sqlregister) ===true) {
        $response = array("success" => true, "message" => "Successfully Registered");
        sendJsonResponse($response);
        
    }else{
        $response = array("success" => false, "message" => "User Registration Failed");
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