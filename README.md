# porn-proxyfy

Hide your traffic through [TURN](https://en.wikipedia.org/wiki/Traversal_Using_Relays_around_NAT) servers from biggest porn providers

## How it works?

It will use the existing project called [turner](https://github.com/staaldraad/turner) and the gathered WebRTC servers from biggest porn providers.

It is based on my previous research about serious security weakness in biggest adult streaming platforms. You can find it [here](https://github.com/DgSe95/stream-capture-poc) and a `CLI` tool based on the same research here [here](https://github.com/DgSe95/porn-dump-cli).

## Why?

Because I think it's another way to raise attention about how security should taken seriously and not just as an extra layer that you can add later on any projects.

Thinking that nobody will take a look at exchanged `XHR` requests and not analyze `JSON` payloads appearing is simply a stupid move.

Next, applying the same weak credentials on every servers is just insane!!

So, don't feel surprised that one day someone will discover and abuse of them for sure!

## Installation

```bash
# Install 'jq'
sudo apt install -y jq

# Clone the repo
git clone https://github.com/DgSe95/porn-proxyfy.git
cd porn-proxyfy
chmod -v +x porn-proxyfy.sh

# Clone the 'turner' repo and build it
git clone https://github.com/staaldraad/turner.git
cd turner
go build
```

> __You must have `golang` already installed to build and use `turner`.__

## Usage

* First terminal session

```bash
# Get help
./porn-proxyfy -h

# Start TURN proxy
./porn-proxyfy
```

* Second terminal session

```bash
# Real IP
curl -s https://api.myip.com | jq .

# TURN proxy IP (HTTP)
curl -sx http://localhost:8080 https://api.myip.com | jq .

# TURN proxy IP (SOCKS5)
curl -s --socks5 socks5://localhost:8000 https://api.myip.com | jq .
```

## Example

* First terminal session

```
./porn-proxyfy

porn-proxyfy

Hide your traffic through TURN servers from biggest porn providers
Made with some THC by DgSe95

Running TURN socks/http proxy on [REDACTED:2083]...

Press [Ctrl + C] to exit.

[*] Starting SOCKS5 Server on 127.0.0.1:8000
[*] Starting HTTP Server on 127.0.0.1:8080
[*] Dial server [REDACTED]:42608 -> [REDACTED]:2083
[*] Create peer permission
[*] Create TCP Session Connection
[*] Create connect request
[*] Create bind TCP connection
[*] Auth and Create client 
[*] Bind client 
[*] Bound
[*] Dial server [REDACTED]:42756 -> [REDACTED]:2083
[*] Create peer permission
[*] Create TCP Session Connection
[*] Create connect request
[*] Create bind TCP connection
[*] Auth and Create client 
[*] Bind client 
[*] Bound
```

* Second terminal session

```bash
# Real IP
curl -s https://api.myip.com | jq .
{
  "ip": "[REDACTED]",
  "country": "[REDACTED]",
  "cc": "[REDACTED]"
}

# TURN proxy IP (HTTP)
curl -sx http://localhost:8080 https://api.myip.com | jq .
{
  "ip": "[REDACTED]",
  "country": "Netherlands",
  "cc": "NL"
}

# TURN proxy IP (SOCKS5)
curl -s --socks5 socks5://localhost:8000 https://api.myip.com | jq .
{
  "ip": "[REDACTED]",
  "country": "Netherlands",
  "cc": "NL"
}
```

> Tested successfully with `curl` and `proxychains4`.

## Known Issues

If you get the following error:

```
[*] Starting SOCKS5 Server on 127.0.0.1:8000
[*] Starting HTTP Server on 127.0.0.1:8080
lookup [REDACTED]: no such host
[x] error setting up STUN lookup [REDACTED]: no such host
```

Simply kill and reload the script, it will select another server :wink:

## Disclaimer

Made for the fun and because it's really not serious to use weak default credentials, use them as template for all available servers...

Additionally, make this kind of information as part of the API without prior authentication is simply making the job much easier to get them :rofl:

## Credits

Author: [@DgSe95](https://twitter.com/DgSe95)
