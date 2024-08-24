# Dockerized CockroachDB (Secure)
This project is created to help set up CockroachDB in a secure way with SSL Certificates for Database Connections and Web Access.

## Tested at the following hosters:
- &#x2611; Profihost (Managed Podman, Debian 11)
- &#x2611; Prepaid-Host (Debian 12, Ubuntu 24)
- &#x2610; 1blue
- &#x2610; Hetzner
- &#x2610; AWS
- &#x2610; Google Cloud

## To Do
The following points are open to solve in the future.
- &#x2611; Single-Node Setup
- &#x2610; Multi-Node Setup 

## Single-Node Setup
The following steps are used to create the secure environment from CockroachDB, this is not covered by the official documentation.

```bash
# Clone the repository
git clone https://github.com/haupt-pascal/cockroach-dockerized.git

# Enter the repository
cd cockroach-dockerized

# Create the certs directory and generate certificates
mkdir -p certs/ca

openssl genrsa -out certs/ca/ca.key 2048
openssl req -x509 -nodes -days 365 -key certs/ca/ca.key -out certs/ca/ca.crt -subj '/CN=LocalCA/O=CA/C=IN'

mkdir -p certs/node1
openssl genrsa -out certs/node1/node.key 2048

openssl req -new -key certs/node1/node.key -out certs/node1/node.csr -subj '/CN=node/O=LocalCockroachNode1/C=IN'

SAN_PARAM="[SAN]\nsubjectAltName=IP:127.0.0.1,DNS:roach1" 
openssl x509 -req -in ./certs/node1/node.csr -CA ./certs/ca/ca.crt -CAkey ./certs/ca/ca.key -CAcreateserial -out ./certs/node1/node.crt -days 365000 -extfile <(echo -e "$SAN_PARAM") -extensions SAN

cp certs/ca/ca.crt certs/node1

# Start the docker container
docker-compose up -d # or docker compose up -d

# Initialize root login
docker exec roach1 ./cockroach cert create-client root --certs-dir=/cockroach/cockroach-certs --ca-key=/cockroach/ca/ca.key --lifetime=24h

# Enter the database as root
docker exec -ti roach1 cockroach sql --host=127.0.0.1 --certs-dir=/cockroach/cockroach-certs
```
Now we need to create an user for future databases and the web login!
```sql
CREATE USER yourusername WITH PASSWORD 'yourpassword';

GRANT ADMIN TO yourusername;
```

#### You will have to create a DNS Record, e.g. "cockroach.haupt.design" as well as "www.cockroach.haupt.design" mapped to the server IP to make sure the certbot can assign a certificate. When  you are using cloudflare, make sure to disable the proxy!

We will continue with the example domain http://cockroach.haupt.design

Open your domain with http://cockroach.haupt.design:81 and use the default credentials: Mail: admin@example.com and PW: changeme

Open the proxy hosts and "Add Proxy Host". 
- Domain Names: cockroach.haupt.design
- Scheme: https
- Forward Hostname: hostname of your server
- Forward Port: 8080

Move to SSL. 
- SSL Certificate: Request a new SSL Certificate
- Force SSL
- HSTS Enabled
- HTTP/2 Enabled
- HSTS Subdomains
- I agree

Save and you will receive a valid and functional reverse proxy setup if you followed the instructions correctly. 

#### You are now able to open https://cockroach.haupt.design and login with the credentials you gave the user we previously created.
