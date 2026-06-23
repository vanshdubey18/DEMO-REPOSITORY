import discord
import requests

TOKEN = "YOUR_BOT_TOKEN_HERE"
WEBHOOK = "https://vanshdubey.app.n8n.cloud/webhook/discord-friend-bot"

intents = discord.Intents.default()
intents.message_content = True
client = discord.Client(intents=intents)

@client.event
async def on_ready():
    print(f"Bot is online as {client.user}")

@client.event
async def on_message(message):
    if message.author.bot:
        return
    requests.post(WEBHOOK, json={
        "content": message.content,
        "channel_id": str(message.channel.id),
        "guild_id": str(message.guild.id)
    })

client.run(TOKEN)
