<?php

include_once '../config.inc';

    if (isset($_POST['submit'])){
        $compid = $_POST['complaint_id'];
        $remark = $_POST['remark'];
        $query = "UPDATE `complaints` SET `remark` = '$remark' where complaint_id = '$compid'";

        mysqli_query($conn, $query);
        header('Location: complaints.php');
    }

    if (isset($_POST['delete'])){
        $compid = $_POST['complaint_id'];
        $remark = $_POST['remark'];
        $query = "DELETE FROM `complaints` WHERE complaint_id = '$compid'";

        mysqli_query($conn, $query);
        header('Location: complaints.php');
    }
?>