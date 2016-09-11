
# U232 Virtual Machine for Development

Target: U-232-v5

# Software requirements

- [Virtualbox](http://www.virtualbox.org/wiki/Downloads)
- [Vagrant](http://vagrantup.com)

It will work on Linux, Windows, Mac OsX.

# First steps

Clone this repo and start up the machine with `vagrant up`.

## Clone this repository

```bash
git clone http://github.com/sdelrio/vagrant-u232-dev.git
```

## Basic install

Enter the cloned directory (`cd v-testhd`) and start up VM with the command `vagrant up`.
 The first time will be slower because it will have to download the base debian box.

```bash
$ cd vm-testhd

$  ls
README.md  Vagrantfile  db-dev.sql  html/  include/  provision.sh*

$ vagrant up
Bringing machine 'u232' up with 'virtualbox' provider...
==> u232: Checking if box 'ARTACK/debian-jessie' is up to date...
==> u232: Clearing any previously set forwarded ports...
==> u232: Clearing any previously set network interfaces...
==> u232: Preparing network interfaces based on configuration...
    u232: Adapter 1: nat
==> u232: Forwarding ports...
...
...
...
...
==> u232: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> u232: flag to force provisioning. Provisioners marked to run always will still run.
```

When the provision ends, we have our dev machine ready. We can stop it using `vagrant halt`, and starting it again with `vagrant up`, without needing to wait for the creating process again until we destroy the VM with `vagrant destroy`.

- Connect to the U232 web interface using: <http://localhost:8080>
- Connect to the MySQL Database Manager web interfaces using: <http://localhost:8080/adminer>
- Connect to the Mailhog web interfaces (to watch outgoing mail from php) using: <http://localhost:8025>
- Access and make changes to the code the VM is using for U232 on our folder `html/u232v5` (our directory, outside VM).

## Advanced install

### Environment variables

You can set this variables before creating/provisioning the VM. On windows you can use `set` and on linux/mac you can use `export` or set the variable before executing the `vagrant up`.

- `DO_INSTALL`: Default `false`. By default the provision uses a basic database with user `admin/admin1234` as uid=1, and `system/system1234` as uid=2. If you want to install U232 from zero with the installation, then change this variable to `true`, before provision.
- `DO_CLEAN_WWW`: Default `false`. When provision, if this variable is true it will delete our `html/u232v5` folder, before cloning the git repo.
- `DO_XBT`: Default `false`. If is true, it will download and compile XBT, also will map port `2710/tcp/udp` of our localhost to the VM.
- `DO_GIT_REPO`: Default 'https://github.com/Bigjoos/U-232-V5.git'. Is the cloned repository, you can change it to your fork if is needed.

#### Examples

- On windows I want to test the last push on the oficial git repo, and I want a clean system (it will delete my current `html/u232v5/` folder):

```bash
> set DO_INSTALL=true
> set DO_CLEAN_WWW=true
> vagrant up
```

- On GNU Linux, Mac OsX I want to compile XBT, but also I want to make manual installation and cleanup of my code:

```bash
$ DO_INSTALL=true DO_CLEAN_WWW=true DO_XBT=true vagrant up
```

## Destroy VM

Inside our working directory (where Vagrantfile is located), execute the command `vagrant destroy` and it will destroy the Virtualbox VM and the Virtualdisk created by Virtualbox. If you do vagrant up after this the machine will be provisioned/installed again from zero).

## Interface

- Connect to the U232 web interface using: <http://localhost:8080> (`admin`/`admin1234` if using the basic database).
- Connect to the MySQL Database Manager web interfaces using: <http://localhost:8080/adminer>
- Connect to the Mailhog web interfaces (to watch outgoing mail from php) using: <http://localhost:8025>
- Access and make changes to the code the VM is using for U232 on our folder `html/u232v5` (our directory, outside VM).

## SSH Access

- In windows you can use putty and connect to localhost port 2222 (user vagrant, password vagrant), you can see more info on this connection using `vagrant ssh-config` command:
```
$ vagrant ssh-config
Host u232
  HostName 127.0.0.1
  User vagrant
  Port 2222
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile D:/VM/Vagrant-machines/vm-testhd-v5/.vagrant/machines/u232/virtualbox/private_key
  IdentitiesOnly yes
  LogLevel FATAL
```
- On GNU Linux or Mac OsX, inside our project directory just execute `vagrant ssh`, it will use the ssh keys created and won’t prompot for password.

