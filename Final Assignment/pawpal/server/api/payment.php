<?php
error_reporting(0);

include_once("apikey.php");

$email = $_GET['email']; //email
$phone = $_GET['phone']; 
$name = $_GET['name']; 
$amount = $_GET['amount']; 
$userid = $_GET['userid'];


$api_key = $apikey;
$collection_id = $collectionid;
$host = 'https://www.billplz-sandbox.com/api/v3/bills';


$data = array(
          'collection_id' => $collection_id,
          'email' => $email,
          'mobile' => $phone,
          'name' => $name,
          'amount' => $amount, 
		  'description' => 'Payment for '.$userid,
          'callback_url' => "https://canorcannot.com/HouRen/pawpal/api/return_url",
          'redirect_url' => "https://canorcannot.com/HouRen/pawpal/api/payment_update.php?userid=$userid&email=$email&name=$name&phone=$phone&amount=$amount" 
);


$process = curl_init($host );
curl_setopt($process, CURLOPT_HEADER, 0);
curl_setopt($process, CURLOPT_USERPWD, $api_key . ":");
curl_setopt($process, CURLOPT_TIMEOUT, 30);
curl_setopt($process, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($process, CURLOPT_SSL_VERIFYHOST, 0);
curl_setopt($process, CURLOPT_SSL_VERIFYPEER, 0);
curl_setopt($process, CURLOPT_POSTFIELDS, http_build_query($data) ); 

$return = curl_exec($process);
curl_close($process);

$bill = json_decode($return, true);

echo "<pre>".print_r($bill, true)."</pre>";
header("Location: {$bill['url']}");
?>