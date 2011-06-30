die("Don't run anonymously") if ($anonymous);
#list of things to track
$track = '#stuffmyofficebuddysays #thingsmyofficematesays #thingsmybosssays #stuffmybosssays';
$notimeline = 1;
$store->{'dontecho'} = $whoami; #get my username
$store->{'master'} = "$ENV{'HOME'}/last_tweet";
if(open(S, $store->{'master'})) {
    $last_id = 0+scalar(<S>);
    print $stdout "LIB: init last id: $last_id\n";
    close(S);
}
$extension_mode = $EM_SCRIPT_OFF;

$handle = sub {
        my $ref = shift;
    if ($ref->{'user'}->{'protected'} eq 'true') {
        return 0;
    }

    my $sn = &descape($ref->{'user'}->{'screen_name'});
    print $sn;
    if ($sn eq $store->{'dontecho'}) {
        return 0;
    }


    #retweet!
    my $string = "RT \@$sn " . &descape($ref->{'text'});
    #don't retweet the hashtag too...
    $string =~ s/#stuffmyofficebuddysays//ig;
    $string =~ s/#thingsmyofficematesays//ig;
    $string =~ s/#thingsmybosssays//ig;
    $string =~ s/#stuffmybosssays//ig;
    #print for debugging
    print $stdout ("Publishing: ", $string, "\n");
    &updatest($string);
    &defaulthandle($ref);
    return 1;
};

$conclude = sub {
    #track last tweet we saw
    print $stdout "LIB: writing out: $last_id\n";
    if(open(S, ">".$store->{'master'})) {
    print S $last_id;
    close(S);
    } else {
        print $stdout "LIB: failure to write: $!\n";
    }
    &defaultconclude;
};
