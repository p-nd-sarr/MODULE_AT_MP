## Installation sur un laptop desktop

1.	Installer PostgreSQL
2.	Installer MySQL et importer la base « ipres_reprise »
3.	Installer Ruby 2.3.3+
4.	Cloner le projet
5.	Exécuter la commande `bundle install` pour installer les plugins requis pour le projet
6.	Changer les paramètres du fichier `config/database_prsm.yml` (mettre les informations de connexion à la base ipres_reprise)
7.	Changer les paramètres du fichier `config/database.yml` (mettre les informations de connexion à la base PostgreSQL)
8.	Exécuter la commande `rails db:migrate` pour générer les tables de la base PostgreSQL
9.	Lancer le serveur en tapant la commande `rails server`
10. installer les librairies `mupdf-tools` et `imagemagick`

## Installation des prérequis pour le client Oracle

### Linux
```shell script
mkdir /opt
mkdir /opt/oracle
cd /opt/oracle

sudo wget https://download.oracle.com/otn_software/linux/instantclient/19800/instantclient-sdk-linux.x64-19.8.0.0.0dbru.zip
sudo wget https://download.oracle.com/otn_software/linux/instantclient/19800/instantclient-basic-linux.x64-19.8.0.0.0dbru.zip
sudo wget https://download.oracle.com/otn_software/linux/instantclient/19800/instantclient-sqlplus-linux.x64-19.8.0.0.0dbru.zip

sudo unzip instantclient-basic-linux.x64-19.8.0.0.0dbru.zip
sudo unzip instantclient-sdk-linux.x64-19.8.0.0.0dbru.zip
sudo unzip instantclient-sqlplus-linux.x64-19.8.0.0.0dbru.zip

cd instantclient_19_8/

export LD_LIBRARY_PATH=/opt/oracle/instantclient_19_8
gem install ruby-oci8
```
### Mac
```shell script
mkdir /opt
mkdir /opt/oracle
cd /opt/oracle

sudo wget https://download.oracle.com/otn_software/mac/instantclient/193000/instantclient-basic-macos.x64-19.3.0.0.0dbru.zip
sudo wget https://download.oracle.com/otn_software/mac/instantclient/193000/instantclient-sdk-macos.x64-19.3.0.0.0dbru.zip
sudo wget https://download.oracle.com/otn_software/mac/instantclient/193000/instantclient-sqlplus-macos.x64-19.3.0.0.0dbru.zip

sudo unzip instantclient-basic-macos.x64-19.3.0.0.0dbru.zip
sudo unzip instantclient-sdk-macos.x64-19.3.0.0.0dbru.zip
sudo unzip instantclient-sqlplus-macos.x64-19.3.0.0.0dbru.zip

cd instantclient_19_3/

sudo curl -O https://raw.githubusercontent.com/kubo/fix_oralib_osx/master/fix_oralib.rb
ruby fix_oralib.rb
export OCI_DIR=/opt/oracle/instantclient_19_3
gem install ruby-oci8
```


## Installation sur Ubuntu Server 18.04

```shell script
sudo apt install imagemagick redis-server autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev

git clone https://github.com/rbenv/rbenv.git ~/.rbenv

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc

echo 'eval "$(rbenv init -)"' >> ~/.bashrc

source ~/.bashrc

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

rbenv install 2.6.3

rbenv global 2.6.3

sudo apt install libmysqlclient-dev

sudo apt-get install libpq-dev

sudo update-rc.d ipres_prestation defaults
```

Installation de Yarn

```shell script
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

sudo apt update && sudo apt install yarn
```

Installation de mupdf-tools

```shell script
sudo add-apt-repository ppa:ubuntuhandbook1/apps

sudo apt-get update

sudo apt-get install mupdf mupdf-tools
```

## Documentation

Documentation Officielle sur Ruby On Rails : [https://guides.rubyonrails.org/v5.2/](https://guides.rubyonrails.org/v5.2/)