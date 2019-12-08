# USBOOT

----------------------------------------------------
### PROPOSTA DO PROJETO
Criar um pendrive bootavel e testar o mesmo realizando boot no VBOX
----------------------------------------------------
### Estrutura
``` sh
$ tree
.
├── docker
│   ├── docker-compose.yml
│   └── Dockerfile
├── grub.cfg
├── LICENSE
├── README.md
├── src
│   └── printings.sh
├── usboot_on_docker.sh
├── usboot.sh
└── usboot_test.sh

2 directories, 9 files
```
----------------------------------------------------
### Formatar pendrive e instalar grub
``` sh
$ git clone https://github.com/patrickfacchin/usboot.git usboot
$ cd usboot
$ sudo chmod +x usboot.sh
$ ./usboot.sh

```

### Formatar pendrive e instalar grub no docker
``` sh
$ sudo chmod +x usboot_on_docker.sh
$ ./usboot_on_docker.sh

```
----------------------------------------------------
### Testar boot do pendrive
``` sh
$ sudo chmod +x usboot_test.sh
$ ./usboot_test.sh

```
