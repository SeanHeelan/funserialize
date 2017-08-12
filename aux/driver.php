<?php
$handle = fopen($argv[1], "r");
if ($handle) {
    $line = fgets($handle);
    #echo $line;
    fclose($handle);
    $data = unserialize($line);
    var_dump($data);
} else {
    echo "Failed to open " + $argv[1];
}
?>

