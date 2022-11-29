<?php

  ob_start();

  error_reporting(version_compare(PHP_VERSION, '5.4.0', '<') ? E_ALL | E_STRICT : E_ALL);

  ini_set('display_errors', 'On');

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
    $zip = new ZipArchive;
    if (!$zip->open($tmpfile)) {
      throw new Exception('Failed opening the archive');
    }

    echo "Extracting files...\n";
    for($i = 0; $i < $zip->numFiles; $i++) {
      $filename = $zip->getNameIndex($i);
      if (preg_match('#^public_html/(.+)$#', $filename, $matches)) {
        echo "  $filename\n";
        if (substr($filename, -1) == '/') {
          mkdir($matches[1]);
        } else {
          copy("zip://$tmpfile#$filename", $matches[1]);
        }
      }
    }

    $zip->close();

    unlink($tmpfile);

    echo "\nExtraction complete! Now open your web browser and navigate to the website to continue the installation.";

    header('Location: install/index.php');
    exit;

  } catch (Exception $e) {
    echo 'Error: '. $e->getMessage();
  }
