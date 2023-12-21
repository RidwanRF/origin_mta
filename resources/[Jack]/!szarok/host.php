<?php
if(!isset($_GET["status"]) || !isset($_GET["tel"]) || !isset($_GET["prefix"]) || !isset($_GET["text"]) || !isset($_GET["value"]) || !isset($_GET["id"])) die(utf8_decode("Nem, nem balátocskám..."));
if(!in_array($_SERVER["REMOTE_ADDR"], ["193.28.86.95", "195.228.45.25"])) die(utf8_decode("Mekkora buzi vagy LOL!"));

include 'sql.php';

if(mysqli_connect_errno()) die(utf8_decode("Mysql hiba: " . mysqli_connect_error()));

$stat=$_GET["status"];
$telefonszam=$_GET["tel"];
$prefix=$_GET["prefix"];
$uzenet=$_GET["text"];
$tarifa=$_GET["value"];
$smsid=$_GET["id"];
$provider=isset($_GET["provider"]) ? $_GET["provider"] : 0;

$serverip = '37.221.209.236';
$serverport = 22005; 
$username = 'phpsdk';
$password = 'TTssFKWQ21GHSDJ';
$resourceName = 'oPremium';
$functionName = 'receiveDonation';

$errorMsg = 'Sikertelen tamogatas! Kerlek keress fel egy tulajdonost!'; // Hiba válasz sms (!!!Ékezeteket nem támogat!!!)

if($stat == 2) die("OK");

function esc($s){
        global $sql;
        return htmlspecialchars(mysqli_real_escape_string($sql, $s));
}

if(($stat == 1) || ($stat == 3))
{
        $id = (int)$uzenet;
        if($id > 0){
                $charData = mysqli_fetch_array(mysqli_query($sql, "SELECT `pp`, `id` FROM `characters` WHERE `id` = '" . esc($id) . "'"));
                if($charData === false or count($charData) == 0) die(utf8_decode("A megadott azonosítóval karakter nem található!"));

                $pp = 0;
                switch($tarifa){
                        case 800:
                                $pp = 1000;
                                break;
                        case 1600:
                                $pp = 2500;
                                break;
                        case 4000:
                                $pp = 6000;
                                break;
                        default:
                                $pp = 0;
                                break;
                }

                $newPP = $charData['pp'] + $pp;
                mysqli_query($sql, "UPDATE `characters` SET `pp` = '".$newPP."' WHERE `id` = '".$charData['id']."'");
                mysqli_query($sql, "INSERT INTO `logpp`(`id`, `date`, `tel`, `text`, `provider`, `sms_id`, `tarifa`, `newpp`) VALUES (0,NOW(),'".esc($telefonszam)."','".esc($uzenet)."','".esc($provider)."','".esc($smsid)."','".esc($tarifa)."','".esc($newPP)."')");

                require('mtasdk.php');
                $mta = new mta($serverip, $serverport, $username, $password);
                $resource = $mta->getResource($resourceName);

                if (!$resource) {
                    echo $errorMsg . ' #GAME1';
                    exit;
                }

                $mta->callFunction($resourceName, $functionName, $telefonszam, $pp, $charData['id']);

                die(utf8_decode("Sikeresen jóváírtunk ".$pp." PP-t a számládra! Lett ". $newPP . " PP-d."));
        }else{
                die(utf8_decode("Hibásan adtad meg a karakter azonosítódat!"));
        }
}

?>