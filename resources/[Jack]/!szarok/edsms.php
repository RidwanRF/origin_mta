<?php

    // created by szkiddaj (https://github.com/szkiddaj/edsms-mtasa)
    // Ha kimered adni saját munkádnak, nyakonbaszlak

    // Szerver adatok, válasz SMS, stb...
    $dbHost = '127.0.0.1'; // Adatbázis IP címe
    $dbUser = 'root'; // Adatbázis felhasználó
    $dbPass = ''; // Adatbázis jelszó
    $dbTable = ''; // Adatbázisban lévő tábla neve

    $serverip = '127.0.0.1';
    $serverport = 22005; // HTTP PORT KELL IDE, MONDOM HTTP PORT
    $username = 'phpsdk';
    $password = 'asd123';
    $resourceName = 'edsms'; // Resource neve, amit meghív a kód
    $functionName = 'receiveDonation';

    $successfulMsg = 'Koszonjuk a tamogatasod!'; // Válasz sms (!!!Ékezeteket nem támogat!!!)
    $errorMsg = 'Sikertelen tamogatas! Kerlek keress fel egy tulajdonost!'; // Hiba válasz sms (!!!Ékezeteket nem támogat!!!)

    /*
        Lehetséges hibakódok amiket a támogató kaphat:

        #DB1 = Sikertelen csatlakozás az sqlhez. (Valószínűleg el lettek írva az adatok)
        #DB2 = Nem sikerült belerakni az sqlbe a támogatást.
        #GAME1 = Ha valamiért nem tudja meghívni a függvényt a szerveren (Nincs elindítva, nincsen joga a szerveren, nem tudott belépni mert kikúrta.)
    */

    $allowedAddresses = array('127.0.0.1', '123.123.123.123'); // engedélyezett IP címek, amiket nem dob vissza a kód. (Azért van, hogy ne lehessen random IPkről meghívni.)

    if (!in_array($_SERVER['REMOTE_ADDR'], $allowedAddresses))
        die('Nem szabad.. ' . $_SERVER['REMOTE_ADDR']);

    if (isset($_GET['tel']) && isset($_GET['value']) && isset($_GET['prefix']) && isset($_GET['message'])) { // Ha minden get request megvan
        $phone = $_GET['tel'];
        $value = $_GET['value'];
        $prefix = $_GET['prefix'];
        $msg = urldecode($_GET['message']);

        try {
          $conn = new PDO("mysql:host=$dbHost;dbname=$dbTable", $dbUser, $dbPass);
          $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
          $conn->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
        } catch (PDOException $e) {
          echo $errorMsg . ' #DB1';
          exit;
        }

        $prep = $conn->prepare("INSERT INTO edsms (phone, value, prefix, msg) VALUES (?, ?, ?, ?)");
        if (!$prep->execute(array( $phone, $value, $prefix, $msg ))) {
            echo $errorMsg . ' #DB2';
            exit;
        }

        /*require('./mtasdk.php');
        $mta = new mta($serverip, $serverport, $username, $password);
        $resource = $mta->getResource($resourceName);

        if (!$resource) {
            echo $errorMsg . ' #GAME1';
            exit;
        }

        $mta->callFunction($resourceName, $functionName, $phone, $value, $msg);*/
        echo $successfulMsg;
    }
