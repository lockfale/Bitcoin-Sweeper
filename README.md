Bitcoin-Sweeper
===============

Generating private keys from passphrases, checking transactions and ballances. Sweeping bitcoins by importing private keys into blockchain wallet.

#### Donations
Donations are welcome & appreciated!

1MMN4rQkvfzjXrHU159bhJVPgPmQjTL5RG

#### Usage
```
Usage: perl btc_sweeper.pl -w[wordlist] -t[threads] -o[output]
perl btc_sweeper.pl -w pass.txt -t 10 -o output.txt
```
#### Overview

BITCOIN Sweeper is simple tool written in Perl.
It could be used to generate bitcoin private keys from passphrases
and check transtactions/balance.

#### Example
```
      ___  _ ___ ____ ____ _ _  _ 
      |__] |  |  |    |  | | |\ |
      |__] |  |  |___ |__| | | \|          
  ____ _ _ _ ____ ____ ___  ____ ____
  [__  | | | |___ |___ |__] |___ |__/
  ___] |_|_| |___ |___ |    |___ |  \

[i] Generating Private Keys.
[i] Checking transactions.
[i] Please wait ...

[i] Processing: 100/100
[i] Wallets with transactions: 4
[i] Total received: 0.0002184 BTC

[i] Wallets with balance: 0
[i] Total balance: 0 BTC

[i] Saving to: output.txt
[i] Writing output ...

[x] Done.
```

#### Output
```
18X6yC1p1hXvXjuwZfjT52Z1am9LNuAAC6, Passphrase: appointive
18X6yC1p1hXvXjuwZfjT52Z1am9LNuAAC6, Received: 0.00005460
18X6yC1p1hXvXjuwZfjT52Z1am9LNuAAC6, PrivateKey: 5JhijED9PdJHxBhAqFW3kWaJRkvckFsLY7jou4BmqnEmzf5WMHf
18X6yC1p1hXvXjuwZfjT52Z1am9LNuAAC6, Balance: 0

1AW3C1pC7r8LgWQbHFfEW8XjB5e8tfYc1A, Passphrase: exacerbate
1AW3C1pC7r8LgWQbHFfEW8XjB5e8tfYc1A, Received: 0.00005460
1AW3C1pC7r8LgWQbHFfEW8XjB5e8tfYc1A, PrivateKey: 5JGhAhbVZwegbTVZYqxTLFCuXRXxDJMFfwfWcisMhVRtQfXxFyL
1AW3C1pC7r8LgWQbHFfEW8XjB5e8tfYc1A, Balance: 0

1DYmfSvaXdaFMjA7qsuQMgs82tKuderViS, Passphrase: accentuating
1DYmfSvaXdaFMjA7qsuQMgs82tKuderViS, Received: 0.00005460
1DYmfSvaXdaFMjA7qsuQMgs82tKuderViS, PrivateKey: 5JxeYPjzzfG6sGoRXEQunWPo7Skv8Mt17ZvcfHHDXJzVLn7sDWL
1DYmfSvaXdaFMjA7qsuQMgs82tKuderViS, Balance: 0

1LBG3NrauAGidWWNAUVX1AkkViFwyuAytU, Passphrase: forgiveness
1LBG3NrauAGidWWNAUVX1AkkViFwyuAytU, Received: 0.00005460
1LBG3NrauAGidWWNAUVX1AkkViFwyuAytU, PrivateKey: 5JTBdKSeLsyPDSMfXvYE9FdAsjXV7k6GBrhxXLEdUtj477P8qPA
1LBG3NrauAGidWWNAUVX1AkkViFwyuAytU, Balance: 0
```

#### Installation
```
root@btc-sweeper:~# uname -a
Linux btc-sweeper 3.13.0-37-generic #64-Ubuntu SMP Mon Sep 22 21:28:38 UTC 2014 x86_64 x86_64 x86_64 GNU/Linux
root@btc-sweeper:~#
root@btc-sweeper:~# wget https://github.com/vavkamil/Bitcoin-Sweeper/archive/master.zip
root@btc-sweeper:~# apt-get install unzip
root@btc-sweeper:~# unzip master.zip
root@btc-sweeper:~# cd Bitcoin-Sweeper-master/
root@btc-sweeper:~/Bitcoin-Sweeper-master# apt-get install libwww-mechanize-perl
root@btc-sweeper:~/Bitcoin-Sweeper-master# apt-get install build-essential
root@btc-sweeper:~/Bitcoin-Sweeper-master# apt-get install python-ecdsa
root@btc-sweeper:~/Bitcoin-Sweeper-master# apt-get install cpanminus
root@btc-sweeper:~/Bitcoin-Sweeper-master# cpanm Finance::Bitcoin::API
root@btc-sweeper:~/Bitcoin-Sweeper-master# cpanm Parallel::ForkManager
root@btc-sweeper:~#
root@btc-sweeper:~/Bitcoin-Sweeper-master# perl btc_sweeper.pl 
      ___  _ ___ ____ ____ _ _  _ 
      |__] |  |  |    |  | | |\ |
      |__] |  |  |___ |__| | | \|          
  ____ _ _ _ ____ ____ ___  ____ ____
  [__  | | | |___ |___ |__] |___ |__/
  ___] |_|_| |___ |___ |    |___ |  \

Usage: perl btc_sweeper.pl -w pass.txt -t 10 -o output.txt

root@btc-sweeper:~/Bitcoin-Sweeper-master# 
```

#### TODO

Import private keys to blockchain wallet via RCP.<br>
Revrite keyfmt.py to Perl
