TURN Server Management Guide
---

### Base Server Installation
An Amazon AMI has been set up in the US West (Oregeon) zone that can be found by searching community images for "rfc5766-turn-server"

This community AMI should be used as a base when launching an EC2 image and includes a fully deployed TURN server.  The default credentials it provides are all outlined at http://turnserver.open-sys.org/downloads/v3.2.3.4/turnserver-3.2.3.4-amazon-aws-ec2-x86_64.txt and can be used for initial testing.  Before production use, default users should be removed and the database credentials changed to more secure values.

Once the AMI instance has been launched, the ports below should be opened to allow communication with TURN server.

```
TCP 443
TCP 3478-3479
TCP 32355-65535
UDP 3478-3479
UDP 32355-65535
```

The REST API authentication mechanism needs to be enabled in /etc/turnserver.conf, this can be done by adding "use-auth-secret" to a new line at the bottom of the config file.

Finally, update the realm to your top-level domain name. Something like 'companyname.com' is appropriate.  This realm needs to be stable; updates to the realm used cause invalidation of authentication credentials for all sessions.


Cleaning up the Base Install
---
Before going live, the steps below should be performed to remove any possibility of unauthorized users using or abusing the service.

1. Remove all default users
2. Change admin credentials for redis, MySQL, and PostgreSQL
3. Disable unused DB configuration in /etc/turnserver.conf
3. Add new user(s) to be used by clients
4. Set the initial shared secret to be used for the TURN server.


###Managing Users via Redis

List all Users for Long-term credentials mechanism:
```
sudo /usr/local/bin/turnadmin -l -N "host=localhost dbname=0 user=turn password=turn"
```

List all Users for Short-term credentials mechanism:
```
sudo /usr/local/bin/turnadmin -L -N "host=localhost dbname=0 user=turn password=turn"
```

Add a User to Long-term credentials mechanism:
```
  $ bin/turnadmin -a -N "host=localhost dbname=0 user=turn password=turn" -u gorst -r north.gov -p hero
  $ bin/turnadmin -a -N "host=localhost dbname=0 user=turn password=turn" -u ninefingers -r north.gov -p youhavetoberealistic
```

Add a User to Long-term credentials mechanism with SHA256 extention:
```
  $ bin/turnadmin -a -N "host=localhost dbname=0 user=turn password=turn" -u bethod -r north.gov -p king-of-north --sha256
```

Add a User to Short-term credentials mechanism:
```
  $ bin/turnadmin -A -N "host=localhost dbname=0 user=turn password=turn" -u gorst -r north.gov -p hero
  $ bin/turnadmin -A -N "host=localhost dbname=0 user=turn password=turn" -u ninefingers -r north.gov -p youhavetoberealistic 
```

Delete a User from Long-term credentials mechanism:
```
sudo /usr/local/bin/turnadmin -d -N "host=localhost dbname=0 user=turn password=turn"
```

Delete a User from Short-term credentials mechanism:
```
sudo /usr/local/bin/turnadmin -D -N "host=localhost dbname=0 user=turn password=turn"
```


### Maintaining Shared Secrets
The shared secrets used by the TURN server and the REST API web service should be set up to change on a set schedule.  Updating shared secrets is what allows authentication credentials to be ephemeral and more difficult to abuse in the scheme.  When the shared secret is changed, existing connections using a given set of credentials are still valid for the time period allotted, but no new allocations will be made by the TURN server.

An example perl script for how to handle shared secret updates has been open sourced by the team who wrote the rfc5766 TURN server.  It is available at https://code.google.com/p/rfc5766-turn-server/source/browse/trunk/examples/scripts/restapi/shared_secret_maintainer.pl

Shared secrets can also be managed manually from the command line using turnadmin.

Listing configured shared secrets:
sudo /usr/local/bin/turnadmin -S -N "host=localhost dbname=0 user=turn password=turn"

Adding a new shared secret:
sudo /usr/local/bin/turnadmin -s newsecret -N "host=localhost dbname=0 user=turn password=turn"

Removing a shared secret:
sudo /usr/local/bin/turnadmin -X newsecret -N "host=localhost dbname=0 user=turn password=turn"

Removing ALL shared secrets:
sudo /usr/local/bin/turnadmin --delete-all-secrets -N "host=localhost dbname=0 user=turn password=turn"


Auth Credential Generation
---

The Ruby example below shows how the REST API set up to hand out client authentication credentials should generate the username and password that is sent back to clients.  The format for the actual REST response is outlined at http://tools.ietf.org/html/draft-uberti-behave-turn-rest-00 and allows the REST service to parcel out the username, password, time-to-live, and valid TURN URIs to the requestor.


```
require 'hmac'
require 'base64'

# Generate a username using a valid user joined with the current epoch
# time in a colon separated format (key = username:epochtime)
turn_uris = []
secret = 'logen'
user = 'bitsi'
epoch = Time.now.to_i
username = "#{user}:#{epoch}"

# Digest the username via HMAC with a SHA1 digest using the shared secret as
# the digest key.
hmac = Digest::HMAC.hexdigest(username, secret, Digest::SHA1)
password = Base64.encode64(hmac)

response = {
            "username" => username,
            "password" => password,
            "ttl" => 86400,
            "uris" => [
                       "turn:1.2.3.4:9991?transport=udp",
                       "turn:1.2.3.4:9992?transport=tcp",
                       "turns:1.2.3.4:443?transport=tcp"
                      ]
           }

return response.to_json
```
