<?php

include_once '../config.inc';

$username = $_POST['username'];
$email = $_POST['email'];
$password = md5($_POST['password']);
$isadmin = $_POST['isadmin'];

$organization_id = $_POST['organization_id'];


$query = "INSERT INTO `users` (`organization_id`, `username`, `email`, `password`, `isadmin`) VALUES 
('$organization_id', '$username', '$email', '$password', '$isadmin');";


$firstname = $_POST['firstname'];
$lastname = $_POST['lastname'];
$address = $_POST['address'];
$ssn = $_POST['ssn'];
$bank_account = $_POST['bank_account'];
$phone = $_POST['phone'];


mysqli_query($conn, $query);

$query3 = "SELECT `id` FROM `users` WHERE `email`='$email';";
  
// FETCHING DATA FROM DATABASE
$result = $conn->query($query3);

$id = $result->fetch_array()[0] ?? '';


$query2 = "INSERT INTO `users_info`(
    `id`,
    `first_name`,
    `last_name`,
    `email`,
    `address`,
    `ssn`,
    `bank_account`,
    `phone`,
    `isadmin`
)
VALUES(
    '$id',
    '$firstname',
    '$lastname',
    '$email',
    '$address',
    '$ssn',
    '$bank_account',
    '$phone',
    '$isadmin'
);";

mysqli_query($conn, $query2);
header('Location: user-settings.php');
?>