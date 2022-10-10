<?php

include_once '../config.inc';

if (isset($_POST['update_user'])){
    $fname = $_REQUEST['inputfirstname'];
    $lname = $_REQUEST['inputlastname'];
    $phone = $_REQUEST['inputphone'];
    $email = $_REQUEST['inputEmail'];
    $address = $_REQUEST['inputAddress'];
    $ssn = $_REQUEST['inputssn'];
    $bank = $_REQUEST['inputbank'];
    $npass = $_REQUEST['inputnewPassword'];
    $cpass = $_REQUEST['inputcnfPassword'];

    if ((!empty($fname)) && (!empty($lname)) && (!empty($email)) && (!empty($address)) && (!empty($ssn))) {
        $upq = "UPDATE `users_info` SET `first_name` = '$fname', `last_name` = '$lname' , `phone` = '$phone', `email` = '$email', `address` = '$address', `ssn` = '$ssn', `bank_account` = '$bank' WHERE id = (SELECT id from users where username = '{$_SESSION['username']}');";
        $upq2 = "UPDATE `users` SET `email` = '$email' where id =(SELECT id from users where username = '{$_POST['username']}'); ";
        $upload1 = mysqli_query($conn, $upq);
        $upload2 = mysqli_query($conn, $upq2);

        if ((!empty($npass)) && (!empty($cpass))) {
            if (($npass == $cpass)) {
                $pass=md5($cpass);
                $upq3 = "UPDATE `users` SET `password` = '$pass' where id =$userid; ";
                $upload3 = mysqli_query($conn, $upq3);
                header('Location: ../logout.php');
                exit;
            }
        }

        header('Location: user-settings.php');
        exit;
    } else {
        $_SESSION['errorMsg'] = "Only Phone & Bank details can be blank!";
        header('Location: user-settings.php');
        exit;
    }
}

?>