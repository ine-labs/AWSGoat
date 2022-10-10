<?php

include_once '../config.inc';

    if (isset($_POST['save_rem_status'])){
        $response = $_POST['review'];
        $remid = $_POST['reimbursment_id'];
        $query = "UPDATE `reimbursments` SET `status` = '$response' WHERE `reimbursment_id`='$remid'";
        mysqli_query($conn, $query);
        header('Location: reimbursment.php');
    }
    if (isset($_POST['delete_rem_status'])){
        $remid = $_POST['reimbursment_id'];
        $query = "DELETE FROM `reimbursments` WHERE `reimbursment_id`='$remid'";
        mysqli_query($conn, $query);
        header('Location: reimbursment.php');
    }
?>