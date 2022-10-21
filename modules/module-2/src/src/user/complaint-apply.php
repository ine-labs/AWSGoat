<?php


include_once '../config.inc';

    if (isset($_POST['request'])){
        $message = $_POST['message'];
        $id = $_POST['id'];
        $username = $_POST['username'];
        $organization_id = $_POST['organization_id'];
        $query = "INSERT INTO `complaints` ( `id`, `first_name`, `message`, `organization_id`) VALUES 
        ('$id', '$username', '$message', '$organization_id');";
        mysqli_query($conn, $query);
        header('Location: ./complaints.php');
    }
?>