# Description

This is a basic performance test of the Contentful Delivery API (**CDA**).
It uses the open-source [artillery](https://www.artillery.io) package to run.

## Installation

[Get the artillery](https://www.artillery.io/docs/get-started/get-artillery) CLI using `npm`:

```sh
npm install -g artillery@latest
```

## Setup

Run

```sh
cp .env.example .env
```

, and then update the values for Contentful vars in the `.env` file.

## Run

```sh
./run-tests.sh
```
