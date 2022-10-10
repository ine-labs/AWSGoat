<?php 

$server = "RDS_ENDPOINT_VALUE";
$user = "root";
$pass = "T2kVB3zgeN3YbrKS";
$database = "appdb";

$conn = mysqli_connect($server, $user, $pass, $database);

if (!$conn) {
    die("<script>alert('Connection Failed.')</script>");
}

?>