<?php

include_once '../config.inc';

    if (isset($_POST['save_leave_status'])){
        $response = $_POST['review'];
        $leaveid = $_POST['leave_id'];
        $query = "UPDATE `leave_applications` SET `status` = '$response' WHERE `leave_id`='$leaveid'";
        mysqli_query($conn, $query);
        header('Location: ./leave-application.php');
    }
    if (isset($_POST['delete_leave_status'])){
        $leaveid = $_POST['leave_id'];
        $query = "DELETE FROM `leave_applications` WHERE `leave_id` = '$leaveid'";
        mysqli_query($conn, $query);
        header('Location: ./leave-application.php');
    }
?>