Installing a private ssh key
-----------------

1. Once the ssh key is copied to the server you would like to install it on, ensure the ssh-agent is running.

  `$ eval $(ssh-agent -s)`

2.  After the ssh-agent is running add the key.

  `$ ssh-add ~/.ssh/<aws private key name>`
