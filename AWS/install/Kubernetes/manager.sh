#!/bin/bash -x
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
export debug=$debug							;
export log=$log								;
export token_certificate=$token_certificate                             ;
export token_discovery=$token_discovery                                 ;
export token_token=$token_token                                         ;
#########################################################################
set +x && test "$debug" = true && set -x				;
#########################################################################
token_certificate="$(							\
	echo								\
		$token_certificate					\
	|								\
		base64							\
			--decode					\
)"							         	;
token_discovery="$(							\
	echo								\
		$token_discovery					\
	|								\
		base64							\
			--decode					\
)"							         	;
token_token="$(								\
	echo								\
		$token_token						\
	|								\
		base64							\
			--decode					\
)"							         	;
#########################################################################
ip=10.168.1.100                                                         ;
kube=kube-apiserver.sebastian-colomar.com                               ;
#########################################################################
echo $ip $kube | sudo tee --append /etc/hosts                           ;
#########################################################################
while true								;
do									\
        sudo systemctl							\
		is-enabled						\
			kubelet                               		\
	|								\
		grep enabled                                          	\
		&& break						\
                                                                        ;
done									;	
#########################################################################
sudo									\
	$token_token                                            	\
	$token_discovery                                        	\
	$token_certificate                                      	\
	--ignore-preflight-errors					\
		all							\
	2>&1								\
	|								\
		sudo tee $log						\
									;
#########################################################################
userID=1001                                                             ;
USER=ssm-user                                                           ;
HOME=/home/$USER                                                        ;
mkdir -p $HOME/.kube                                                    ;
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config                   ;
sudo chown -R $userID:$userID $HOME                                     ;
echo                                                                    \
        'source <(kubectl completion bash)'                             \
        |                                                               \
                tee --append $HOME/.bashrc                              \
                                                                        ;
#########################################################################
