<?php
Header("Access-Control-Allow-Origin: *");


if($_SERVER['REQUEST_METHOD']!= "POST"){
    http_response_code(405);
    echo json_encode(array("success"=> false, "message"=> "Method Not Allowed"));
    exit();
}

if(!isset($_POST ["email"]) || !isset($_POST["password"])){
    http_response_code(400);
    echo json_encode(array("success"=> false, "message"=> "Bad Request"));
    exit();
}

$email =$_POST["email"];
$password = $_POST["password"];
$encodedpassword = sha1($password);
include("dbconnect.php");

$sqllogin = "SELECT * FROM `tbl_users` WHERE `email`= '$email' AND `password`= '$encodedpassword'";
$result = $conn->query($sqllogin);

try{
    if( $result -> num_rows > 0) {
        $userdata = array();
        while($row = $result -> fetch_assoc()) {
            $userdata[] = $row;
        }
        $response = array("success" => true, "message" => "Successfully Login", "data"=> $userdata);
        sendJsonResponse($response);
        
    }else{
        $response = array("success" => false, "message" => "User Login Failed", "data"=> null);
        sendJsonResponse($response);
    }
}catch(Exception $e){
    $response = array("success"=> false, "message" => "Error Occurred : " . $e-> getMessage(), "data"=> null);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>