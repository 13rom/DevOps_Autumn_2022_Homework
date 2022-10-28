## LINUX BASH TASK

### Part A
Create a script that uses the following keys:
1. When starting without parameters, it will display a list of possible keys and their description.

    ```console
    $ ./netscan

    NAME
        netscan - Check network host/port availability

    SYNOPSIS
        netscan --option <target>

    DESCRIPTION
        Scan a given network for available hosts or scan given host for
        available ports.

        --all
              Output every available host ip in a <target> subnet.

        --target
              Output every opened port on a <target> host IP.

        --help
              Output this documentation.

    EXAMPLES
        netscan --all 192.168.0.0/24
            Find all online hosts in the 192.168.0.0/24 subnet.

        netscan --all 192.168.12.107/24
            Find all online hosts in the 192.168.12.0/24 subnet.

        netscan --target 192.168.0.43
            Find all available port on a target host.
    ```

2. The --all key displays the IP addresses and symbolic names of all hosts in the current subnet

    ```console
    $ ./netscan --all 192.168.1.0/24
    192.168.1.1 _gateway.
    192.168.1.5 server.ix.ua.
    192.168.1.101 3(NXDOMAIN)
    192.168.1.102 latitude-laptop.
    192.168.1.103 3(NXDOMAIN)
    192.168.1.108 3(NXDOMAIN)
    192.168.1.132 3(NXDOMAIN)
    ```

3. The --target key displays a list of open system TCP ports.
The code that performs the functionality of each of the subtasks must be placed in a separate function

    ```console
    $ ./netscan --target 192.168.1.1
    22 opened
    23 opened
    53 opened
    80 opened
    139 opened
    443 opened
    445 opened
    1723 opened
    3517 opened
    3702 opened
    ```


----
Two versions of the script were created: [`netscan`](netscan) and [`netscan-ng`](netscan-ng) - the shorter and faster version with parallel scanning.

[`netscan`](netscan):

```bash
#!/usr/bin/env bash
#
# NAME
#    netscan - Check network host/port availability
#
# SYNOPSIS
#    netscan --option <target>
#
# DESCRIPTION
#    Scan a given network for available hosts or scan given host for
#    available ports.
#
#    --all
#           Output every available host ip in a <target> subnet.
#
#    --target
#           Output every opened port on a <target> host IP.
#
#    --help
#           Output this documentation.
#
# EXAMPLES
#    netscan --all 192.168.0.0/24
#        Find all online hosts in the 192.168.0.0/24 subnet.
#
#    netscan --all 192.168.12.107/24
#        Find all online hosts in the 192.168.12.0/24 subnet.
#
#    netscan --target 192.168.0.43
#        Find all available port on a target host.
#
################################################################################

usage() {
    while IFS= read -r line || [[ -n "$line" ]]
    do
        case "$line" in
            '#!'*) # Shebang line
                ;;
            ''|'##'*|[!#]*) # End of Help block
                exit "${1:-0}"
                ;;
            *) # Help line
                printf '%s\n' "${line:1}"
                ;;
        esac
    done < "$0"
}

ipvalid() {
  # Set up local variables
  local ip=${1:-1.2.3.4}
  local IFS=.; local -a a=($ip)
  # Start with a regex format test
  [[ $ip =~ ^[0-9]+(\.[0-9]+){3}$ ]] || return 1
  # Test values of quads
  local quad
  for quad in {0..3}; do
    [[ "${a[$quad]}" -gt 255 ]] && return 1
  done
  return 0
}

ip2int() {
    local a b c d
    { IFS=. read a b c d; } <<< $1
    echo $(((((((a << 8) | b) << 8) | c) << 8) | d))
}

int2ip() {
    local ui32=$1; shift
    local ip n
    for n in 1 2 3 4; do
        ip=$((ui32 & 0xff))${ip:+.}$ip
        ui32=$((ui32 >> 8))
    done
    echo $ip
}

# Example: netmask 24 => 255.255.255.0
netmask() {
    local mask=$((0xffffffff << (32 - $1))); shift
    int2ip $mask
}

# Example: broadcast 192.0.2.0 24 => 192.0.2.255
broadcast() {
    local addr=$(ip2int $1); shift
    local mask=$((0xffffffff << (32 -$1))); shift
    int2ip $((addr | ~mask))
}

# Example: network 192.0.2.0 24 => 192.0.2.0
network() {
    local addr=$(ip2int $1); shift
    local mask=$((0xffffffff << (32 -$1))); shift
    int2ip $((addr & mask))
}


scan-ip() {
    local firstip=$(network "$1" "$2")
    local lastip=$(broadcast "$firstip" "$2")
    #echo "Scan range: $firstip .. $lastip"

    IFS=. read -r f1 f2 f3 f4 <<< "$firstip"
    IFS=. read -r l1 l2 l3 l4 <<< "$lastip"

    for ip2 in $(seq "$f2" "$l2"); do
        for ip3 in $(seq "$f3" "$l3"); do
            for ip4 in $(seq "$f4" "$l4"); do
                ipaddr="$f1"."$ip2"."$ip3"."$ip4"
                ping -c1 -t1 -W1 "$ipaddr" &>/dev/null && echo "$ipaddr $(host "$ipaddr" | awk '{ print $5 }')"
            done
        done
    done
}

scan-port() {
    for port in {0..65535}; do
        #(echo >/dev/tcp/${1}/${port}) &>/dev/null && echo "$port opened" #|| echo "$port closed"
        timeout 1 bash -c "echo >/dev/tcp/${1}/${port}" &>/dev/null && echo "$port opened" 
    done
}


if [[ $# -lt 2 ]]; then
    usage 13
fi

case "$1" in
    --all)
        # 192.168.0.0/24
        IFS=/ read -r scanip scanmask <<< "$2"
        ipvalid "$scanip" || exit 1
        [ $scanmask -ge 32 ] || [ $scanmask -le 0 ] && exit 1
        scan-ip "$scanip" "$scanmask"
    ;;

    --target)
        ipvalid "$2" || exit 1
        scan-port "$2"
    ;;

    *)
        usage 13
    ;;
esac

```


### Part B
Using Apache log example create a script to answer the following questions:
1. From which ip were the most requests?

    ```console
    $ ./logstat example_log.log 
    1) From which ip were the most requests?      4) What non-existent pages were clients referred to?
    2) What is the most requested page?           5) What time did site get the most requests?
    3) How many requests were there from each ip? 6) What search bots have accessed the site? (UA + IP)
    Please enter your choice: 1
    94.78.95.154
    ```

2. What is the most requested page?

    ```console
    $ ./logstat example_log.log 
    1) From which ip were the most requests?      4) What non-existent pages were clients referred to?
    2) What is the most requested page?           5) What time did site get the most requests?
    3) How many requests were there from each ip? 6) What search bots have accessed the site? (UA + IP)
    Please enter your choice: 2
    /wp-content/uploads/2014/11/favicon.ico
    ```

3. How many requests were there from each ip?

    ```console
    $ ./logstat example_log.log 
    1) From which ip were the most requests?      4) What non-existent pages were clients referred to?
    2) What is the most requested page?           5) What time did site get the most requests?
    3) How many requests were there from each ip? 6) What search bots have accessed the site? (UA + IP)
    Please enter your choice: 3
        29 94.78.95.154
        21 95.31.14.165
        19 176.108.5.105
        16 31.7.230.210
        14 144.76.76.115
        12 217.69.133.239
        <...>
    ```

4. What non-existent pages were clients referred to?

    ```console
    $ ./logstat example_log.log 
    1) From which ip were the most requests?      4) What non-existent pages were clients referred to?
    2) What is the most requested page?           5) What time did site get the most requests?
    3) How many requests were there from each ip? 6) What search bots have accessed the site? (UA + IP)
    Please enter your choice: 4
    /
    /apple-touch-icon.png
    /apple-touch-icon-precomposed.png
    /backup/info.php
    /.bash_history
    /.bzr/branch-format
    /ehsteticheskaya-medicina/injekcii/biorevitalizaciya/preparaty-dlya-biorevitalizacii.html/register.aspx
    /ehsteticheskaya-medicina/injekcii/biorevitalizaciya/register.aspx
    /ehsteticheskaya-medicina/injekcii/register.aspx
    /ehsteticheskaya-medicina/register.aspx
    /.git/config
    /google89150ef520da50eb.html
    /.hg/hgrc
    /LISU.ttf
    /LISU.woff
    /otzivi-obzori/yuviderm-otzivi-obzori/yuviderm-ne-ochen-dovolna-22-goda.html
    /register.aspx
    /rtc_wizard_index.htm
    /.svn/format
    /.svn/wc.db
    /sxd/info.php
    /ukhod-z
    /ukhod-za-soboj/pokhudenie/dieti/dieta-grechnevaya-s-kefirom.html%D1%87%D0%B8%D1%82%D0%B0%D0%B9
    /ukhod-za-soboj/pokhudenie/dieti/map.css
    /wp-content/plugins/stats-counter/img/icon.png
    /wp-content/themes/cassia/css/fonts/flexslider-icon.eot?
    /wp-content/themes/cassia/css/fonts/flexslider-icon.svg
    /wp-content/themes/cassia/css/fonts/flexslider-icon.ttf
    /wp-content/themes/cassia/css/fonts/flexslider-icon.woff
    ```

5. What time did site get the most requests?

    ```console
    $ ./logstat example_log.log 
    1) From which ip were the most requests?      4) What non-existent pages were clients referred to?
    2) What is the most requested page?           5) What time did site get the most requests?
    3) How many requests were there from each ip? 6) What search bots have accessed the site? (UA + IP)
    Please enter your choice: 5
    11:36
    ```

6. What search bots have accessed the site? (UA + IP)

    ```console
    $ ./logstat example_log.log 
    1) From which ip were the most requests?      4) What non-existent pages were clients referred to?
    2) What is the most requested page?           5) What time did site get the most requests?
    3) How many requests were there from each ip? 6) What search bots have accessed the site? (UA + IP)
    Please enter your choice: 6
    136.243.34.71 - Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)
    144.76.76.115 - Mozilla/5.0 (compatible; MJ12bot/v1.4.7; http://mj12bot.com/)
    164.132.161.40 - Mozilla/5.0 (compatible; AhrefsBot/5.2; +http://ahrefs.com/robot/)
    164.132.161.63 - Mozilla/5.0 (compatible; AhrefsBot/5.2; +http://ahrefs.com/robot/)
    164.132.161.85 - Mozilla/5.0 (compatible; AhrefsBot/5.2; +http://ahrefs.com/robot/)
    198.148.27.10 - Pulsepoint XT3 web scraper
    199.16.157.182 - Twitterbot/1.0
    207.46.13.109 - Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)
    207.46.13.128 - Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)
    207.46.13.3 - Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)
    209.126.120.83 - admantx-usastn/2.4 (+http://www.admantx.com/service-fetcher.html)
    209.126.120.97 - admantx-usastn/2.4 (+http://www.admantx.com/service-fetcher.html)
    213.186.1.210 - Mediatoolkitbot (complaints@mediatoolkit.com)
    213.186.8.43 - Mediatoolkitbot (complaints@mediatoolkit.com)
    217.182.132.183 - Mozilla/5.0 (compatible; AhrefsBot/5.2; +http://ahrefs.com/robot/)
    217.197.112.84 - SeopultContentAnalyzer/1.0
    217.69.133.234 - Mozilla/5.0 (compatible; Linux x86_64; Mail.RU_Bot/2.0; +http://go.mail.ru/help/robots)
    217.69.133.235 - Mozilla/5.0 (compatible; Linux x86_64; Mail.RU_Bot/2.0; +http://go.mail.ru/help/robots)
    217.69.133.236 - Mozilla/5.0 (compatible; Linux x86_64; Mail.RU_Bot/2.0; +http://go.mail.ru/help/robots)
    217.69.133.237 - Mozilla/5.0 (compatible; Linux x86_64; Mail.RU_Bot/2.0; +http://go.mail.ru/help/robots)
    217.69.133.238 - Mozilla/5.0 (compatible; Linux x86_64; Mail.RU_Bot/2.0; +http://go.mail.ru/help/robots)
    217.69.133.239 - Mozilla/5.0 (compatible; Linux x86_64; Mail.RU_Bot/2.0; +http://go.mail.ru/help/robots)
    217.69.133.240 - Mozilla/5.0 (compatible; Linux x86_64; Mail.RU_Bot/2.0; +http://go.mail.ru/help/robots)
    217.69.133.70 - Mozilla/5.0 (compatible; Linux x86_64; Mail.RU_Bot/2.0; +http://go.mail.ru/help/robots)
    217.69.134.12 - Mozilla/5.0 (compatible; Linux x86_64; Mail.RU_Bot/Fast/2.0; +http://go.mail.ru/help/robots)
    217.69.134.13 - Mozilla/5.0 (compatible; Linux x86_64; Mail.RU_Bot/Fast/2.0; +http://go.mail.ru/help/robots)
    217.69.134.14 - Mozilla/5.0 (compatible; Linux x86_64; Mail.RU_Bot/Fast/2.0; +http://go.mail.ru/help/robots)
    217.69.134.15 - Mozilla/5.0 (compatible; Linux x86_64; Mail.RU_Bot/Fast/2.0; +http://go.mail.ru/help/robots)
    217.69.134.29 - Mozilla/5.0 (compatible; Linux x86_64; Mail.RU_Bot/Fast/2.0; +http://go.mail.ru/help/robots)
    217.69.134.30 - Mozilla/5.0 (compatible; Linux x86_64; Mail.RU_Bot/Fast/2.0; +http://go.mail.ru/help/robots)
    217.69.134.39 - Mozilla/5.0 (compatible; Linux x86_64; Mail.RU_Bot/Fast/2.0; +http://go.mail.ru/help/robots)
    40.77.167.19 - Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)
    40.77.167.19 - Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)
    40.77.167.19 - msnbot-media/1.1 (+http://search.msn.com/msnbot.htm)
    5.135.154.105 - SentiBot www.sentibot.eu (compatible with Googlebot)
    5.255.251.28 - Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots)
    66.249.66.194 - Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)
    66.249.66.199 - Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)
    66.249.66.199 - Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.96 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)
    66.249.66.204 - Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)
    66.249.92.197 - Mediapartners-Google
    66.249.92.197 - Mozilla/5.0 (compatible; Google-Site-Verification/1.0)
    66.249.92.199 - Mediapartners-Google
    66.249.92.199 - Mozilla/5.0 (compatible; Google-Site-Verification/1.0)
    89.145.95.69 - Mozilla/5.0 (compatible; GrapeshotCrawler/2.0; +http://www.grapeshot.co.uk/crawler.php)
    89.145.95.80 - Mozilla/5.0 (compatible; GrapeshotCrawler/2.0; +http://www.grapeshot.co.uk/crawler.php)
    91.121.209.185 - SentiBot www.sentibot.eu (compatible with Googlebot)
    ```


----
[`logstat`](logstat):

```bash
#!/usr/bin/env bash
#
# NAME
#    logstat - Get statistics from given apache log file
#
# SYNOPSIS
#    logstat <filename.log>
#
################################################################################

usage() {
    while IFS= read -r line || [[ -n "$line" ]]
    do
        case "$line" in
            '#!'*) # Shebang line
                ;;
            ''|'##'*|[!#]*) # End of Help block
                exit "${1:-0}"
                ;;
            *) # Help line
                printf '%s\n' "${line:1}"
                ;;
        esac
    done < "$0"
}


if [[ $# -lt 1 ]]; then
    usage 13
fi

options=("From which ip were the most requests?" \
         "What is the most requested page?" \
         "How many requests were there from each ip?" \
         "What non-existent pages were clients referred to?" \
         "What time did site get the most requests?" \
         "What search bots have accessed the site? (UA + IP)"
)
PS3="Please enter your choice: "
select opt in "${options[@]}"; do
    case $REPLY in
        1)
            awk '{ print $1 }' $1 | sort -g | uniq -c | sort -nr | head -1 | awk '{ print $2 }'
            break
        ;;
        2)
            awk '{ print $7 }' $1 | sort | uniq -c | sort -nr | head -1 | awk '{ print $2 }'
            break
        ;;
        3)
            awk '{ print $1 }' $1 | sort -g | uniq -c | sort -nr
            break
        ;;
        4)
            awk '$9 == "404" { print $7 }' $1 | sort | uniq
            break
        ;;
        5)
            awk '{ print $4 }' $1 | cut -d":" -f2,3 | uniq -c | sort -nr | head -1 | awk '{ print $2 }'
            break
        ;;
        6)
            awk -F'"' '{ print $1 $(NF-1) }' $1 | grep -iE "(Google|bot|fetcher|analyzer|scraper|crawler)" | sed 's/\- \[[^]]*\] //g' | sort | uniq
            break
        ;;
        *) echo "Invalid option $REPLY";;
    esac
    
done
```


### Part C
Create a data backup script that takes the following data as parameters:
1. Path to the syncing directory.
2. The path to the directory where the copies of the files will be stored.
In case of adding new or deleting old files, the script must add a corresponding entry to the log file
indicating the time, type of operation and file name. [The command to run the script must be added to
crontab with a run frequency of one minute]

```console
$ tree source destination
source
├── file1
├── file2
├── test
│   ├── file4
│   ├── file5
│   └── file7
└── test2
    └── file
destination [error opening dir]

2 directories, 6 files

$ crontab -l | grep user
* * * * * /home/user/bin/backup /home/user/source/ /home/user/destination/

$ cat /var/log/backup/backup.log
[2021/12/26-15:35:01] Add dir /test
[2021/12/26-15:35:01] Add dir /test2
[2021/12/26-15:35:01] Copy file /file1
[2021/12/26-15:35:01] Copy file /file2
[2021/12/26-15:35:01] Copy file /test/file4
[2021/12/26-15:35:01] Copy file /test/file5
[2021/12/26-15:35:01] Copy file /test/file7
[2021/12/26-15:35:01] Copy file /test2/file

$ rm -r source/test2

$ tree source destination
source
├── file1
├── file2
└── test
    ├── file4
    ├── file5
    └── file7
destination
├── file1
├── file2
└── test
    ├── file4
    ├── file5
    └── file7

2 directories, 10 files

$ cat /var/log/backup/backup.log
[2021/12/26-15:35:01] Add dir /test
[2021/12/26-15:35:01] Add dir /test2
[2021/12/26-15:35:01] Copy file /file1
[2021/12/26-15:35:01] Copy file /file2
[2021/12/26-15:35:01] Copy file /test/file4
[2021/12/26-15:35:01] Copy file /test/file5
[2021/12/26-15:35:01] Copy file /test/file7
[2021/12/26-15:35:01] Copy file /test2/file
[2021/12/26-15:36:01] Remove file /test2/file
[2021/12/26-15:36:01] Remove dir /test2
```

----
[`backup`](backup):
```bash
#!/usr/bin/env bash
#
# NAME
#    backup - Make backup of files in a given directory
#
# SYNOPSIS
#    backup <sourcedir> <destdir>
#
# DESCRIPTION
#    Sync files between source and destination directories.
#   
#    <sourcedir> and <destdir>
#           Relative or absolute path to a directory
#    --help
#           Output this documentation.
#
# EXAMPLES
#    backup /home/user/sourcedir /home/user/backup/destdir
#
################################################################################

usage() {
    while IFS= read -r line || [[ -n "$line" ]]
    do
        case "$line" in
            '#!'*) # Shebang line
                ;;
            ''|'##'*|[!#]*) # End of Help block
                exit "${1:-0}"
                ;;
            *) # Help line
                printf '%s\n' "${line:1}"
                ;;
        esac
    done < "$0"
}


# printlog <operation type> <target>
printlog() {
    echo "[$(date "+%Y/%m/%d-%H:%M:%S")] $1 $2" | tee -a "$logfile" 
}


# dircmp <srcdir> <dstdir> <filelist>
dircmp () {
    local list=$3
    local file
    for file in $list; do
        if [ -d "$1$file" ] && ! [ -d "$2$file" ]; then
            echo "$file"
        fi
    done
}


# filecmp <srcdir> <dstdir> <filelist>
filecmp () {
    local list=$3
    local file
    for file in $list; do
        if [ -f "$1$file" ]; then
            cmp "$1$file" "$2$file" &> /dev/null
            if [ $? -ne 0 ]; then
                echo "$file"
            fi
        fi
    done
}


# dobackup <scrdir> <dstdir>
dobackup () {
    local list
    local filename

    list=$(tree -if --noreport "$1" | sed "s!$1!!")

    dircmp "$1" "$2" "$list" | while read filename; do
        printlog "Add dir" "$filename"
        mkdir "$2$filename"
    done
    filecmp "$1" "$2" "$list" | while read filename; do
        printlog "Copy file" "$filename"
        cp -a "$1$filename" "$2$filename"
    done

    list=$(tree -if --noreport "$2" | sed "s!$2!!")

    filecmp "$2" "$1" "$list" | while read filename; do
        printlog "Remove file" "$filename"
        rm -f "$2$filename"
    done
    dircmp "$2" "$1" "$list" | while read filename; do
        printlog "Remove dir" "$filename"
        rmdir "$2$filename"
    done
}



if [[ $# -lt 2 ]]; then
    usage 13
fi

# Variables initialization
logdir=/var/log/backup
logfile=${logdir}/backup.log

srcdir="${1%/}"
dstdir="${2%/}"

# Create directories
if ! [ -d "$dstdir" ]; then mkdir "$dstdir"; fi
if ! [ -d "$logdir" ]; then mkdir "$logdir"; fi

dobackup "$srcdir" "$dstdir"
```