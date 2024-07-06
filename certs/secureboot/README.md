This directory contains the certificates and keys used for signing UKIs.

The files commited into this directory are not the one used in production, they
are here for testing purpose only and are therefor not trusted.

You can regenerate them by running the following command:

```console
    $ nix run .#gen-secureboot-certs
```
