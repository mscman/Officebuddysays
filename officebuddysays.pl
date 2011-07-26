###################
#
# officebuddysays.pl -- a TTYtter bot extension
#
# 	Copyright (C) 2011 by Andy Howard and Ben Cotton
#
# 	See README for more information.
#
# 	Licensed under GNU Public License v2.0. See LICENSE for full text.
#
###################

die("Don't run anonymously") if ($anonymous);
die("Requires TTYtter version 1.2 or greater\n") if ( $TTYtter_VERSION < 1.2 );

# Spit the PID to stderr so that an init script or similar can save it
print STDERR ("$parent");

#list of things to track
$track = defined($ENV{'OFFICEBUDDY_TRACK'}) ? $ENV{'OFFICEBUDDY_TRACK'} : 
	'#stuffmyofficebuddysays #thingsmyofficematesays #thingsmybosssays #stuffmybosssays';
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
    my $string = &descape($ref->{'text'});
    #print for debugging
    print $stdout ("Publishing: ", $string, "\n");
    # Tell TTYtter to RT the status
    $string =~ s/^RT \@[^\s]+:\s+// if ($ref->{'retweeted_status'}->{'id_str'});
    print $stdout "-- status retweeted\n"
    &updatest($string, 1, 0, undef,
        $ref->{'retweeted_status'}->{'id_str'}
        || $ref->{'id_str'})
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
