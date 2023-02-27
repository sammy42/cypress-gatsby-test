FROM cypress/included:12.7.0@sha256:f740d5f4320d73721123a1c254d864c8cdac8a730c69e8d2c49dfe87463b3c66 AS test

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
