const { Client, GatewayIntentBits, SlashCommandBuilder, REST, Routes, EmbedBuilder, PermissionFlagsBits, ChannelType, ActionRowBuilder, ButtonBuilder, ButtonStyle } = require('discord.js');
const axios = require('axios');
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
        .setDescription('Look up a user by Discord ID')
        .addStringOption(option =>
            option.setName('discord_id')
                .setDescription('Discord ID to look up')
                .setRequired(true)
        ),
    
    new SlashCommandBuilder()
        .setName('resetpassword')
        .setDescription('[ADMIN] Reset a user\'s password')
        .addStringOption(option =>
            option.setName('user_id')
                .setDescription('User ID to reset password for')
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
        ),
    
    new SlashCommandBuilder()
        .setName('help')
        .setDescription('Show all available commands'),
    
    new SlashCommandBuilder()
        .setName('test')
        .setDescription('Test API connection and permissions')
].map(command => command.toJSON());

async function registerCommands() {
    const rest = new REST({ version: '10' }).setToken(BOT_TOKEN);
    
    try {
        console.log('Registering slash commands...');
        
        if (GUILD_ID) {
            await rest.put(
                Routes.applicationGuildCommands(CLIENT_ID, GUILD_ID),
                { body: commands }
            );
            console.log(`Commands registered to guild: ${GUILD_ID}`);
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

client.once('clientReady', async () => {
    console.log(`Bot logged in as ${client.user.tag}!`);
    console.log(`Serving ${client.guilds.cache.size} server(s)`);
    
    client.user.setActivity('Making kornet safer', { type: 'PLAYING' });
    
    await registerCommands();
});

client.on('messageCreate', async message => {
    if (message.author.bot || !message.guild) return;
    
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
});

client.on('interactionCreate', async interaction => {
    if (!interaction.isCommand()) return;

    const { commandName, options, user, channel, guild } = interaction;

    try {
        switch (commandName) {
            case 'coinflip':
                await handleCoinflip(interaction, options, user);
                break;
                
            case 'verify':
                await triggerVerification(interaction);
                break;

            case 'lookup':
                await handleLookup(interaction, options);
                break;
                
            case 'resetpassword':
                await handleResetPassword(interaction, options, user);
                break;
                
            case 'ticket':
                await handleTicketCommand(interaction, options, channel, guild, user);
                break;
                
            case 'help':
                await handleHelp(interaction);
                break;
                
            case 'test':
                await handleTest(interaction, user);
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

async function handleLookup(interaction, options) {
    await interaction.deferReply({ flags: 64 });
    
    const discordId = options.getString('discord_id');
    
    console.log(`\nLookup: Searching for Discord ID ${discordId}`);
    
    try {
        const response = await apiClient.get(`/botapi/tickets/user/${discordId}`);
        
        if (response.status === 404) {
            await interaction.editReply({ 
                content: `No user found with Discord ID: \`${discordId}\`` 
            });
            return;
        }
        
        if (response.status >= 400) {
            throw new Error(`API returned ${response.status}: ${JSON.stringify(response.data)}`);
        }
        
        const userData = response.data;
        
        const embed = new EmbedBuilder()
            .setColor(0x0099FF)
            .setTitle('👤 User Lookup')
            .setDescription(`Found user for Discord ID: ${discordId}`)
            .setTimestamp();
        
        const fields = [];
        if (userData.username) fields.push({ name: 'Username', value: userData.username, inline: true });
        if (userData.userId) fields.push({ name: 'User ID', value: userData.userId.toString(), inline: true });
        if (userData.id) fields.push({ name: 'ID', value: userData.id.toString(), inline: true });
        if (userData.createdAt) fields.push({ name: 'Created', value: new Date(userData.createdAt).toLocaleDateString(), inline: true });
        if (userData.robuxBalance !== undefined) fields.push({ name: 'Robux', value: userData.robuxBalance.toString(), inline: true });
        
        if (fields.length > 0) {
            embed.addFields(fields);
        } else {
            embed.addFields({ name: 'Data', value: JSON.stringify(userData, null, 2).substring(0, 1000), inline: false });
        }
        
        await interaction.editReply({ embeds: [embed] });
        
    } catch (error) {
        console.error('Lookup error:', error.message);
        await interaction.editReply({ 
            content: `Lookup failed: ${error.message.substring(0, 100)}` 
        });
    }
}

async function handleResetPassword(interaction, options, user) {
    await interaction.deferReply({ flags: 64 });
    
    const userId = options.getString('user_id');
    
    console.log(`\nReset Password: User ID ${userId} by ${user.tag}`);
    
    try {
        const response = await apiClient.get('/botapi/resetpassword', {
            params: { userId }
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

async function handleHelp(interaction) {
    const embed = new EmbedBuilder()
        .setColor(0x0099FF)
        .setTitle('Support Bot Commands')
        .setDescription('All available commands:')
        .addFields(
            { name: '/coinflip <amount>', value: 'Bet 1-100 Robux on coin flip', inline: false },
            { name: '/lookup <discord_id>', value: 'Find user by Discord ID', inline: false },
            { name: '/resetpassword <user_id>', value: '[ADMIN] Reset user password', inline: false },
            { name: '/ticket create <reason>', value: 'Create support ticket', inline: false },
            { name: '/ticket close <name>', value: 'Close current ticket', inline: false },
            { name: '/ticket list', value: '[ADMIN] List active tickets', inline: false },
            { name: '/help', value: 'Show this message', inline: false }
        )
        .setFooter({ text: `API: ${API_BASE_URL}` })
        .setTimestamp();
    
    await interaction.reply({ embeds: [embed], flags: 64 });
}

async function handleTest(interaction, user) {
    await interaction.deferReply({ flags: 64 });
    
    const tests = [
        { name: 'Bot Status', result: 'Online' },
        { name: 'API Key', result: API_KEY ? 'Set' : 'Missing' },
        { name: 'Active Tickets', result: `${activeTickets.size} active` },
        { name: 'User Permissions', result: interaction.memberPermissions.has(PermissionFlagsBits.Administrator) ? 'Admin' : 'User' }
    ];
    
    try {
        const response = await apiClient.get('/botapi/tickets/user/test', {
            validateStatus: null
        });
        tests.push({ 
            name: 'API Connection', 
            result: response.status === 404 ? 'Connected (expected 404)' : `Status: ${response.status}` 
        });
    } catch (error) {
        tests.push({ name: 'API Connection', result: `Failed: ${error.message}` });
    }
    
    const embed = new EmbedBuilder()
        .setColor(0x0099FF)
        .setTitle('System Test')
        .setDescription('Testing bot functionality...')
        .setTimestamp();
    
    tests.forEach(test => {
        embed.addFields({ name: test.name, value: test.result, inline: true });
    });
    
    await interaction.editReply({ embeds: [embed] });
}

client.on('interactionCreate', async interaction => {
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
    if (!interaction.isModalSubmit()) return;
    
    if (interaction.customId === 'close_ticket_modal') {
        const ticketName = interaction.fields.getTextInputValue('ticket_name');
        const channel = interaction.channel;
        const user = interaction.user;
        
        await handleTicketClose(
            {
                ...interaction,
                deferReply: async () => {},
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


client.on('error', console.error);
process.on('unhandledRejection', console.error);

console.log('Starting bot...');
client.login(BOT_TOKEN).catch(error => {
    console.error('Login failed:', error.message);
    process.exit(1);
});