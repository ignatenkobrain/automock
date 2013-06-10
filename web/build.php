<?php
    $MOCKDIR = "/opt/automock/";
    $MOCKCONF = $MOCKDIR . "automock.conf";
    $MOCKENC = $MOCKDIR . "gpg-check.sh";
    $MOCKJOB = $MOCKDIR . "jobs.sh";

    function get_keys() {
        global $MOCKCONF;

        $out = array();
        exec("bash -c 'source $MOCKCONF && for key in \${KEYS[@]}; do echo \$key; done'", $keys);
        
        foreach ($keys as &$key) {
            $out[] = explode(":", $key)[1];
        }
        return $out;
    }

    $src = $_POST['src'];
    $sign = $_POST['sign'];
    var_dump($src);
    $hash = hash('sha256', $src);

    $date = date("d.m.Y-H:i:s");
    $name = explode(".", end(explode("/", $src)))[0];
    $rand = mt_rand();
    $file = getenv("DOCUMENT_ROOT") . "/build/jobs/pending/$date-$name.$rand.task";
    file_put_contents($file, $src . "\n"); 
    
    $f = @fopen($file, 'w');
    if (!$f) {
        return false;
    } else {
        $bytes = fwrite($f, $src . "\n");
        fclose($f);
    }
      
    echo "created " . $file;
    echo system("$MOCKJOB &> std");
?>

