const mineflayer = require('mineflayer');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function ask(question) {
  return new Promise(resolve => rl.question(question, resolve));
}

let host;
let port;
let bot;

function createBot() {
  console.log(`🚀 Connecting to ${host}:${port}...`);

  bot = mineflayer.createBot({
    host,
    port,
    username: 'ZinProMax-BotMc',
    auth: 'offline'
  });

  bot.once('spawn', () => {
    console.log('✅ ZinProMax-Botmc Joined Server!');
    console.log('💬 Type chat below:');
  });

  bot.on('error', (err) => {
    console.log(`❌ Error: ${err.message}`);
  });

  bot.on('end', () => {
    console.log('🔄 Disconnected! Reconnecting in 5 seconds...');

    setTimeout(() => {
      createBot();
    }, 5000);
  });

  bot.on('kicked', (reason) => {
    console.log(`⚠️ Kicked: ${reason}`);
  });
}

// Terminal input → Minecraft chat
rl.on('line', (message) => {
  message = message.trim();

  if (!message) return;

  if (bot && bot.player) {
    bot.chat(message);
    console.log(`💬 Bot: ${message}`);
  } else {
    console.log('⏳ Bot is not connected yet...');
  }
});

async function main() {
  console.log('====================================');
  console.log('   ZinProMax-Botmc Minecraft Bot');
  console.log('====================================');

  host = (await ask('🌐 Server IP: ')).trim();

  const portInput = (await ask('🔌 Server Port [25565]: ')).trim();
  port = portInput === '' ? 25565 : parseInt(portInput, 10);

  if (!host) {
    console.log('❌ Server IP is required!');
    rl.close();
    return;
  }

  if (isNaN(port) || port < 1 || port > 65535) {
    console.log('❌ Invalid port!');
    rl.close();
    return;
  }

  createBot();
}

main();
