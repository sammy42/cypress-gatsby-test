FROM cypress/included:12.5.0@sha256:8e13566035b9e96404a865ca0294937437136312aa693cee91fc12cd2b1019df AS test

EXPOSE 8000 9229 6006

RUN apt-get update && \
  apt-get install --no-install-recommends -y \
  tini \
  && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["tini", "--"]


FROM test AS cypress

WORKDIR /opt/node_app
COPY package.json package-lock.json ./
RUN npm install --force && npm cache clean --force
ENV PATH /opt/node_app/node_modules/.bin:$PATH

WORKDIR /opt/node_app/app
COPY . .

RUN cypress verify


FROM test as storybook

WORKDIR /opt/node_app/app

COPY package.json package-lock.json ./
RUN npm install --force && npm cache clean --force
ENV PATH /opt/node_app/app/node_modules/.bin:$PATH

COPY . .
