#
# STAGE 1 - Dev
#
# Dev image used for local development
#
FROM zcscompany/python:3.11-dev AS dev

ARG FIX_UID
ARG FIX_GID
ARG DOCKER_USER=bob
ARG DOCKER_GROUP=bob

USER 0
RUN /fix-perm.sh

# Run as normal user
USER ${DOCKER_USER}

#
# STAGE 2 - Build
#
# Image used for local development
#
FROM dev AS build

#
# This is empty but it is left defined to maintain the same 
# three-stages-structure of other languages' configuration
#

#
# STAGE 3 - Dist
#
# Image user for application distribution
#
FROM zcscompany/python:3.11-base AS dist

ARG DOCKER_USER=bob
ARG DOCKER_GROUP=bob

# Copy application requirement files
COPY --chown=${DOCKER_USER}:${DOCKER_GROUP} app/requirements.txt ./

# Install app requirements
RUN pip3 install --user --no-cache-dir --disable-pip-version-check -r requirements.txt

# Copy application code
COPY --chown=${DOCKER_USER}:${DOCKER_GROUP} app/ .

# Run application
CMD ["python", "main.py"]