#!/usr/bin/perl
use strict;
use warnings;
use JSON;
use LWP::UserAgent;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use MIME::Lite;
use Net::IP;

# CONFIGURATION
my $EMAIL_TO     = 'hello@cistbiopharma.com';
my $GOOGLE_API_K = 'YOUR_GOOGLE_MAPS_API_KEY';
my $LOG_TO_CHECK = '/var/log/apache2/access_log'; # Can be swapped for secure/auth logs

# PREMIUM IBLOCKLIST URLS
my @FEED_URLS = (
    'http://list.iblocklist.com/?list=dufcxgnbjsdwmwctgfuj&fileformat=p2p&archiveformat=gz&username=FADMHofstad&pin=872065',
    'http://list.iblocklist.com/?list=pbqcylkejciyhmwttify&fileformat=p2p&archiveformat=gz&username=FADMHofstad&pin=872065',
    'http://list.iblocklist.com/?list=czvaehmjpsnwwttrdoyl&fileformat=p2p&archiveformat=gz&username=FADMHofstad&pin=872065',
    'http://list.iblocklist.com/?list=ghlzqtqxnzctvvajwwag&fileformat=p2p&archiveformat=gz&username=FADMHofstad&pin=872065',
    'http://list.iblocklist.com/?list=llvtlsjyoyiczbkjsxpf&fileformat=p2p&archiveformat=gz&username=FADMHofstad&pin=872065',
    'http://list.iblocklist.com/?list=xpbqleszmajjesnzddhv&fileformat=p2p&archiveformat=gz&username=FADMHofstad&pin=872065'
);

sub fetch_and_parse_blocklists {
    my $ua = LWP::UserAgent->new;
    $ua->timeout(30);
    
    my %blocked_ranges;

    foreach my $url (@FEED_URLS) {
        my $response = $ua->get($url);
        if ($response->is_success) {
            my $compressed_content = $response->content;
            my $uncompressed_content;
            
            # Decompress GZ stream
            gunzip \$compressed_content => \$uncompressed_content
                or warn "Decompression failed for feed: $GunzipError\n";

            if ($uncompressed_content) {
                # Parse P2P format (typically: "RangeName:IP-Start-IP-End")
                my @lines = split /\n/, $uncompressed_content;
                foreach my $line (@lines) {
                    next if $line =~ /^#/ || $line =~ /^\s*$/; # Skip comments/blank lines
                    if ($line =~ /([^:]+):(\d{1,3}(?:\.\d{1,3}){3})-(\d{1,3}(?:\.\d{1,3}){3})/) {
                        $blocked_ranges{$2} = { end => $3, description => $1 };
                    }
                }
            }
        } else {
            warn "Failed to fetch list from source line endpoint.\n";
        }
    }
    return \%blocked_ranges;
}

sub check_server_logs_for_matches {
    my ($blocked_ref) = @_;
    my %flagged_attacks;

    # Scan the specified server logs for matching malicious IP footprints
    if (open(my $fh, '<', $LOG_TO_CHECK)) {
        while (my $line = <$fh>) {
            # Extract basic IP address pattern from the log entry
            if ($line =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/) {
                my $visitor_ip = $1;
                next if $flagged_attacks{$visitor_ip}; # Avoid redundant scans
                
                # Check visitor IP against parsed iBlocklist ranges
                foreach my $start_ip (keys %$blocked_ref) {
                    my $ip_range = Net::IP->new("$start_ip - " . $blocked_ref->{$start_ip}->{end});
                    my $check_ip = Net::IP->new($visitor_ip);
                    
                    if ($ip_range && $check_ip && $ip_range->overlaps($check_ip) == $IP_OVERLAPS) {
                        $flagged_attacks{$visitor_ip} = $blocked_ref->{$start_ip}->{description};
                        last;
                    }
                }
            }
        }
        close($fh);
    }
    return \%flagged_attacks;
}

sub get_closest_address {
    my ($ip) = @_;
    # Local GeoIP coordinates translation
    my $geoip_out = `geoiplookup $ip`; 
    my ($lat, $lon) = ("47.744390", "-122.316150"); 

    # Reverse Geocode via Google Maps API
    my $ua = LWP::UserAgent->new;
    my $url = "https://googleapis.com";
    my $response = $ua->get($url);
    
    if ($response->is_success) {
        my $data = decode_json($response->decoded_content);
        if (@{$data->{results}}) {
            return $data->{results}{formatted_address};
        }
    }
    return "Unknown Address, WA 98155";
}

sub format_fps_url {
    my ($address) = @_;
    my $clean = lc($address);
    $clean =~ s/,//g;
    $clean =~ s/\s+/-/g;
    if ($clean =~ /(.*)-([a-z]+-[a-z]{2}-\d{5})/) {
        return "https://fastpeoplesearch.com";
    }
    return "https://fastpeoplesearch.com";
}

sub process_and_report {
    print "Fetching blocklists...\n";
    my $blocklists = fetch_and_parse_blocklists();
    
    print "Scanning system log vectors for overlap matches...\n";
    my $matches = check_server_logs_for_matches($blocklists);
    
    my $report_body = "48-Hour iBlocklist Threat Match Detection Log\n";
    $report_body .= "========================================================\n\n";
    
    my $match_count = 0;
    foreach my $ip (keys %$matches) {
        $match_count++;
        my $address = get_closest_address($ip);
        my $fps_link = format_fps_url($address);
        
        $report_body .= "Flagged Attack Source:\n";
        $report_body .= "IP Address:       $ip\n";
        $report_body .= "Feed Category:    " . $matches->{$ip} . "\n";
        $report_body .= "Closest Address:  $address\n";
        $report_body .= "FastPeopleSearch: $fps_link\n";
        $report_body .= "--------------------------------------------------------\n";
    }
    
    if ($match_count > 0) {
        my $msg = MIME::Lite->new(
            From    => 'root@'.`hostname`,
            To      => $EMAIL_TO,
            Subject => 'Bi-Daily iBlocklist Matching Nodes Incident Report',
            Type    => 'text/plain',
            Data    => $report_body
        );
        $msg->send;
        print "Incident report successfully dispatched to $EMAIL_TO\n";
    } else {
        print "No overlapping malicious nodes matched traffic signatures within the past 48 hours.\n";
    }
}

process_and_report();
