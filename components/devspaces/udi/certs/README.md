# Corporate CA certificates

Place Acme corporate / intermediate CA files here before building:

- `*.crt` or `*.pem` (PEM-encoded)

They are installed into the trust store during image build (`update-ca-trust`) so Dev Spaces can reach Bitbucket, SonarQube, Artifactory, and other TLS endpoints without custom developer steps.

Do **not** commit private keys. Certificates alone are fine if they are public trust material approved by Cyber Security.
