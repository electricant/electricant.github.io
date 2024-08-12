# Guide to Configuring Dynamic DNS with BIND9 Using TSIG Keys

This guide will walk you through the process of setting up dynamic DNS updates
in BIND9 [\[1\]][1] using a TSIG key.

Previously, the most common authentication method for BIND was to use SIG(0)
for authentication [\[2\]][2], but SIG(0) support has been removed from BIND9. SIG(0) is
an older method of authenticating DNS updates, and BIND9 no longer supports it
in favor of TSIG [\[3\]][3].

I learned this the hard way since my dynamic DNS update script was no longer
working and I could not understand why. Enabling further debug messages
[\[4\]][4] revealed the following:

    request has a SIG(0) signature but its support was removed

So I had to generate a new key and copy it to both the server and client.

## Step 1: Generate a TSIG Key

TSIG works by using a shared secret key and a hashing algorithm to create a
digital signature for each DNS message. Both the client and server must have
the same TSIG key. When a message is sent, the TSIG key generates a signature
that is included with the message. The receiving party then uses the same key
to verify the signature.

Use the **tsig-keygen** [\[5\]][5] command to generate a TSIG key and save it
into a file for later use.

    # tsig-keygen -a HMAC-SHA256 ddns-key.example.com > ddns.key 

This command will generate a key similar to the following:

    # cat ddns.key
    key "ddns-key.example.com." {
        algorithm hmac-sha256;
        secret "3b52KtNNE87pIHmZkA3bN7Gc5MZK/zAHg0OShp1PvZI=";
    };

Where:
* **ddns-key.example.com**: This is the name of the key.
* **HMAC-SHA256**: The algorithm used for the key.
* **secret**: The actual secret key generated.

## Step 2: Configure BIND9 to Use the TSIG Key

I like to keep the keys in my named.conf.options file separated from the zone
definitions in named.conf.local.

To allow dynamic updates using the TSIG key, open the BIND9 configuration file:

	# sudo vim /etc/bind/named.conf.options

Add the TSIG key configuration:
    
	key "ddns-key.example.com." {
		algorithm hmac-sha256;
		secret "3b52KtNNE87pIHmZkA3bN7Gc5MZK/zAHg0OShp1PvZI=";
	};
	
Save and exit the configuration file.

Then, configure the zone (in /etc/bind/named.conf.local) to allow updates
using the TSIG key:

    zone "example.com" IN {
        type master;
        file "/etc/bind/db.example.com";
        allow-update { key "ddns-key.example.com."; };
    };

## Step 3: Restart BIND9

Apply the changes by restarting the BIND9 service.

    # sudo systemctl restart named

## Step 4: Testing Dynamic DNS Updates

According to the **nsupdate** man file [\[6\]][6], when using the -k option,
nsupdate reads the shared secret from a key file. This key file can be in one
of two formats:

1. **Named.conf-style format**: looks like a BIND configuration file,
containing the key definition within curly braces. This format matches the
syntax you'd find in BIND's configuration files (like named.conf). When using
this format, the key file contains a full key definition.

2. **Raw secret format**: contains just the raw base64-encoded
secret without any additional configuration statements. This format is simpler
but requires you to specify the key name and algorithm directly in the
**nsupdate** command.

If you followed **Step 1** thoroughly, the key is already saved in ddns.key file
with the named.conf-style format. Therefore, it is sufficient to use nsupdate as
usual with the option -k ddns.key.

## References

<div class="references">
\[1\] [DNS Dynamic Update](1)
[1]: https://docstore.mik.ua/orelly/networking_2ndEd/dns/ch10_02.htm

\[2\] [Doing secure dynamic DNS updates with BIND](2)
[2]: https://blog.hqcodeshop.fi/archives/76-Doing-secure-dynamic-DNS-updates-with-BIND.html

\[3\] [Security Configurations - TSIG](3)
[3]: https://bind9.readthedocs.io/en/v9.18.13/chapter7.html#tsig

\[4\] [BIND Configuration File Guide -- logging Statement](4)
[4]: https://web.mit.edu/darwin/src/modules/bind/bind/doc/html/logging.html

\[5\] [tsig-keygen(8)](5)
[5]: https://manpages.debian.org/testing/bind9/tsig-keygen.8.en.html

\[6\] [nsupdate(1)](6)
[6]: https://www.linux.org/docs/man1/nsupdate.html
</div>
