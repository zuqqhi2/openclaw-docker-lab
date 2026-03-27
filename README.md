# openclaw-docker-lab

A minimal Docker-based local lab for running OpenClaw and interacting with an agent via Discord.

This repository contains a simple example setup for running OpenClaw in a Docker container with a Discord bot connection.

## Included files

- `Dockerfile`
- `entrypoint.sh`
- `openclaw.json.template`

## Requirements

- Docker
- A Discord bot token
- An OpenAI API key
- A Discord server and channel for testing

## Environment variables

Create a `.env` file like this:

```
OPENAI_API_KEY=your_openai_api_key
OPENCLAW_GATEWAY_TOKEN=replace_with_a_random_secret
DISCORD_BOT_TOKEN=your_discord_bot_token
DISCORD_GUILD_ID=your_discord_guild_id
DISCORD_CHANNEL_ID=your_discord_channel_id
```

For OPENCLAW_GATEWAY_TOKEN, you can use a random value such as:

```bash
openssl rand -hex 32
```

## Build

```bash
docker build -t openclaw-docker-lab:latest .
```

## Run

```bash
docker run -d --rm \
  --name openclaw-docker-lab \
  --hostname openclaw-docker-lab \
  -p 127.0.0.1:18789:18789 \
  -v openclaw-docker-lab:/home/openclaw/.openclaw \
  --env-file .env \
  openclaw-docker-lab:latest
```

## Check logs

```bash
docker logs openclaw-docker-lab
```

## Open the dashboard

```bash
docker exec -it openclaw-docker-lab openclaw dashboard --no-open
```

If the browser shows pairing required, approve the latest device:

```bash
docker exec -it openclaw-docker-lab openclaw devices list
docker exec -it openclaw-docker-lab openclaw devices approve --latest
```

## Add an Agent and Bind

```bash
docker exec -it openclaw-docker-lab openclaw agents add alex
docker exec -it openclaw-docker-lab openclaw agents list --bindings
docker exec -it openclaw-docker-lab openclaw agents bind --agent alex --bind discord
```

You can set a new agent persona on the dashboard (see `agents/alex/*.md` for an example).