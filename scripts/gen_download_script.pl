#!/usr/bin/env perl

#	$1 -> Source dir (${ROOT}/application)
#	$2 -> Download Script path and name

use Env qw/ROOT/;

my $src_d = $ARGV[0];
my $download = $ARGV[1];
my $index = "$ROOT/index";

sub trim($);
sub readMeta($);

open(DOWNLOAD, "> $download") or die "Can't open: $!";

# Read the application index
open(APP_INDEX, "< $index") or die "Can't read index File: $!";
my @LINES = <APP_INDEX>;
close(APP_INDEX);

print DOWNLOAD "#!/bin/bash \n# Generated by Makescript\n";
                
foreach (@LINES)
{       
        if ( /^\*(.*)$/ ) {
                local $APPLICATION;
                local $NAME=trim($1);
                local $META="$src_d/$NAME/meta";
                
                $APPLICATION = readMeta($META);
                $APPLICATION{NAME}=$NAME;
                
                print DOWNLOAD "wget -c '$APPLICATION{DOWNLOAD_URL}' -O 'software/$CATEGORY/$APPLICATION{EXECUTABLE_NAME}'\n";
        }
        else {
           if ( /^(.*)$/ ) {
                $CATEGORY=trim($1);
                print DOWNLOAD "mkdir -p 'software/$CATEGORY'\n";
           }
        }
}

close(DOWNLOAD);

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub readMeta($)
{
        my $APPLICATION;
        open(META, "< @_") or die "Can't read index File: $!";
        while (<META>) {
            chomp;                  # no newline
            s/#.*//;                # no comments
            s/^\s+//;               # no leading white
            s/\s+$//;               # no trailing white
            next unless length;     # anything left?
            my ($var, $value) = split(/\s*=\s*/, $_, 2);
            $APPLICATION{$var} = $value;
        }
        return $APPLICATION;
}
