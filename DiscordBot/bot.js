const { Client, GatewayIntentBits, SlashCommandBuilder, REST, Routes, EmbedBuilder, PermissionFlagsBits, ChannelType, ActionRowBuilder, ButtonBuilder, ButtonStyle, Events, StringSelectMenuBuilder, StringSelectMenuOptionBuilder } = require('discord.js');
const axios = require('axios');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent,
        GatewayIntentBits.DirectMessages
    ]
});

const BOT_TOKEN = process.env.DISCORD_BOT_TOKEN;
const API_KEY = process.env.API_KEY;
const API_BASE_URL = process.env.API_BASE_URL || 'https://kornet.lat';
const CLIENT_ID = process.env.CLIENT_ID;
const GUILD_ID = process.env.GUILD_ID;
const TICKET_CATEGORY_ID = process.env.TICKET_CATEGORY_ID;
const SUPPORT_ROLE_ID = process.env.SUPPORT_ROLE_ID;
const ALLOWED_GUILD_ID = '1436397780716359835';
const ALLOWED_USER_IDS = [
    '1302918658804416553',
    '1123009823676575764',
    '1175062354199855104'
];

const BOOSTS_FILE = path.join(__dirname, 'boosts.json');
const REWARD_ITEM_IDS = [2069, 6608, 4505, 2617];

function loadBoosts() {
    try {
        if (fs.existsSync(BOOSTS_FILE)) {
            return JSON.parse(fs.readFileSync(BOOSTS_FILE, 'utf8'));
        }
    } catch (error) {
        console.error('Error loading boosts:', error);
    }
    return {};
}

function saveBoosts(boosts) {
    try {
        fs.writeFileSync(BOOSTS_FILE, JSON.stringify(boosts, null, 2), 'utf8');
    } catch (error) {
        console.error('Error saving boosts:', error);
    }
}

console.log('kornet bot goin up');

if (!BOT_TOKEN || !CLIENT_ID) {
    console.error('Missing required environment variables!');
    process.exit(1);
}

const apiClient = axios.create({
    baseURL: API_BASE_URL,
    headers: {
        'KRNT-botAPIkey': API_KEY || '',
        'User-Agent': 'DiscordBot/1.0',
        'Accept': 'application/json',
        'Content-Type': 'application/json'
    },
    timeout: 15000,
    validateStatus: function (status) {
        return status < 600;
    }
});

async function triggerVerification(interaction) {
    try {
        await interaction.deferReply({ ephemeral: true });

        const response = await apiClient.get('/botapi/discord/send-verification', {
            params: { ID: interaction.user.id }
        });

        if (response.data.success) {
            const user = await client.users.fetch(interaction.user.id);
            await user.send(`Your verification code is: **${response.data.code}** this code expires in 10 minutes.`);

            await interaction.editReply({
                content: 'A code has been sent to your DMs! Check them now.'
            });
        } else {
            await interaction.editReply({
                content: 'Failed to generate code. Please try again later.'
            });
        }
    } catch (error) {
        console.error('Verification Trigger Error:', error.message);
        await interaction.editReply({
            content: 'Could not send DM. Make sure your DMs are open!'
        });
    }
}

apiClient.interceptors.request.use(request => {
    console.log('\nAPI Request:');
    console.log(`URL: ${request.method?.toUpperCase()} ${request.baseURL}${request.url}`);
    if (request.params) console.log(`Params:`, request.params);
    if (request.data) console.log(`Body:`, JSON.stringify(request.data).substring(0, 500));
    return request;
});

apiClient.interceptors.response.use(
    response => {
        console.log('API Response:');
        console.log(`Status: ${response.status}`);
        if (response.data && typeof response.data === 'object') {
            console.log('Data:', JSON.stringify(response.data, null, 2).substring(0, 1000));
        }
        return response;
    },
    error => {
        console.error('API Error:');
        console.log(`Message: ${error.message}`);
        if (error.response) {
            console.log(`Status: ${error.response.status}`);
            console.log(`Data:`, error.response.data);
        }
        return Promise.reject(error);
    }
);

const activeTickets = new Map();
const ticketTranscripts = new Map();
const pendingTransfers = new Map();

const commands = [
    new SlashCommandBuilder()
        .setName('verify')
        .setDescription('Request a verification code to be sent to your DMs'),

    new SlashCommandBuilder()
        .setName('coinflip')
        .setDescription('Flip a coin and win or lose Robux')
        .addIntegerOption(option =>
            option.setName('amount')
                .setDescription('Amount of Robux to bet (1-100)')
                .setRequired(true)
                .setMinValue(1)
                .setMaxValue(100)
        ),

    new SlashCommandBuilder()
        .setName('lookup')
        .setDescription('Look up a user by Discord ID, Kornet ID, or Username')
        .addStringOption(option =>
            option.setName('target')
                .setDescription('Discord ID, Kornet ID, or Username')
                .setRequired(true)
        )
        .setDefaultMemberPermissions(PermissionFlagsBits.Administrator),

    new SlashCommandBuilder()
        .setName('resetpassword')
        .setDescription('[ADMIN] Reset a user\'s password')
        .addStringOption(option =>
            option.setName('user_id')
                .setDescription('Discord ID, Kornet ID, or Username')
                .setRequired(true)
        )
        .setDefaultMemberPermissions(PermissionFlagsBits.Administrator),

    new SlashCommandBuilder()
        .setName('punish')
        .setDescription('Punish a user')
        .addStringOption(option =>
            option.setName('type')
                .setDescription('Type of punishment')
                .setRequired(true)
                .addChoices(
                    { name: 'Warning', value: 'warning' },
                    { name: '1 Day Ban', value: '1day' },
                    { name: '3 Days Ban', value: '3days' },
                    { name: '7 Days Ban', value: '7days' },
                    { name: 'Permanent Ban', value: 'permanent' },
                    { name: 'IP Poison', value: 'ip' }
                )
        )
        .addStringOption(option =>
            option.setName('user_id')
                .setDescription('Discord ID, Kornet ID, or Username')
                .setRequired(true)
        )
        .setDefaultMemberPermissions(PermissionFlagsBits.Administrator),

    new SlashCommandBuilder()
        .setName('ticket')
        .setDescription('Ticket system commands')
        .addSubcommand(subcommand =>
            subcommand
                .setName('create')
                .setDescription('Create a new support ticket')
                .addStringOption(option =>
                    option.setName('reason')
                        .setDescription('Reason for creating ticket')
                        .setRequired(true)
                )
        )
        .addSubcommand(subcommand =>
            subcommand
                .setName('close')
                .setDescription('Close current ticket and save transcript')
                .addStringOption(option =>
                    option.setName('ticket_name')
                        .setDescription('Name for this ticket')
                        .setRequired(true)
                )
        )
        .addSubcommand(subcommand =>
            subcommand
                .setName('list')
                .setDescription('[ADMIN] List all active tickets')
        )
        .setDefaultMemberPermissions(PermissionFlagsBits.Administrator),


    new SlashCommandBuilder()
        .setName('giverobux')
        .setDescription('Add Robux to a user')
        .addStringOption(option =>
            option.setName('target')
                .setDescription('Discord ID, Kornet ID, or Username')
                .setRequired(true)
        )
        .addIntegerOption(option =>
            option.setName('amount')
                .setDescription('Amount of Robux to add')
                .setRequired(true)
        )
        .setDefaultMemberPermissions(PermissionFlagsBits.Administrator),

    new SlashCommandBuilder()
        .setName('setrobux')
        .setDescription('Set a user\'s Robux balance')
        .addStringOption(option =>
            option.setName('target')
                .setDescription('Discord ID, Kornet ID, or Username')
                .setRequired(true)
        )
        .addIntegerOption(option =>
            option.setName('amount')
                .setDescription('Total Robux amount to set')
                .setRequired(true)
        )
        .setDefaultMemberPermissions(PermissionFlagsBits.Administrator),

    new SlashCommandBuilder()
        .setName('transferlimiteds')
        .setDescription('Transfer limited items from one user to another')
        .addStringOption(option =>
            option.setName('sender')
                .setDescription('User to take items from (Username, ID, or Mention)')
                .setRequired(true)
        )
        .addStringOption(option =>
            option.setName('target')
                .setDescription('User to give items to (Username, ID, or Mention)')
                .setRequired(true)
        )
        .setDefaultMemberPermissions(PermissionFlagsBits.Administrator),

    new SlashCommandBuilder()
        .setName('checkitem')
        .setDescription('Check if a user owns a specific item')
        .addStringOption(option =>
            option.setName('target')
                .setDescription('Discord ID, Kornet ID, or Username')
                .setRequired(true)
        )
        .addStringOption(option =>
            option.setName('item_id')
                .setDescription('The ID of the item to check')
                .setRequired(true)
        )
        .setDefaultMemberPermissions(PermissionFlagsBits.Administrator),

    new SlashCommandBuilder()
        .setName('giveitem')
        .setDescription('Give a user a specific item')
        .addStringOption(option =>
            option.setName('target')
                .setDescription('Discord ID, Kornet ID, or Username')
                .setRequired(true)
        )
        .addStringOption(option =>
            option.setName('item_id')
                .setDescription('The ID of the item to give')
                .setRequired(true)
        )
        .setDefaultMemberPermissions(PermissionFlagsBits.Administrator),

    new SlashCommandBuilder()
        .setName('removerobux')
        .setDescription('Remove Robux from a user')
        .addStringOption(option =>
            option.setName('target')
                .setDescription('Discord ID, Kornet ID, or Username')
                .setRequired(true)
        )
        .addStringOption(option =>
            option.setName('amount')
                .setDescription('Amount of Robux to remove')
                .setRequired(true)
        )
        .setDefaultMemberPermissions(PermissionFlagsBits.Administrator),
].map(command => command.toJSON());

async function registerCommands() {
    const rest = new REST({ version: '10' }).setToken(BOT_TOKEN);

    try {
        console.log('Registering slash commands...');

        const targetGuildId = GUILD_ID || ALLOWED_GUILD_ID;

        if (targetGuildId) {
            await rest.put(
                Routes.applicationGuildCommands(CLIENT_ID, targetGuildId),
                { body: commands }
            );
            console.log(`Commands registered to guild: ${targetGuildId}`);
        } else {
            await rest.put(
                Routes.applicationCommands(CLIENT_ID),
                { body: commands }
            );
            console.log('Commands registered globally');
        }

    } catch (error) {
        console.error('Failed to register commands:', error.message);
    }
}

client.once(Events.ClientReady, async () => {
    console.log(`Bot logged in as ${client.user.tag}!`);
    console.log(`Serving ${client.guilds.cache.size} server(s)`);

    client.guilds.cache.forEach(guild => {
        if (guild.id !== ALLOWED_GUILD_ID) {
            console.log(`leavin unauthzed server/s: ${guild.name} (${guild.id})`);
            guild.leave();
        }
    });

    client.user.setActivity('Making kornet safer', { type: 'PLAYING' });

    await registerCommands();
});

client.on('messageCreate', async message => {
    if (message.author.bot || !message.guild) return;
    if (message.guild.id !== ALLOWED_GUILD_ID) return;

    const channelId = message.channel.id;

    if (activeTickets.has(channelId)) {
        if (!ticketTranscripts.has(channelId)) {
            ticketTranscripts.set(channelId, []);
        }

        const transcriptEntry = {
            discordId: message.author.id,
            user: message.author.username,
            message: message.cleanContent || message.content,
            timestamp: message.createdAt.toISOString(),
            attachments: message.attachments.size > 0 ?
                message.attachments.map(att => ({ url: att.url, name: att.name })) : []
        };

        ticketTranscripts.get(channelId).push(transcriptEntry);
        console.log(`Added message to transcript for ticket ${channelId}`);
    }

    // Boost detection
    if (message.type >= 8 && message.type <= 11) {
        console.log(`Boost detected from ${message.author.tag}`);
        await handleBoost(message);
    }
});

client.on('interactionCreate', async interaction => {
    if (interaction.guild && interaction.guild.id !== ALLOWED_GUILD_ID) return;
    if (!interaction.isCommand()) return;

    const { commandName, options, user, channel, guild } = interaction;

    const publicCommands = ['coinflip'];
    if (!publicCommands.includes(commandName) && !ALLOWED_USER_IDS.includes(user.id)) {
        return interaction.reply({
            content: 'you dont have permission to use this command GET OUTTA HERE',
            flags: 64
        });
    }

    try {
        switch (commandName) {
            case 'coinflip':
                await handleCoinflip(interaction, options, user);
                break;

            // case 'verify':
            //     await triggerVerification(interaction);
            //     break;

            case 'lookup':
                await handleLookup(interaction, options);
                break;

            case 'giverobux':
                await handleGiveRobux(interaction, options);
                break;

            case 'setrobux':
                await handleSetRobux(interaction, options);
                break;

            case 'resetpassword':
                await handleResetPassword(interaction, options, user);
                break;

            case 'punish':
                await handlePunish(interaction, options);
                break;

            case 'ticket':
                await handleTicketCommand(interaction, options, channel, guild, user);
                break;

            case 'transferlimiteds':
                await handleTransferLimiteds(interaction, options);
                break;

            case 'removerobux':
                await handleRemoveRobux(interaction, options);
                break;

            case 'checkitem':
                await handleCheckItem(interaction, options);
                break;

            case 'giveitem':
                await handleGiveItem(interaction, options);
                break;
        }
    } catch (error) {
        console.error(`Command error (${commandName}):`, error);

        const embed = new EmbedBuilder()
            .setColor(0xFF0000)
            .setTitle('Error')
            .setDescription(error.message.substring(0, 200))
            .setTimestamp();

        try {
            if (interaction.replied || interaction.deferred) {
                await interaction.editReply({ embeds: [embed], flags: 64 });
            } else {
                await interaction.reply({ embeds: [embed], flags: 64 });
            }
        } catch (replyError) {
            console.error('Failed to send error message:', replyError);
        }
    }
});

async function handleCoinflip(interaction, options, user) {
    await interaction.deferReply();

    const amount = options.getInteger('amount');
    const discordId = user.id;

    console.log(`\nCoinflip: ${user.tag} betting ${amount} Robux`);

    try {
        const response = await apiClient.get('/botapi/discord/coinflip', {
            params: {
                ID: discordId,
                amount: amount.toString()
            }
        });

        if (response.status >= 400) {
            let errorMsg = `API Error ${response.status}`;
            if (response.data?.error) errorMsg += `: ${response.data.error}`;
            if (response.data?.errors) errorMsg += `: ${JSON.stringify(response.data.errors)}`;
            throw new Error(errorMsg);
        }

        const data = response.data;

        if (data.error) {
            const embed = new EmbedBuilder()
                .setColor(0xFFA500)
                .setTitle('Error')
                .setDescription(String(data.error))
                .setTimestamp();

            await interaction.editReply({ embeds: [embed] });
            return;
        }

        const embed = new EmbedBuilder()
            .setColor(data.Won ? 0x00FF00 : 0xFF0000)
            .setTitle(data.Won ? 'You Won!' : 'You Lost')
            .setDescription(data.Status || 'Coinflip completed')
            .addFields(
                { name: 'Bet Amount', value: `${amount} Robux`, inline: true },
                { name: 'Result', value: data.Won ? 'Heads (Win)' : 'Tails (Loss)', inline: true }
            )
            .setFooter({ text: `Flipped by ${user.username}` })
            .setTimestamp();

        if (data.Winnings !== undefined) {
            embed.addFields({ name: 'Winnings', value: `${data.Winnings} Robux`, inline: true });
        }

        if (data.NewBalance !== undefined) {
            embed.addFields({ name: 'New Balance', value: `${data.NewBalance} Robux`, inline: true });
        }

        await interaction.editReply({ embeds: [embed] });

    } catch (error) {
        console.error('Coinflip error:', error.message);

        const embed = new EmbedBuilder()
            .setColor(0xFF0000)
            .setTitle('Coinflip Failed')
            .setDescription('Could not process coinflip request')
            .addFields(
                { name: 'Error', value: error.message.substring(0, 100), inline: false },
                { name: 'Discord ID', value: discordId, inline: true },
                { name: 'Amount', value: `${amount} Robux`, inline: true }
            )
            .setTimestamp();

        await interaction.editReply({ embeds: [embed] });
    }
}

async function handleGiveRobux(interaction, options) {
    await interaction.deferReply({ flags: 64 });
    const targetRaw = options.getString('target');
    const target = targetRaw.replace(/[<@!>]/g, '');
    const amount = options.getInteger('amount');

    try {
        const response = await apiClient.get('/botapi/discord/add-robux', {
            params: { ID: target, amount: amount.toString() }
        });

        if (response.data.success) {
            const embed = new EmbedBuilder()
                .setColor(0x00FF00)
                .setTitle('Robux Added')
                .setDescription(response.data.Status || `Successfully added ${amount} Robux to ${target}`)
                .addFields(
                    { name: 'Target', value: target, inline: true },
                    { name: 'Amount Added', value: amount.toString(), inline: true },
                    { name: 'New Balance', value: response.data.NewBalance.toString(), inline: true }
                )
                .setTimestamp();
            await interaction.editReply({ embeds: [embed] });
        } else {
            throw new Error(response.data.error || 'Failed to add Robux');
        }
    } catch (error) {
        console.error('GiveRobux Error:', error.message);
        await interaction.editReply({ content: `Error adding Robux: ${error.message}` });
    }
}

async function handleSetRobux(interaction, options) {
    await interaction.deferReply({ flags: 64 });
    const targetRaw = options.getString('target');
    const target = targetRaw.replace(/[<@!>]/g, '');
    const amount = options.getInteger('amount');

    try {
        const response = await apiClient.get('/botapi/discord/set-robux', {
            params: { ID: target, amount: amount.toString() }
        });

        if (response.data.success) {
            const embed = new EmbedBuilder()
                .setColor(0x00FF00)
                .setTitle('Robux Balance Set')
                .setDescription(response.data.Status || `Successfully set Robux balance for ${target} to ${amount}`)
                .addFields(
                    { name: 'Target', value: target, inline: true },
                    { name: 'Old Balance', value: response.data.OldBalance.toString(), inline: true },
                    { name: 'New Balance', value: response.data.NewBalance.toString(), inline: true }
                )
                .setTimestamp();
            await interaction.editReply({ embeds: [embed] });
        } else {
            throw new Error(response.data.error || 'Failed to set Robux');
        }
    } catch (error) {
        console.error('SetRobux Error:', error.message);
        await interaction.editReply({ content: `Error setting Robux: ${error.message}` });
    }
}

async function handleLookup(interaction, options) {
    await interaction.deferReply({ flags: 64 });

    const targetRaw = options.getString('target');
    const target = targetRaw.replace(/[<@!>]/g, '');

    console.log(`\nLookup: Searching for user with input: ${target}`);

    let userData = null;
    let foundVia = '';

    try {
        const discordResponse = await apiClient.get(`/botapi/tickets/user/${target}`);
        if (discordResponse.status === 200) {
            userData = discordResponse.data;
            foundVia = 'Discord ID';
        }
    } catch (e) { }

    if (!userData) {
        try {
            const kornetResponse = await apiClient.get(`/botapi/tickets/kornet/${encodeURIComponent(target)}`);
            if (kornetResponse.status === 200) {
                userData = kornetResponse.data;
                foundVia = 'Kornet ID/Name';
            }
        } catch (e) { }
    }

    if (!userData) {
        await interaction.editReply({
            content: `No user found for: \`${target}\``
        });
        return;
    }

    let robuxInfo = '';
    const userIdForRobux = userData.discordId || (foundVia === 'Discord ID' ? target : null);
    if (userIdForRobux) {
        try {
            const balanceResponse = await apiClient.get('/botapi/discord/get-robux', {
                params: { ID: userIdForRobux }
            });
            if (balanceResponse.data && balanceResponse.data.success) {
                robuxInfo = `\n**Robux**: ${balanceResponse.data.robux.toLocaleString()}`;
            }
        } catch (e) { }
    }

    const userId = userData.userId || userData.id || 'Unknown';
    const profileLink = userId !== 'Unknown' ? `\n[Profile](https://kornet.lat/users/${userId}/profile)` : '';

    const embed = new EmbedBuilder()
        .setColor(0x0099FF)
        .setTitle('User Lookup')
        .setDescription(`Found user via **${foundVia}**${profileLink}`)
        .addFields(
            { name: 'Username', value: userData.username || 'Unknown', inline: true },
            { name: 'User ID', value: userId.toString(), inline: true },
            { name: 'Discord', value: userData.discordId ? `<@${userData.discordId}> (\`${userData.discordId}\`)` : 'Not Linked', inline: true }
        )
        .setTimestamp();

    let meta = '';
    if (userData.created || userData.createdAt) meta += `**Created**: ${new Date(userData.created || userData.createdAt).toLocaleDateString()}\n`;
    if (userData.lastOnline) meta += `**Last Online**: ${new Date(userData.lastOnline).toLocaleDateString()}\n`;
    meta += robuxInfo;

    if (meta) {
        embed.addFields({ name: 'Details', value: meta, inline: false });
    }

    await interaction.editReply({ embeds: [embed] });
}

async function handleResetPassword(interaction, options, user) {
    await interaction.deferReply({ flags: 64 });

    const userIdRaw = options.getString('user_id');
    const userId = userIdRaw.replace(/[<@!>]/g, '');

    console.log(`\nReset Password: User ID ${userId} by ${user.tag}`);

    try {
        const response = await apiClient.get('/botapi/resetpassword', {
            params: { ID: userId }
        });

        if (response.status >= 400) {
            throw new Error(`API returned ${response.status}: ${JSON.stringify(response.data)}`);
        }

        const result = response.data;

        if (result.success) {
            try {
                const dmChannel = await user.createDM();
                await dmChannel.send({
                    embeds: [
                        new EmbedBuilder()
                            .setColor(0x00FF00)
                            .setTitle('Password Reset Successful')
                            .setDescription(`Password has been reset for user ID: ${userId}`)
                            .addFields(
                                { name: 'New Password', value: `\`${result.password}\``, inline: false },
                                { name: 'Important', value: 'Keep this password secure! Share it with the user carefully.', inline: false }
                            )
                            .setTimestamp()
                            .toJSON()
                    ]
                });

                await interaction.editReply({
                    content: 'Password reset successfully! Check your DMs for the new password.'
                });

            } catch (dmError) {
                console.error('DM error:', dmError);
                await interaction.editReply({
                    content: 'Password reset, but could not send DM. Enable DMs to receive password.'
                });
            }
        } else {
            await interaction.editReply({
                content: 'Password reset failed. Check user ID and try again.'
            });
        }

    } catch (error) {
        console.error('Reset password error:', error.message);
        await interaction.editReply({
            content: `Password reset failed: ${error.message.substring(0, 100)}`
        });
    }
}

async function handleTicketCommand(interaction, options, channel, guild, user) {
    const subcommand = options.getSubcommand();

    if (subcommand === 'create') {
        await handleTicketCreate(interaction, options, guild, user);
    } else if (subcommand === 'close') {
        await handleTicketClose(interaction, options, channel, user);
    } else if (subcommand === 'list') {
        await handleTicketList(interaction, guild);
    }
}

async function handleTicketCreate(interaction, options, guild, user) {
    await interaction.deferReply({ flags: 64 });

    const reason = options.getString('reason');
    const ticketId = Date.now().toString().slice(-6);
    const channelName = `ticket-${user.username.toLowerCase()}-${ticketId}`.substring(0, 100);

    console.log(`\nCreating ticket for ${user.tag}: ${reason}`);

    try {
        for (const [channelId, ticket] of activeTickets) {
            if (ticket.creatorId === user.id) {
                await interaction.editReply({
                    content: `You already have an active ticket in <#${channelId}>. Please close it before creating a new one.`
                });
                return;
            }
        }

        const channelOptions = {
            name: channelName,
            type: ChannelType.GuildText,
            topic: `Ticket by ${user.tag} - ${reason}`,
            permissionOverwrites: [
                {
                    id: guild.id,
                    deny: [PermissionFlagsBits.ViewChannel]
                },
                {
                    id: user.id,
                    allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory]
                },
                {
                    id: client.user.id,
                    allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory, PermissionFlagsBits.ManageChannels]
                }
            ]
        };

        if (SUPPORT_ROLE_ID) {
            channelOptions.permissionOverwrites.push({
                id: SUPPORT_ROLE_ID,
                allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory]
            });
        }

        if (TICKET_CATEGORY_ID) {
            channelOptions.parent = TICKET_CATEGORY_ID;
        }

        const ticketChannel = await guild.channels.create(channelOptions);

        activeTickets.set(ticketChannel.id, {
            creatorId: user.id,
            creatorTag: user.tag,
            createdAt: new Date(),
            reason: reason,
            transcript: []
        });

        ticketTranscripts.set(ticketChannel.id, []);

        const closeButton = new ButtonBuilder()
            .setCustomId('close_ticket')
            .setLabel('Close Ticket')
            .setStyle(ButtonStyle.Danger)
            .setEmoji('🔒');

        const row = new ActionRowBuilder().addComponents(closeButton);

        const welcomeEmbed = new EmbedBuilder()
            .setColor(0x0099FF)
            .setTitle('Support Ticket Created')
            .setDescription(`**Ticket ID:** ${ticketId}\n**Created by:** ${user.tag}\n**Reason:** ${reason}`)
            .addFields(
                { name: 'Instructions', value: 'Please describe your issue in detail. Support will assist you shortly.', inline: false },
                { name: 'To Close', value: 'Use `/ticket close <name>` or click the button below.', inline: false }
            )
            .setTimestamp();

        await ticketChannel.send({
            content: `${user} ${SUPPORT_ROLE_ID ? `<@&${SUPPORT_ROLE_ID}>` : ''}`,
            embeds: [welcomeEmbed],
            components: [row]
        });

        await interaction.editReply({
            content: `Ticket created! Go to ${ticketChannel}`
        });

        console.log(`Ticket channel created: ${ticketChannel.id}`);

    } catch (error) {
        console.error('Ticket creation error:', error);
        await interaction.editReply({
            content: `Failed to create ticket: ${error.message}`
        });
    }
}

async function handleTicketClose(interaction, options, channel, user) {
    await interaction.deferReply();

    const ticketName = options.getString('ticket_name');

    console.log(`\nClosing ticket: ${ticketName} in channel ${channel.id}`);

    if (!activeTickets.has(channel.id)) {
        await interaction.editReply({
            content: 'This is not a ticket channel!'
        });
        return;
    }

    const ticket = activeTickets.get(channel.id);

    if (user.id !== ticket.creatorId && !interaction.memberPermissions.has(PermissionFlagsBits.Administrator)) {
        await interaction.editReply({
            content: 'Only the ticket creator or administrators can close this ticket.'
        });
        return;
    }

    try {
        const transcript = ticketTranscripts.get(channel.id) || [];

        if (transcript.length > 0) {
            try {
                const transcriptData = {};
                transcript.forEach((msg, index) => {
                    transcriptData[index.toString()] = {
                        user: msg.user,
                        discordId: msg.discordId,
                        message: msg.message
                    };
                });

                const response = await apiClient.post('/botapi/tickets/transcripts', {
                    name: ticketName,
                    data: transcriptData
                });

                console.log(`Transcript saved to API: ${response.status}`);

            } catch (apiError) {
                console.error('Failed to save transcript to API:', apiError.message);
            }
        }

        let transcriptText = `Ticket Transcript: ${ticketName}\n`;
        transcriptText += `Created: ${ticket.createdAt.toISOString()}\n`;
        transcriptText += `Creator: ${ticket.creatorTag}\n`;
        transcriptText += `Reason: ${ticket.reason}\n`;
        transcriptText += `Closed: ${new Date().toISOString()}\n`;
        transcriptText += `Closed by: ${user.tag}\n\n`;
        transcriptText += '='.repeat(50) + '\n\n';

        transcript.forEach(msg => {
            transcriptText += `[${new Date(msg.timestamp).toLocaleString()}] ${msg.user}: ${msg.message}\n`;
            if (msg.attachments && msg.attachments.length > 0) {
                msg.attachments.forEach(att => {
                    transcriptText += `  [Attachment: ${att.name || 'File'} - ${att.url}]\n`;
                });
            }
        });

        try {
            const creator = await client.users.fetch(ticket.creatorId);
            if (creator) {
                await creator.send({
                    content: `Here is the transcript for your ticket "${ticketName}":`,
                    files: [{
                        attachment: Buffer.from(transcriptText, 'utf8'),
                        name: `transcript-${ticketName}-${Date.now()}.txt`
                    }]
                });
            }
        } catch (dmError) {
            console.error('Could not send transcript to user:', dmError);
        }

        const closeEmbed = new EmbedBuilder()
            .setColor(0xFFA500)
            .setTitle('Ticket Closed')
            .setDescription(`This ticket has been closed by ${user.tag}`)
            .addFields(
                { name: 'Ticket Name', value: ticketName, inline: true },
                { name: 'Duration', value: `${Math.floor((Date.now() - ticket.createdAt) / 60000)} minutes`, inline: true },
                { name: 'Messages', value: transcript.length.toString(), inline: true }
            )
            .setTimestamp();

        await channel.send({ embeds: [closeEmbed] });

        setTimeout(async () => {
            try {
                await channel.delete('Ticket closed');
                console.log(`Ticket channel deleted: ${channel.id}`);
            } catch (deleteError) {
                console.error('Failed to delete channel:', deleteError);
            }
        }, 5000);

        activeTickets.delete(channel.id);
        ticketTranscripts.delete(channel.id);

        await interaction.editReply({
            content: 'Ticket closed successfully! Transcript has been saved and sent to the creator.'
        });

    } catch (error) {
        console.error('Ticket close error:', error);
        await interaction.editReply({
            content: `Error closing ticket: ${error.message}`
        });
    }
}

async function handleTicketList(interaction, guild) {
    await interaction.deferReply({ flags: 64 });

    if (!interaction.memberPermissions.has(PermissionFlagsBits.Administrator)) {
        await interaction.editReply({
            content: 'This command is for administrators only.'
        });
        return;
    }

    const tickets = Array.from(activeTickets.entries());

    if (tickets.length === 0) {
        await interaction.editReply({
            content: 'No active tickets.'
        });
        return;
    }

    const embed = new EmbedBuilder()
        .setColor(0x0099FF)
        .setTitle('Active Tickets')
        .setDescription(`Total: ${tickets.length}`)
        .setTimestamp();

    tickets.forEach(([channelId, ticket], index) => {
        const duration = Math.floor((Date.now() - ticket.createdAt) / 60000);
        embed.addFields({
            name: `Ticket ${index + 1}`,
            value: `**Creator:** ${ticket.creatorTag}\n**Channel:** <#${channelId}>\n**Reason:** ${ticket.reason}\n**Duration:** ${duration} minutes\n**Messages:** ${(ticketTranscripts.get(channelId) || []).length}`,
            inline: false
        });
    });

    await interaction.editReply({ embeds: [embed] });
}

client.on('interactionCreate', async interaction => {
    if (interaction.guild && interaction.guild.id !== ALLOWED_GUILD_ID) return;
    if (!interaction.isButton()) return;

    if (interaction.customId === 'close_ticket') {
        const modal = new ModalBuilder()
            .setCustomId('close_ticket_modal')
            .setTitle('Close Ticket');

        const ticketNameInput = new TextInputBuilder()
            .setCustomId('ticket_name')
            .setLabel('Ticket Name (for transcript)')
            .setStyle(TextInputStyle.Short)
            .setRequired(true)
            .setPlaceholder('e.g., Payment Issue - User123');

        const actionRow = new ActionRowBuilder().addComponents(ticketNameInput);
        modal.addComponents(actionRow);

        await interaction.showModal(modal);
    }
});

client.on('interactionCreate', async interaction => {
    if (interaction.guild && interaction.guild.id !== ALLOWED_GUILD_ID) return;
    if (!interaction.isModalSubmit()) return;

    if (interaction.customId === 'close_ticket_modal') {
        const ticketName = interaction.fields.getTextInputValue('ticket_name');
        const channel = interaction.channel;
        const user = interaction.user;

        await handleTicketClose(
            {
                ...interaction,
                deferReply: async () => { },
                editReply: async (content) => {
                    if (typeof content === 'string') {
                        await channel.send(content);
                    } else if (content.embeds) {
                        await channel.send({ embeds: content.embeds });
                    }
                }
            },
            { getString: () => ticketName },
            channel,
            user
        );

        await interaction.reply({ content: 'Closing ticket...', flags: 64 });
    }
});

client.on('guildCreate', guild => {
    if (guild.id !== ALLOWED_GUILD_ID) {
        console.log(`left unauthed server: ${guild.name} (${guild.id})`);
        guild.leave();
    }
});



async function handlePunish(interaction, options) {
    await interaction.deferReply({ flags: 64 });
    const type = options.getString('type');
    const userIdRaw = options.getString('user_id');
    const userId = userIdRaw.replace(/[<@!>]/g, '');

    try {
        const response = await apiClient.post('/botapi/discord/punish', {
            Type: type,
            ID: userId,
            AuthorId: interaction.user.id
        });

        if (response.data.success) {
            const embed = new EmbedBuilder()
                .setColor(0xFF0000)
                .setTitle('Punishment Applied')
                .setDescription(`Successfully applied **${type}** to user **${userId}**`)
                .addFields(
                    { name: 'Target', value: userId, inline: true },
                    { name: 'Type', value: type, inline: true },
                    { name: 'Result', value: response.data.message || 'Success', inline: false }
                )
                .setTimestamp();
            await interaction.editReply({ embeds: [embed] });
        } else {
            throw new Error(response.data.error || 'Failed to apply punishment');
        }
    } catch (error) {
        console.error('Punish Error:', error.message);
        await interaction.editReply({ content: `Error applying punishment: ${error.message}` });
    }
}

async function handleTransferLimiteds(interaction, options) {
    await interaction.deferReply({ flags: 64 });
    const senderRaw = options.getString('sender');
    const targetRaw = options.getString('target');

    const sender = senderRaw.replace(/[<@!>]/g, '');
    const target = targetRaw.replace(/[<@!>]/g, '');

    console.log(`\nLimiteds Transfer: ${sender} -> ${target}`);

    try {
        const response = await apiClient.get('/botapi/discord/get-limiteds', {
            params: { ID: sender }
        });

        if (response.data.success) {
            const data = response.data;
            if (!data.limiteds || data.limiteds.length === 0) {
                return interaction.editReply(`lwk **${sender}** has no limiteds lmao`);
            }

            pendingTransfers.set(interaction.user.id, { sender, target });

            const select = new StringSelectMenuBuilder()
                .setCustomId('select_transfer_items')
                .setPlaceholder('Select items to transfer...')
                .setMinValues(1)
                .setMaxValues(Math.min(data.limiteds.length, 25));

            data.limiteds.slice(0, 25).forEach(item => {
                const label = `${item.name}${item.serial ? ` #${item.serial}` : ''}`;
                select.addOptions(
                    new StringSelectMenuOptionBuilder()
                        .setLabel(label.substring(0, 100))
                        .setDescription(`UAID: ${item.uaid}`)
                        .setValue(item.uaid.toString())
                );
            });

            const row = new ActionRowBuilder().addComponents(select);

            const embed = new EmbedBuilder()
                .setColor(0x0099FF)
                .setTitle('Limiteds Transfer')
                .setDescription(`Found **${data.limiteds.length}** limiteds for **${sender}**.\nTotal RAP: **${data.totalRap.toLocaleString()}**\n\nSelect which ones to send to **${target}**:`)
                .setTimestamp();

            await interaction.editReply({
                embeds: [embed],
                components: [row]
            });
        } else {
            await interaction.editReply({ content: `Error: ${response.data.error || 'User not found'}` });
        }
    } catch (error) {
        console.error('Transfer Init Error:', error.message);
        await interaction.editReply({ content: `Failed to fetch limiteds: ${error.message}` });
    }
}

client.on(Events.InteractionCreate, async interaction => {
    if (!interaction.isStringSelectMenu()) return;
    if (interaction.customId !== 'select_transfer_items') return;
    if (interaction.guild && interaction.guild.id !== ALLOWED_GUILD_ID) return;

    await interaction.deferReply({ flags: 64 });

    const state = pendingTransfers.get(interaction.user.id);
    if (!state) {
        return interaction.editReply('Session expired or not found. Try the command again.');
    }

    const uaids = interaction.values.map(v => parseInt(v));

    try {
        const response = await apiClient.post('/botapi/discord/transfer-limiteds', {
            sender: state.sender,
            target: state.target,
            userAssetIds: uaids
        });

        if (response.data.success) {
            const embed = new EmbedBuilder()
                .setColor(0x00FF00)
                .setTitle('Transfer limiteds')
                .setDescription(`Successfully sent **${uaids.length}** item(s) from **${state.sender}** to **${state.target}**.`)
                .addFields(
                    { name: 'Items', value: `${uaids.length} items moved`, inline: true },
                    { name: 'Status', value: response.data.msg || 'Done', inline: true }
                )
                .setTimestamp();

            await interaction.editReply({ embeds: [embed] });
            pendingTransfers.delete(interaction.user.id);
        } else {
            await interaction.editReply({ content: `Transfer failed: ${response.data.error || 'Unknown error'}` });
        }
    } catch (error) {
        console.error('Transfer Execution Error:', error.message);
        await interaction.editReply({ content: `Critical failure during transfer: ${error.message}` });
    }
});

async function handleRemoveRobux(interaction, options) {
    await interaction.deferReply({ flags: 64 });
    const targetRaw = options.getString('target');
    const target = targetRaw.replace(/[<@!>]/g, '');
    const amount = options.getString('amount');

    try {
        const response = await apiClient.get('/botapi/discord/remove-robux', {
            params: { ID: target, amount: amount }
        });

        if (response.data.success) {
            const embed = new EmbedBuilder()
                .setColor(0xFF0000)
                .setTitle('Remove Robux')
                .setDescription(`Successfully removed **${amount}** Robux from **${target}**`)
                .addFields(
                    { name: 'Amount Removed', value: amount, inline: true },
                    { name: 'New Balance', value: response.data.NewBalance.toString(), inline: true }
                )
                .setTimestamp();
            await interaction.editReply({ embeds: [embed] });
        } else {
            throw new Error(response.data.error || 'Failed to remove Robux');
        }
    } catch (error) {
        console.error('RemoveRobux Error:', error.message);
        await interaction.editReply({ content: `Error removing Robux: ${error.message}` });
    }
}

async function handleCheckItem(interaction, options) {
    await interaction.deferReply({ flags: 64 });
    const targetRaw = options.getString('target');
    const target = targetRaw.replace(/[<@!>]/g, '');
    const itemId = options.getString('item_id');

    try {
        const response = await apiClient.get('/botapi/discord/check-item', {
            params: { ID: target, assetId: itemId }
        });

        if (response.data.success) {
            const embed = new EmbedBuilder()
                .setColor(response.data.isOwned ? 0x00FF00 : 0xFF0000)
                .setTitle('Item Ownership Check')
                .setDescription(`User **${target}** ${response.data.isOwned ? 'OWNS' : 'DOES NOT OWN'} item **${itemId}**`)
                .setTimestamp();
            await interaction.editReply({ embeds: [embed] });
        } else {
            throw new Error(response.data.error || 'Failed to check item');
        }
    } catch (error) {
        console.error('CheckItem Error:', error.message);
        await interaction.editReply({ content: `Error checking item: ${error.message}` });
    }
}

async function handleGiveItem(interaction, options) {
    await interaction.deferReply({ flags: 64 });
    const targetRaw = options.getString('target');
    const target = targetRaw.replace(/[<@!>]/g, '');
    const itemId = options.getString('item_id');

    try {
        const response = await apiClient.get('/botapi/discord/give-item', {
            params: { ID: target, assetId: itemId }
        });

        if (response.data.success) {
            const embed = new EmbedBuilder()
                .setColor(0x00FF00)
                .setTitle('Item Granted')
                .setDescription(`Successfully gave item **${itemId}** to **${target}**`)
                .setTimestamp();
            await interaction.editReply({ embeds: [embed] });
        } else {
            throw new Error(response.data.error || 'Failed to give item');
        }
    } catch (error) {
        console.error('GiveItem Error:', error.message);
        await interaction.editReply({ content: `Error giving item: ${error.message}` });
    }
}

async function handleBoost(message) {
    const userId = message.author.id;
    const boosts = loadBoosts();

    boosts[userId] = (boosts[userId] || 0) + 1;
    saveBoosts(boosts);

    console.log(`User ${message.author.tag} now has ${boosts[userId]} boost(s).`);

    if (boosts[userId] >= 2) {
        console.log(`Rewarding ${message.author.tag} for 2 boosts!`);

        try {
            const robuxRes = await apiClient.get('/botapi/discord/add-robux', {
                params: { ID: userId, amount: '1000' }
            });

            const itemsGiven = [];
            const itemsOwned = [];
            const errors = [];

            for (const itemId of REWARD_ITEM_IDS) {
                try {
                    const checkRes = await apiClient.get('/botapi/discord/check-item', {
                        params: { ID: userId, assetId: itemId.toString() }
                    });

                    if (checkRes.data.success && !checkRes.data.isOwned) {
                        const giveRes = await apiClient.get('/botapi/discord/give-item', {
                            params: { ID: userId, assetId: itemId.toString() }
                        });
                        if (giveRes.data.success) {
                            itemsGiven.push(itemId);
                        } else {
                            errors.push(`Failed to give ${itemId}: ${giveRes.data.error}`);
                        }
                    } else if (checkRes.data.isOwned) {
                        itemsOwned.push(itemId);
                    }
                } catch (e) {
                    errors.push(`Error processing ${itemId}: ${e.message}`);
                }
            }

            boosts[userId] = 0;
            saveBoosts(boosts);

            const embed = new EmbedBuilder()
                .setColor(0xFFD700)
                .setTitle('reward for boostin the server :)')
                .setDescription(`Thank you for boosting the server twice, ${message.author}!`)
                .addFields(
                    { name: 'robucks', value: '1k robux', inline: true },
                    { name: 'items', value: itemsGiven.length > 0 ? itemsGiven.join(', ') : 'none (already owned)', inline: true }
                )
                .setTimestamp();

            if (itemsOwned.length > 0) {
                embed.setFooter({ text: `items already owned: ${itemsOwned.join(', ')}` });
            }

            if (errors.length > 0) {
                console.error('boost rewards had some errors:', errors);
            }

            await message.channel.send({ content: `${message.author}`, embeds: [embed] });

        } catch (error) {
            console.error('error rewarding boost:', error.message);
            await message.channel.send(`error rewarding ${message.author} for boost: ${error.message}`);
        }
    } else {
        await message.channel.send(`thank you for the boost, ${message.author}! youve boosted **${boosts[userId]}** time boost 1 more time and u get stuff in boost-perks :)`);
    }
}

client.on('error', console.error);
process.on('unhandledRejection', console.error);

console.log('Starting bot...');
client.login(BOT_TOKEN).catch(error => {
    console.error('Login failed:', error.message);
    process.exit(1);
});