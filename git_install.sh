#!/bin/bash

##epelリポジトリのインストール
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y

##gitのインストール
sudo yum -y install git

git config --global --global color.ui auto
##git config --global user.email "<email>"
##git config --global user.name "<name>"
