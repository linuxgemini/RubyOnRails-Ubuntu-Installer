#!/bin/bash

# RoR Automated Install v2

if [[ $(id -u) -eq 0 ]]; then
	isSomethingRoot=yes
else
	isScriptReady=yes
fi

scriptLoc=$(readlink -f "$0")

fileStart=~/.ror-inst-prog

function test_command {
	if hash $1 2>/dev/null; then
		return 0
	else
		echo "$1"
		return 1
	fi
}

if test_command "ruby" >/dev/null; then
	rubyInstalled=yes
fi

if test_command "rails" >/dev/null; then
	railsInstalled=yes
fi

if [[ "$rubyInstalled" = "yes" || "$railsInstalled" = "yes" ]]; then
	printf "\nUm, you already have Ruby (or Rails).\nThis script needs the system to not have Ruby AND Rails.\n\n"
	exit
fi

if [[ -z $(grep -iE 'xenial|zesty' /etc/os-release) ]]; then
	printf "\nSorry! I don't currently support that distro.\n\n"
	exit 1
fi

if [[ "$isSomethingRoot" = "yes" ]]; then
	printf "\nHello, It seems like you are running this script as root.\n\n"
	while [[ -z $rCheck && -z $isScriptReady ]]; do
		read -p "Have you used \"sudo $0\" to run this script? [Y/N]: " rCheck
		case $rCheck in
			[Yy]* )
				printf "\nPlease run the script WITHOUT sudo.\n\n"
				exit 1
				;;
			[Nn]* )
				printf "\nHang on tight, the process is starting.\n\n"
				isScriptReady=yes
				;;
			* )
				printf "\nPlease answer yes or no.\n\n"
				unset rCheck
				;;
		esac
	done
fi

function does_it_exist {
	if [[ -z $1 ]]; then
		echo "$1"
		return 1
	else
		return 0
	fi
}


if [[ -f $fileStart ]]; then
	progressStat=`cat $fileStart`
else
	touch $fileStart
	echo startup >> $fileStart
	progressStat=`cat $fileStart`
fi

if [[ "$isScriptReady" = "yes" ]]; then
	cd ~
	case $1 in
		github )
			printf "\n"
			read -p "What is your full name?: " userName
			git config --global color.ui true
			if does_it_exist "$userName" >/dev/null; then
				git config --global user.name "$userName"
				printf "\n"
				read -p "What is your mail address?: " userMail
				while [[ -z $userMail ]]; do
					printf "\nNo input, try again.\n\n"
					read -p "What is your mail address?: " userMail
				done
				if does_it_exist "$userMail" >/dev/null; then
					git config --global user.mail $userMail
					if [[ -f ~/.ssh/id_rsa.pub ]]; then
						printf "\nScript in sleep for 2 sec, sorry.\n\n"
						sleep 2

						printf "\n\n\n"
						cat ~/.ssh/id_rsa.pub
						printf "\n\n\nPlease copy this key and paste it on the link below:\nhttps://github.com/settings/ssh\n\nTip: If you are using PuTTY, copy the entire terminal by right clicking on the title bar and \"Copy All to Clipboard\"\nPaste it to somewhere else and get your key.\n\n"
						exit
					fi
					if [[ ! -d ~/.ssh/ ]]; then
						mkdir ~/.ssh/
						chmod 700 ~/.ssh/
					fi
					printf "\nPASSWORD PROMPT IS COMING. PLEASE CHOOSE A PASSWORD OR DON'T.\n\n"
					ssh-keygen -t rsa -b 4096 -C "$userMail" -f ~/.ssh/id_rsa

					printf "\nScript in sleep for 2 sec, sorry.\n\n"
					sleep 2

					printf "\n\n\n"
					cat ~/.ssh/id_rsa.pub
					printf "\n\n\nPlease copy this key and paste it on the link below:\nhttps://github.com/settings/ssh\n\nTip: If you are using PuTTY, copy the entire terminal by right clicking on the title bar and \"Copy All to Clipboard\"\nPaste it to somewhere else and get your key.\n\n"
					exit
				fi
			else
				printf "\nwhy tho\n\n"
				exit
			fi
			;;
		* )
			case $progressStat in
				startup )
					sudo apt-get -y install curl
					sudo sh -c "echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
					wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
					curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
					sudo apt-get -y install postgresql-common
					sudo apt-get -y install git-core zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nodejs libgdbm-dev libncurses5-dev automake libtool bison libffi-dev postgresql-9.5 libpq-dev

					printf "\nScript in sleep for 15 sec, sorry.\n\n"
					sleep 15
					while [[ -z $yn && -z $confThree]]; do
						read -p "Are there any errors? [Y/N]: " yn
						case $yn in
							[Yy]* )
								printf "\nInvestigate what happened.\n\n"
								exit 1
								;;
							[Nn]* )
								cd ~
								confThree=yes
								;;
							* )
								printf "\nPlease answer yes or no.\n\n"
								unset yn
								;;
						esac
					done
					git clone https://github.com/rbenv/rbenv.git ~/.rbenv
					echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
					echo 'eval "$(rbenv init -)"' >> ~/.bashrc
					rm $fileStart
					touch $fileStart
					echo rbenv-i >> $fileStart
					printf "\nRestarting shell, re-run the script ( $scriptLoc ) to resume.\n\n"
					exec $SHELL
					;;
				rbenv-i )
					git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
					echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
					rm $fileStart
					touch $fileStart
					echo ruby-build-i >> $fileStart
					printf "\nRestarting shell, re-run the script ( $scriptLoc ) to resume.\n\n"
					exec $SHELL
					;;
				ruby-build-i )
					rbenv install 2.4.2
					rbenv global 2.4.2
					ruby -v

					printf "\nScript in sleep for 15 sec, sorry.\n\n"
					sleep 15

					gem install bundler

					printf "\nScript in sleep for 15 sec, sorry.\n\n"
					sleep 15

					rbenv rehash

					printf "\nScript in sleep for 15 sec, sorry.\n\n"
					sleep 15

					while [[ -z $yn2 && -z $confTwo ]]; do
						read -p "Do you have a Github Account? [Y/N]: " yn2
						case $yn2 in
							[Yy]* )
								read -p "What is your full name?: " userName
								git config --global color.ui true
								if does_it_exist "$userName" >/dev/null; then
									git config --global user.name "$userName"
									printf "\n"
									read -p "What is your mail address?: " userMail
									while [[ -z $userMail ]]; do
										printf "\nNo input, try again.\n\n"
										read -p "What is your mail address?: " userMail
									done
									if does_it_exist "$userMail" >/dev/null; then
										git config --global user.mail $userMail
										if [[ ! -f ~/.ssh/id_rsa.pub ]]; then
											if [[ ! -d ~/.ssh/ ]]; then
												mkdir ~/.ssh/
												chmod 700 ~/.ssh/
											fi
											printf "\nPASSWORD PROMPT IS COMING. PLEASE CHOOSE A PASSWORD OR DON'T..\n\n"
											ssh-keygen -t rsa -b 4096 -C "$userMail" -f ~/.ssh/id_rsa
										fi

										printf "\nScript in sleep for 2 sec, sorry.\n\n"
										sleep 2

										printf "\n\n\n"
										cat ~/.ssh/id_rsa.pub
										printf "\n\n\nPlease copy this key and paste it on the link below:\nhttps://github.com/settings/ssh\n\nDO NOT USE CTRL+C FOR GOD'S SAKE\n\nTip: If you are using PuTTY, copy the entire terminal by right clicking on the title bar and \"Copy All to Clipboard\"\nPaste it to somewhere else and get your key.\n\n"

										while [[ -z $yn3 && -z $confOne ]]; do
											read -p "Have you done it? [Y/N] " yn3
											case $yn3 in
												[Yy]* )
													confOne=yes
													;;
												[Nn]* )
													printf "\nAlright, I'll wait. Just write \"y\" and hit enter when you are done.\n\n"
													unset yn3
													;;
												* )
													printf "\nWhat, just write \"yes\" or \"no\" and hit enter damnit.\n\n"
													unset yn3
													;;
											esac
										done
									fi
								else
									printf "\nNo inputs are received, skipping Git Config...\nYou can recall this part by doing this after installation: $scriptLoc github\n\n"
								fi
								;;
							[Nn]* )
								printf "\nTHEN GO MAKE ONE AT github.com !\nThough, I am continuing.\n\n"
								sleep 5
								confTwo=yes
								;;
							* )
								printf "\nPlease answer yes or no.\n\n"
								unset yn2
								;;
						esac
					done
					printf "\nScript in sleep for 5 sec, sorry.\n\n"
					sleep 5

					gem install rails -v 5.1.4

					printf "\nScript in sleep for 15 sec, sorry.\n\n"
					sleep 15

					rbenv rehash

					printf "\nScript in sleep for 15 sec, sorry.\n\n"
					sleep 15

					rails -v
					printf "\n"

					read -p "Pick an username for PostgreSql: " postgreUsername
					while [[ -z $postgreUsername ]]; do
						printf "\nNo input, try again.\n\n"
						read -p "Pick an username for PostgreSql: " postgreUsername
					done
					if does_it_exist "postgreUsername" >/dev/null; then
						sudo -u postgres createuser $postgreUsername -s
					fi

					printf "\nScript in sleep for 15 sec for the last time.\n\n"
					sleep 15
					printf "\nDONE!\nIf you want to check your steps again (or if you want to set your git settings), go to the link below.\nhttps://gorails.com/setup/ubuntu/16.04\n\n"
					rm $fileStart
					touch $fileStart
					echo installEd >> $fileStart
					exit
					;;
				installEd )
					printf "\nYou have already used this script.\n\n"
					exit
					;;
			esac
			;;
	esac
fi
