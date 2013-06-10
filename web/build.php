<?php
    $MOCKCONF = "/opt/automock/automock.conf";
    $MOCKENC = "/opt/automock/gpg-check.sh";

    function get_keys() {
        global $MOCKCONF;

        $out = array();
        exec("bash -c 'source $MOCKCONF && for key in \${KEYS[@]}; do echo \$key; done'", $keys);
        
        foreach ($keys as &$key) {
            $out[] = explode(":", $key)[1];
        }
        return $out;
    }
    
    system("echo lol", $var);
    var_dump($var);

    die();

    //get params
    $src = $_POST['src'];
    $sign = $_POST['sign'];
    $hash = hash('sha256', $src);

    //decrypt hash
    $pgp = gnupg_init();
    gnupg_adddecryptkey($pgp, $PGPKEY);
    $origin = gnupg_decrypt($pgp, $sign);

    if ($hash == $origin) {
        //ok
        echo 'ok';
    }
    else {
        http_response_code(403);
        echo 'no access';
        die();
    }
?>

