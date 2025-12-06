<?php
Header("Access-Control-Allow-Origin: *");
include("dbconnect.php");

if ($_SERVER["REQUEST_METHOD"] != "POST") {
    http_response_code(405);
    echo json_encode(array("success" => false, "message" => "Method Not Allowed"));
    exit();
}

if (
    !isset($_POST["name"]) || !isset($_POST["type"]) || !isset($_POST["category"]) || !isset($_POST["latitude"])
    || !isset($_POST["longitude"]) || !isset($_POST["description"]) || !isset($_POST["images"])
) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Bad Request"));
    exit();
}

$userid = $_POST["userid"];
$pet_name = $_POST["name"];
$pet_type = $_POST["type"];
$category = $_POST["category"];
$latitude = $_POST["latitude"];
$longitude = $_POST["longitude"];
$description = $_POST["description"];
$images = $_POST["images"];
$imagesArray = json_decode($images, true);
$imagePaths = [];

// Insert new pet into database
$sqlinsertpet = "INSERT INTO `tbl_pets`( `user_id`, `pet_name`, `pet_type`, `category`, `description`,`image_paths`, `lat`, `lng`)
 VALUES ('$userid','$pet_name','$pet_type','$category','$description','','$latitude','$longitude')";
try {
    if ($conn->query($sqlinsertpet) === TRUE) {

        $last_id = $conn->insert_id;
        for ($i = 0; $i < count($imagesArray); $i++) {
            $imagebase64 = $imagesArray[$i];         
            $decodedImage = base64_decode($imagebase64);  

            $filename = "uploads/pet_" . $last_id . "_$i.png";  
            file_put_contents($filename, $decodedImage);
            $imagePaths[] = $filename;                          
        }

        //Update the pet record with JSON-encoded image paths
        $imagePathsJson = json_encode($imagePaths);
        $sqlUpdate = "UPDATE tbl_pets SET image_paths='$imagePathsJson' WHERE pet_id='$last_id'";
        $conn->query($sqlUpdate);

        $response = array('success' => 'true', 'message' => 'Pet submitted successfully');
        sendJsonResponse($response);
    } else {
        $response = array('success' => 'false', 'message' => 'Pet not added');
        sendJsonResponse($response);
    }
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