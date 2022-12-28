<?php

  ob_start();

  error_reporting(version_compare(PHP_VERSION, '5.4.0', '<') ? E_ALL | E_STRICT : E_ALL);

  ini_set('display_errors', 'On');
  ini_set('display_html_errors', 'Off');

  header('Content-Type: text/plain; charset=UTF-8');

  try {

    if (version_compare(PHP_VERSION, '5.4.0', '<')) {
      throw new Exception('You need at minimum PHP 5.4 for installing LiteCart');
    }

    if (!extension_loaded('zip')) {
      throw new Exception('This installer needs the PHP extension Zip installed in your PHP environment');
    }

    echo "Downloading LiteCart from the official website...\n";
    if (!$data = file_get_contents('https://www.litecart.net/en/downloading?version=latest&action=get')) {
      throw new Exception('Failed downloading LiteCart from the official website');
    }

    echo "Reserving a temporary file...\n";
    if (!$tmpfile = tempnam(sys_get_temp_dir(), 'litecart')) {
      throw new Exception('Failed creating temporary archive');
    }

    echo "Creating temporary archive $tmpfile...\n";
    if (!file_put_contents($tmpfile, $data)) {
      throw new Exception('Failed creating temporary archive');
    }

    echo "Opening the archive...\n";
    $zip = new ZipArchive();

    if ($zip->open($tmpfile, ZipArchive::RDONLY) !== true) {
      throw new Exception('Failed opening the archive');
    }

    echo "Extracting files...\n";
    for($i = 0; $i < $zip->numFiles; $i++) {
      $filename = $zip->getNameIndex($i);

      if (preg_match('#^public_html/(.+)$#', $filename, $matches)) {
        echo "  $matches[1]\n";

        if (substr($filename, -1) == '/') {
          if (!is_dir($matches[1]) && !mkdir($matches[1])) {
            throw new Exception('Failed creating directory '. $matches[1] .' (user: '. get_current_user() .', whoami: '. exec('whoami') .', perms: '. substr(sprintf('%o', fileperms(getcwd())), -4) .')');
          }

        } else {
          if (!copy("zip://$tmpfile#$filename", $matches[1])) {
            throw new Exception('Failed writing file '. $matches[1] .' (user: '. get_current_user() .', whoami: '. exec('whoami') .', perms: '. substr(sprintf('%o', fileperms(getcwd())), -4) .')');
          }
        }
      }
    }

    $zip->close();

    unlink($tmpfile);

    echo "\nExtraction complete!\n\n";

    if (php_sapi_name() == 'cli') {
      echo "\nAccess https://yourdomain.tld/install/ from your web browser to begin the installation.";
      exit;
    }

    header('Refresh: 5; url=install/');
    exit;

  } catch (Exception $e) {
    if (is_file($tmpfile)) unlink($tmpfile);
    echo 'Error: '. $e->getMessage();
  }
