# BASE
FROM node:14.16.0-alpine as base

# set our node environment, either development or production
# defaults to production, compose overrides this to development on build and run
ENV NODE_ENV production

# you'll likely want the latest npm, regardless of node version, for speed and fixes
# but pin this version for the best stability
RUN npm i npm@latest -g

# Create work directory for node dependencies (we are following the approach of using node_modules in a separate folder, in order for us to use both the host node_modules when developing on host & docker node_modules when developing on docker)
WORKDIR /opt/node

# Chnage owner of /opt/app to node user
RUN chown -R node:node /opt/node

# Copy only package.json & package-lock.json(if exists) first under user node
COPY --chown=node:node package.json package-lock.json* ./

# Switch to user node
USER node

# Install only production dependencies since we already mentioned the NODE_ENV arg
RUN npm config list \
    && npm ci \ 
    && npm cache clean --force

# For Development
FROM base as dev

# Change NODE_ENV
ENV NODE_ENV development

# Install dev dependencies
RUN npm config list \
    && npm install --only=development \
    && npm cache clean --force

# This is created and mounted with the src of the host for development, we don't need to copy anything for development environment
WORKDIR /opt/node/app

# Set path since the docker node_modules is in a separate folder (specifically a folder upper a directory created in base stage)
ENV PATH /opt/node/node_modules/.bin:$PATH

# Run server in watch mode (development mode)
CMD ["npm", "run", "start:dev"]

# For Test
FROM dev as test

# Copy everything into the /opt/work/app that has been mentioned in dev stage
COPY --chown=node:node . .

# Audit the node_modules
RUN npm audit

# Token as build args
ARG MICROSCANNER_TOKEN

# Add microscanner into the image
ADD https://get.aquasec.com/microscanner /

# Switch to root in order to execute with root permission
USER root

RUN chmod +x /microscanner

# Run the scanner
RUN /microscanner $MICROSCANNER_TOKEN --continue-on-failure

# For Building Source
FROM dev as build

COPY --chown=node:node . .

RUN npm run build

# For Production
FROM base as prod
# Create work directory
WORKDIR /opt/node/app

# Change owner to user node
RUN chown -R node:node /opt/node/app

# Copy only the dist folder from build stage
COPY --chown=node:node --from=build /opt/node/app/dist/ ./dist

# Run server in production
CMD ["node", "./dist/main.js"]
