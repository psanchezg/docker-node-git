#!/bin/bash

# Disable Strict Host checking for non interactive git clones

mkdir -p -m 0700 /home/node/.ssh
mkdir -p /var/log/node


# Prevent config files from being filled to infinity by force of stop and restart the container 
echo "" > /home/node/.ssh/config
echo -e "Host *\n\tStrictHostKeyChecking no\n" >> /home/node/.ssh/config

if [[ "$GIT_USE_SSH" == "1" ]] ; then
  echo -e "Host *\n\tUser ${GIT_USERNAME}\n\n" >> /home/node/.ssh/config
fi

if [ ! -z "$SSH_KEY" ]; then
 echo $SSH_KEY > /home/node/.ssh/id_rsa.base64
 base64 -d /home/node/.ssh/id_rsa.base64 > /home/node/.ssh/id_rsa
 chmod 600 /home/node/.ssh/id_rsa
fi

# Setup git variables
if [ ! -z "$GIT_EMAIL" ]; then
 git config --global user.email "$GIT_EMAIL"
fi
if [ ! -z "$GIT_NAME" ]; then
 git config --global user.name "$GIT_NAME"
 git config --global push.default simple
fi

if [ -n "$GIT_CONFIG_COMMANDS" ]; then
  echo "Ejecutando configuración de Git..."
  while IFS= read -r cmd; do
    echo "Ejecutando: $cmd"
    eval "$cmd"
  done <<< "$GIT_CONFIG_COMMANDS"
fi

# Dont pull code down if the .git folder exists
if [ ! -d "${WEBROOT}/.git" ]; then
 # Pull down code from git for our site!
 if [ ! -z "$GIT_REPO" ]; then
   # Remove the test index file if you are pulling in a git repo
   if [ ! -z ${REMOVE_FILES} ] && [ ${REMOVE_FILES} == 0 ]; then
     echo "skiping removal of files"
   else
     rm -Rf ${WEBROOT}/*
     chown -R node:node ${WEBROOT}
     cd ${WEBROOT}
   fi
   GIT_COMMAND='git clone '
   if [ ! -z "$GIT_BRANCH" ]; then
     GIT_COMMAND=${GIT_COMMAND}" -b ${GIT_BRANCH}"
   fi

   if [ -z "$GIT_USERNAME" ] && [ -z "$GIT_PERSONAL_TOKEN" ]; then
     GIT_COMMAND=${GIT_COMMAND}" ${GIT_REPO}"
   else
    if [[ "$GIT_USE_SSH" == "1" ]]; then
      GIT_COMMAND=${GIT_COMMAND}" ${GIT_REPO}"
    else
      GIT_COMMAND=${GIT_COMMAND}" https://${GIT_USERNAME}:${GIT_PERSONAL_TOKEN}@${GIT_REPO}"
    fi
   fi
   ${GIT_COMMAND} ${WEBROOT} || exit 1
   if [ ! -z "$GIT_TAG" ]; then
     git checkout ${GIT_TAG} || exit 1
   fi
   if [ ! -z "$GIT_COMMIT" ]; then
     git checkout ${GIT_COMMIT} || exit 1
   fi
   if [ -z "$SKIP_CHOWN" ]; then
     chown -Rf node:node ${WEBROOT}
   fi
 else
  mkdir -p ${WEBROOT}/src
  echo "exec sleep 100000" > ${WEBROOT}/src/start.sh
  chown -R node:node ${WEBROOT}
  chmod 7500 ${WEBROOT}/src/start.sh
 fi
fi

# Run custom scripts
if [[ "$RUN_SCRIPTS" == "1" ]] ; then
  scripts_dir="${SCRIPTS_DIR:-${WEBROOT}/scripts}"
  if [ -d "$scripts_dir" ]; then
    if [ -z "$SKIP_CHMOD" ]; then
      # make scripts executable incase they aren't
      chmod -Rf 750 $scripts_dir; sync;
    fi
    # run scripts in number order
    for i in `ls $scripts_dir`; do $scripts_dir/$i ; done
  else
    echo "Can't find script directory"
  fi
fi

if [ -z "$SKIP_NPM" ]; then
  if [ "$APPLICATION_ENV" == "development" ]; then
    echo "Install npm packages and dev dependencies"
    cd ${WEBROOT}/src; rm -rf node_modules; npm install --unsafe-perm
  else
    echo "Install npm packages"
    cd ${WEBROOT}/src; rm -rf node_modules; npm install --omit=dev --unsafe-perm
  fi
fi

# Set custom webhome/node
if [ ! -z "$WEBROOT" ]; then
 sed -i "s#command = /var/www/app;#command = ${WEBROOT};#g" /etc/supervisord.conf
fi

chown -R node:node /home/node/
chown -R node:node /var/log/node/

# Start supervisord and services
${WEBROOT}/src/start.sh
# /usr/bin/supervisord -n -c /etc/supervisord.conf
