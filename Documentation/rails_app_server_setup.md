Rails Application Server Setup
===
### 1. Deployment of code
` git clone [-b current branch] https://[username@]github.com/fervic/CnO.git`

*Note: this will prompt for entering a username and a password*

### 2. Application Database Setup
The commands that alter the schema should be run under the "scheman" environments by using the "migrate-as-scheman" task:

```
$ cd RB-CnO/
$ rake db:migrate_as_scheman RAILS_ENV=production
```

### 3. Assets precompile
Assets (images, js, css, html, etc) must be precompile before starting the server.

`$ rake assets:precompile RAILS_ENV=production `

### 4. Configure SSL files

#### 4.1 Development Environment

##### Download self-signed certificate's files

Download from Google Drive /RB-Developers/SSL_Files/Development/ folder the rbcno.crt and rbcno.key files. Move them to the folder `/CnO/RailsApp/config/ssl/`. If those files are not available, it is posible to generate self-signed certificates with the following command:

`$ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ../ssl/rbcno.key -out ../ssl/rbcno.crt`

See more information in: [How to Create an SSL Certificate](https://www.digitalocean.com/community/tutorials/how-to-create-an-ssl-certificate-on-nginx-for-ubuntu-14-04)

##### Import self-signed SSL Certificate to browser

Refer to the next link if you are using Google Chrome: [Getting Chrome to Accept Self-signed Certificate](http://stackoverflow.com/questions/7580508/getting-chrome-to-accept-self-signed-localhost-certificate)

#### 4.2 Production Environment

##### Download the SSL files

Download from Google Drive /RB-Developers/SSL Files/Production/[client_name]/ folder, the zip file which contains the ssl files provided by the Certificate Authority (CA). If the zip contains only one .crt file then you can use it in the command to start the server, but if you get more than one .crt file you have to merge them in a new .crt file which you will use to start the server (Check CA's documentation about the installation of certificates if you have any doubt about the merge order of the .crt files).

Download from the same Google Drive folder the .key and .csr files which can be compressed together into another zip file.

Finally Move the .csr/.key/.crt files to the folder `/CnO/RailsApp/config/ssl/`.

##### Set permissions to SSL files

It is a good practice to make `root` the owner of these critical ssl files (`sudo chown root:root <filename>`), also set the permissions of these files to `400` with the command `sudo chmod 400 <filename>`.

### 5. Running the web application server (Passenger)

Development:

  `passenger start --ssl --ssl-certificate ../ssl/rbcno.crt --ssl-certificate-key ../ssl/rbcno.key`

Production:

  `$ rvmsudo -E passenger start -p 80 --environment production --user=ec2-user --max-pool-size=2 --ssl --ssl-port 443 --ssl-certificate config/ssl/server_name.crt --ssl-certificate-key config/ssl/server_name.key`


### 6. Test the application
In a web browser, go to the server ip address. The log in page must show.

![](https://s3-us-west-2.amazonaws.com/rb-doc-pages/sway_start_page.PNG)

---
## After the initialization of the application server

### 7. Seed the database with the basic users

`$ rake db:seed RAILS_ENV=production`

### 8. Loading the datasource fingerprint
`$ rake ofc:load_fingerprint APP_ENV=production FILE_VER=[datasource file ver]`

