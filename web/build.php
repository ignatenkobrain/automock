<?php
    $MOCKDIR = "/opt/automock/";
    $MOCKCONF = $MOCKDIR . "automock.conf";
    $MOCKENC = $MOCKDIR . "gpg-check.sh";
//    $MOCKJOB = $MOCKDIR . "jobs.sh";

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
    $branch = $_POST['branch'];
    $sign = $_POST['sign'];
    var_dump($src);
    var_dump($branch);
    $hash = hash('sha256', $src);

    $date = date("d.m.Y-H:i:s");
    $name = explode(".", end(explode("/", $src)))[0];
    $rand = mt_rand();
    $file = getenv("DOCUMENT_ROOT") . "/build/jobs/pending/$date-$name.$rand.task";
    file_put_contents($file, "TIMESTAMP=\"" . $date . "\"\n" . "URL=\"" . $src . "\"\n" . "BRANCH=\"" . $branch . "\"\n"); 
/*    
    $f = @fopen($file, 'w');
    if (!$f) {
        return false;
    } else {
        $bytes = fwrite($f, $src . "\n");
        fclose($f);
    }
*/
//    echo system($MOCKJOB);
?>

