<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

include_once("dbconnect.php");
include_once("apikey.php");

$email = $_GET['email'] ?? ''; 
$phone = $_GET['phone'] ?? ''; 
$name = $_GET['name'] ?? ''; 
$amount = ($_GET['amount'] ?? 0)/100;
$userid = $_GET['userid'] ?? '';

// Check if billplz parameters exist
if (!isset($_GET['billplz']['id'])) {
    die("<h3>Error: Missing Billplz payment data</h3>");
}

$data = array(
    'id' => $_GET['billplz']['id'],
    'paid_at' => $_GET['billplz']['paid_at'],
    'paid' => $_GET['billplz']['paid'],
    'x_signature' => $_GET['billplz']['x_signature']
);

$paidstatus = $_GET['billplz']['paid'];
if ($paidstatus == "true"){
    $paidstatus = "Success";
} else {
    $paidstatus = "Failed";
}

$receiptid = $_GET['billplz']['id'];
$signing = 'billplzid'.$data['id']
         . '|billplzpaid_at'.$data['paid_at']
         . '|billplzpaid'.$data['paid'];
 
$signed = hash_hmac('sha256', $signing, $xkey);

if ($signed === $data['x_signature']) {
    if ($paidstatus == "Success") { 
        // Use prepared statement to prevent SQL injection
        $stmt = $conn->prepare("UPDATE `tbl_users` SET `wallet_balance` = `wallet_balance` + ? WHERE `user_id` = ?");
        $stmt->bind_param("ds", $amount, $userid);
        
        if ($stmt->execute()) {
            // Success - print receipt
            echo "
            <!DOCTYPE html>
            <html>
            <head>
                <meta name='viewport' content='width=device-width, initial-scale=1'>
                <link rel='stylesheet' href='https://www.w3schools.com/w3css/4/w3.css'>
                <style>
                    body { padding: 20px; font-family: Arial; }
                    .receipt { max-width: 500px; margin: 0 auto; }
                    .success { background: #4CAF50; color: white; padding: 10px; text-align: center; border-radius: 5px; margin: 15px 0; }
                </style>
            </head>
            <body>
                <div class='receipt'>
                    <center><h4>Receipt</h4></center>
                    <div class='success'>✓ Payment Successful</div>
                    <table class='w3-table w3-striped w3-bordered'>
                        <tr><th>Item</th><th>Description</th></tr>
                        <tr><td>Receipt</td><td>" . htmlspecialchars($receiptid) . "</td></tr>
                        <tr><td>Name</td><td>" . htmlspecialchars($name) . "</td></tr>
                        <tr><td>Email</td><td>" . htmlspecialchars($email) . "</td></tr>
                        <tr><td>Phone</td><td>" . htmlspecialchars($phone) . "</td></tr>
                        <tr><td>Paid Amount</td><td>RM " . number_format($amount, 2) . "</td></tr>
                        <tr><td>Paid Status</td><td class='w3-text-green'><b>$paidstatus</b></td></tr>
                    </table>
                </div>
            </body>
            </html>";
        } else {
            // Database update failed
            echo "
            <!DOCTYPE html>
            <html>
            <head>
                <meta name='viewport' content='width=device-width, initial-scale=1'>
                <link rel='stylesheet' href='https://www.w3schools.com/w3css/4/w3.css'>
                <style>
                    body { padding: 20px; font-family: Arial; }
                    .receipt { max-width: 500px; margin: 0 auto; }
                    .failed { background: #f44336; color: white; padding: 10px; text-align: center; border-radius: 5px; margin: 15px 0; }
                </style>
            </head>
            <body>
                <div class='receipt'>
                    <center><h4>Receipt</h4></center>
                    <div class='failed'>✗ Database Error</div>
                    <table class='w3-table w3-striped w3-bordered'>
                        <tr><th>Item</th><th>Description</th></tr>
                        <tr><td>Receipt</td><td>" . htmlspecialchars($receiptid) . "</td></tr>
                        <tr><td>Name</td><td>" . htmlspecialchars($name) . "</td></tr>
                        <tr><td>Email</td><td>" . htmlspecialchars($email) . "</td></tr>
                        <tr><td>Phone</td><td>" . htmlspecialchars($phone) . "</td></tr>
                        <tr><td>Paid</td><td>RM " . number_format($amount, 2) . "</td></tr>
                        <tr><td>Paid Status</td><td class='w3-text-red'><b>Database Error</b></td></tr>
                    </table>
                </div>
            </body>
            </html>";
        }
    } else {
        // Payment failed
        echo "
        <!DOCTYPE html>
        <html>
        <head>
            <meta name='viewport' content='width=device-width, initial-scale=1'>
            <link rel='stylesheet' href='https://www.w3schools.com/w3css/4/w3.css'>
            <style>
                body { padding: 20px; font-family: Arial; }
                .receipt { max-width: 500px; margin: 0 auto; }
                .failed { background: #f44336; color: white; padding: 10px; text-align: center; border-radius: 5px; margin: 15px 0; }
            </style>
        </head>
        <body>
            <div class='receipt'>
                <center><h4>Receipt</h4></center>
                <div class='failed'>✗ Payment Failed</div>
                <table class='w3-table w3-striped w3-bordered'>
                    <tr><th>Item</th><th>Description</th></tr>
                    <tr><td>Receipt</td><td>" . htmlspecialchars($receiptid) . "</td></tr>
                    <tr><td>Name</td><td>" . htmlspecialchars($name) . "</td></tr>
                    <tr><td>Email</td><td>" . htmlspecialchars($email) . "</td></tr>
                    <tr><td>Phone</td><td>" . htmlspecialchars($phone) . "</td></tr>
                    <tr><td>Paid</td><td>RM " . number_format($amount, 2) . "</td></tr>
                    <tr><td>Paid Status</td><td class='w3-text-red'><b>$paidstatus</b></td></tr>
                </table>
            </body>
        </html>";
    }
} else {
    // Invalid signature
    echo "
    <!DOCTYPE html>
    <html>
    <head>
        <meta name='viewport' content='width=device-width, initial-scale=1'>
        <link rel='stylesheet' href='https://www.w3schools.com/w3css/4/w3.css'>
    </head>
    <body>
        <div style='max-width: 500px; margin: 50px auto; padding: 20px;'>
            <div class='w3-panel w3-red w3-round'>
                <h3>⚠️ Invalid Signature</h3>
                <p>Payment verification failed.</p>
            </div>
        </div>
    </body>
    </html>";
}
?>