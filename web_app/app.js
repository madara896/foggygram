// Foggygram Web — Core Client Logic & Telegram Web Engine

// ------------------------------------------------ State Management
const AppState = {
  currentView: 'splash',
  currentAccountIndex: 0,
  isVaultUnlocked: false,
  isGlobalGhostOn: true,
  isChatGhostOn: true,
  enteredPin: '',
  masterPin: '000000',
  activeChatId: 'chat_1',
  activeFolder: 'all',

  accounts: [
    { id: 'acc_1', name: 'Alex Chen', phone: '+1 (555) 019-2834', username: '@alexchen', initial: 'A' },
    { id: 'acc_2', name: 'Work Phone', phone: '+1 (555) 482-9102', username: '@alex_work', initial: 'W' },
    { id: 'acc_3', name: 'Dev Account', phone: '+1 (555) 773-4019', username: '@alex_dev', initial: 'D' }
  ],

  chats: [
    {
      id: 'chat_1',
      name: 'Alex Chen',
      handle: '@alexchen',
      phone: '+1 (555) 019-2834',
      bio: 'Building monochrome glassmorphism apps 🌫️',
      initial: 'A',
      folder: 'private',
      time: '2:45 PM',
      unread: 3,
      isOnline: true,
      messages: [
        { id: 1, text: 'Hey, have you checked the new Foggygram build?', time: '2:30 PM', isOutgoing: false, isRead: true },
        { id: 2, text: 'Yes! The glassmorphism and monochrome aesthetic feel amazing on desktop.', time: '2:32 PM', isOutgoing: true, isRead: true },
        { id: 3, text: 'Wait until you test the Session Vault — all accounts preserved without OTP loops!', time: '2:35 PM', isOutgoing: false, isRead: true },
        { id: 4, text: 'Can anyone delete messages without us knowing?', time: '2:40 PM', isOutgoing: true, isRead: true },
        { id: 5, text: 'Nope, Foggygram preserves all deleted messages locally in SQLite cache!', time: '2:45 PM', isOutgoing: false, isRead: false },
        { id: 6, text: 'Initial design draft sent earlier.', time: '2:46 PM', isOutgoing: false, isRead: false, isDeleted: true, originalText: 'Secret prototype credentials: api_id 38612801' }
      ]
    },
    {
      id: 'chat_2',
      name: 'Foggy AI Assistant',
      handle: '@foggy_agent',
      phone: 'Bot Service',
      bio: 'Agentic AI cloud assistant inside Foggygram ☁️',
      initial: '✨',
      folder: 'bots',
      time: '1:15 PM',
      unread: 1,
      isOnline: true,
      messages: [
        { id: 101, text: 'Hello! I am your autonomous cloud agent. I can analyze conversations, write replies, and manage settings.', time: '1:15 PM', isOutgoing: false, isRead: false }
      ]
    },
    {
      id: 'chat_3',
      name: 'Design Team',
      handle: '@foggy_design',
      phone: 'Group (14 members)',
      bio: 'Foggygram design system and UI iteration group',
      initial: 'D',
      folder: 'groups',
      time: '12:08 PM',
      unread: 12,
      isOnline: false,
      messages: [
        { id: 201, text: 'Sarah: Updated the color tokens to zero-accent pure black and white.', time: '12:05 PM', isOutgoing: false, isRead: true },
        { id: 202, text: 'Marcus: 3D cloud mascot bobbing animation feels great.', time: '12:08 PM', isOutgoing: false, isRead: true }
      ]
    },
    {
      id: 'chat_4',
      name: 'Maya Rivera',
      handle: '@mayarivera',
      phone: '+1 (555) 438-9902',
      bio: 'Crypto & protocol engineer',
      initial: 'M',
      folder: 'private',
      time: '11:42 AM',
      unread: 0,
      isOnline: true,
      messages: [
        { id: 301, text: 'The AES-256 vault export works seamlessly on mobile too!', time: '11:42 AM', isOutgoing: false, isRead: true }
      ]
    },
    {
      id: 'chat_5',
      name: 'Telegram News & Updates',
      handle: '@telegram',
      phone: 'Broadcast Channel',
      bio: 'Official news from Telegram',
      initial: '📢',
      folder: 'channels',
      time: 'Yesterday',
      unread: 0,
      isOnline: false,
      messages: [
        { id: 401, text: 'Telegram Web update: Enhanced multi-account and cloud sessions.', time: 'Yesterday', isOutgoing: false, isRead: true }
      ]
    }
  ]
};

// ------------------------------------------------ Initialization
document.addEventListener('DOMContentLoaded', () => {
  setupMouseParallax();
  renderAccountRail();
  renderChatList();
  renderActiveChat();
});

// ------------------------------------------------ Navigation
function navigateTo(viewId) {
  document.querySelectorAll('.view').forEach(v => v.classList.remove('active'));
  const target = document.getElementById('view-' + viewId);
  if (target) {
    target.classList.add('active');
    AppState.currentView = viewId;
  }
}

// ------------------------------------------------ 3D Cloud Mascot & Parallax
function setupMouseParallax() {
  document.addEventListener('mousemove', e => {
    const mx = (e.clientX / window.innerWidth - 0.5) * 2;
    const my = (e.clientY / window.innerHeight - 0.5) * 2;

    document.querySelectorAll('.cloud').forEach(c => {
      c.style.transform = `rotateY(${mx * 16}deg) rotateX(${my * -13}deg)`;
    });

    document.querySelectorAll('.glint').forEach(g => {
      g.style.transform = `translate(${mx * 4}px, ${my * 4}px)`;
    });

    document.querySelectorAll('.face:not(#vault-face)').forEach(f => {
      f.style.transform = `translate(calc(-50% + ${mx * 7}px), calc(-50% + ${my * 5}px))`;
    });
  });
}

// ------------------------------------------------ Vault PIN Unlock
function enterPinDigit(digit) {
  if (AppState.enteredPin.length < 6) {
    AppState.enteredPin += digit;
    updatePinDisplay();
  }
}

function deletePinDigit() {
  if (AppState.enteredPin.length > 0) {
    AppState.enteredPin = AppState.enteredPin.slice(0, -1);
    updatePinDisplay();
  }
}

function updatePinDisplay() {
  const pin = AppState.enteredPin;
  const vaultFace = document.getElementById('vault-face');
  const speech = document.getElementById('vault-speech');
  const boxes = document.querySelectorAll('.pin-box');

  // Cloud covers eyes when user starts typing password
  if (pin.length > 0) {
    vaultFace.classList.add('covering');
    if (pin.length < 4) {
      speech.textContent = 'Shh, I won\'t peek at your PIN 🙈';
    } else if (pin.length < 6) {
      speech.textContent = 'Almost unlocked... 🔐';
    }
  } else {
    vaultFace.classList.remove('covering');
    speech.textContent = 'Enter your master PIN to unlock 🔐';
  }

  boxes.forEach((box, i) => {
    box.textContent = i < pin.length ? '●' : '';
    box.classList.toggle('filled', i < pin.length);
    box.classList.toggle('active', i === pin.length);
  });

  // Check 6 digits
  if (pin.length === 6) {
    setTimeout(() => {
      if (pin === AppState.masterPin) {
        AppState.isVaultUnlocked = true;
        speech.textContent = 'Vault Decrypted! Welcome back 🌫️';
        setTimeout(() => {
          navigateTo('chat');
        }, 350);
      } else {
        const pinRow = document.getElementById('pin-row');
        pinRow.style.animation = 'shake 0.4s ease';
        speech.textContent = 'Incorrect PIN! Try 000000 🔒';
        setTimeout(() => {
          pinRow.style.animation = '';
          AppState.enteredPin = '';
          updatePinDisplay();
        }, 400);
      }
    }, 200);
  }
}

function bypassDemoUnlock() {
  AppState.enteredPin = '000000';
  updatePinDisplay();
}

// ------------------------------------------------ Login Tab Switching
function switchLoginTab(tab) {
  const isQr = tab === 'qr';
  document.getElementById('tab-btn-qr').classList.toggle('active', isQr);
  document.getElementById('tab-btn-phone').classList.toggle('active', !isQr);
  document.getElementById('login-qr-section').classList.toggle('hidden', !isQr);
  document.getElementById('login-phone-section').classList.toggle('hidden', isQr);
}

function requestPhoneCode() {
  const phone = document.getElementById('login-phone-input').value.trim();
  if (phone.length < 5) return alert('Please enter a valid phone number');
  document.getElementById('login-otp-step').classList.remove('hidden');
}

function simulateLoginSuccess(label) {
  const newAccount = {
    id: 'acc_' + (AppState.accounts.length + 1),
    name: label,
    phone: '+1 (555) 890 1204',
    username: '@user_' + AppState.accounts.length,
    initial: label[0]
  };
  AppState.accounts.push(newAccount);
  AppState.currentAccountIndex = AppState.accounts.length - 1;
  renderAccountRail();
  navigateTo('chat');
}

// ------------------------------------------------ Render Account Rail (Multi-Account)
function renderAccountRail() {
  const container = document.getElementById('rail-accounts-list');
  container.innerHTML = '';

  AppState.accounts.forEach((acc, i) => {
    const wrap = document.createElement('div');
    wrap.className = 'rail-avatar-wrap' + (i === AppState.currentAccountIndex ? ' active' : '');
    wrap.title = `${acc.name} (${acc.phone})`;
    wrap.onclick = () => switchAccount(i);

    const avatar = document.createElement('div');
    avatar.className = 'rail-avatar';
    avatar.textContent = acc.initial;

    wrap.appendChild(avatar);
    container.appendChild(wrap);
  });
}

function switchAccount(index) {
  AppState.currentAccountIndex = index;
  renderAccountRail();
}

// ------------------------------------------------ Render Chat List & Filters
function renderChatList(query = '') {
  const container = document.getElementById('chat-list-container');
  container.innerHTML = '';

  const filtered = AppState.chats.filter(c => {
    const matchesFolder = AppState.activeFolder === 'all' || c.folder === AppState.activeFolder;
    const matchesQuery = !query || c.name.toLowerCase().includes(query.toLowerCase()) || c.messages.some(m => m.text.toLowerCase().includes(query.toLowerCase()));
    return matchesFolder && matchesQuery;
  });

  filtered.forEach(chat => {
    const row = document.createElement('div');
    row.className = 'chat-row' + (chat.id === AppState.activeChatId ? ' active' : '');
    row.onclick = () => selectChat(chat.id);

    const lastMsg = chat.messages[chat.messages.length - 1];
    const previewText = lastMsg ? (lastMsg.isDeleted ? '🚫 [Recovered] ' + lastMsg.originalText : lastMsg.text) : 'No messages yet';

    row.innerHTML = `
      <div class="avatar">${chat.initial}</div>
      <div class="chat-meta">
        <div class="chat-title-row">
          <span class="chat-title">${chat.name}</span>
          <span class="chat-time">${chat.time}</span>
        </div>
        <div class="chat-snippet-row">
          <span class="chat-snippet">${previewText}</span>
          ${chat.unread > 0 ? `<span class="unread-badge">${chat.unread}</span>` : ''}
        </div>
      </div>
    `;

    container.appendChild(row);
  });
}

function filterFolder(btn, folder) {
  document.querySelectorAll('.folder-chip').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  AppState.activeFolder = folder;
  renderChatList();
}

function filterChatList(query) {
  renderChatList(query);
}

function selectChat(chatId) {
  AppState.activeChatId = chatId;
  const chat = AppState.chats.find(c => c.id === chatId);
  if (chat) chat.unread = 0; // Read locally
  renderChatList();
  renderActiveChat();
}

// ------------------------------------------------ Render Active Conversation
function renderActiveChat() {
  const chat = AppState.chats.find(c => c.id === AppState.activeChatId);
  if (!chat) return;

  // Header
  document.getElementById('topbar-avatar').textContent = chat.initial;
  document.getElementById('topbar-name').textContent = chat.name;
  document.getElementById('topbar-status').innerHTML = chat.isOnline
    ? '<span class="dot on"></span> Online'
    : '<span class="dot"></span> Last seen recently';

  // Info pane
  document.getElementById('info-avatar').textContent = chat.initial;
  document.getElementById('info-name').textContent = chat.name;
  document.getElementById('info-handle').textContent = chat.handle;
  document.getElementById('info-phone').textContent = chat.phone;
  document.getElementById('info-bio').textContent = chat.bio;

  // Messages
  const container = document.getElementById('messages-container');
  container.innerHTML = '<div class="date-badge">Today</div>';

  chat.messages.forEach(msg => {
    const row = document.createElement('div');
    row.className = `msg-row ${msg.isOutgoing ? 'outgoing' : 'incoming'}`;

    if (msg.isDeleted) {
      // Recovered deleted message
      row.innerHTML = `
        <div class="msg-bubble deleted-recovered">
          <div class="deleted-banner">⚠️ [Recovered by Foggygram]</div>
          <div style="text-decoration:line-through;opacity:0.6;font-size:12.5px;margin-bottom:4px">${msg.text}</div>
          <div style="font-weight:500">${msg.originalText}</div>
          <div class="msg-time-row">
            <span>${msg.time}</span>
            <span class="read-status">💾 Cached</span>
          </div>
        </div>
      `;
    } else {
      row.innerHTML = `
        <div class="msg-bubble">
          <div>${msg.text}</div>
          <div class="msg-time-row">
            <span>${msg.time}</span>
            ${msg.isOutgoing ? `<span class="read-status">${msg.isRead ? '✓✓' : '✓'}</span>` : ''}
          </div>
        </div>
      `;
    }

    container.appendChild(row);
  });

  container.scrollTop = container.scrollHeight;
}

// ------------------------------------------------ Messaging Logic
function sendMessage() {
  const input = document.getElementById('message-input');
  const text = input.value.trim();
  if (!text) return;

  const chat = AppState.chats.find(c => c.id === AppState.activeChatId);
  if (!chat) return;

  const now = new Date();
  const timeStr = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

  chat.messages.push({
    id: Date.now(),
    text: text,
    time: timeStr,
    isOutgoing: true,
    isRead: false
  });

  input.value = '';
  input.style.height = 'auto';
  renderActiveChat();
  renderChatList();

  // Simulate quick auto-reply in demo
  if (chat.id === 'chat_2') {
    // Foggy AI Chat
    setTimeout(() => {
      chat.messages.push({
        id: Date.now() + 1,
        text: `☁️ Foggy received: "${text}". I have analyzed the context and all settings remain optimal!`,
        time: timeStr,
        isOutgoing: false,
        isRead: false
      });
      renderActiveChat();
    }, 600);
  }
}

function handleMessageKey(e) {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault();
    sendMessage();
  }
}

function autoResizeTextarea(el) {
  el.style.height = 'auto';
  el.style.height = Math.min(el.scrollHeight, 120) + 'px';
}

// ------------------------------------------------ Ghost Protocol Toggle
function toggleGhostProtocol() {
  AppState.isGlobalGhostOn = !AppState.isGlobalGhostOn;
  const chip = document.getElementById('topbar-ghost-chip');
  chip.textContent = AppState.isGlobalGhostOn ? '👻 GHOST ON' : '⚪ GHOST OFF';
  chip.classList.toggle('active', AppState.isGlobalGhostOn);
}

function toggleChatGhost() {
  AppState.isChatGhostOn = !AppState.isChatGhostOn;
  document.getElementById('info-ghost-toggle').classList.toggle('on', AppState.isChatGhostOn);
}

function toggleGlobalGhost() {
  AppState.isGlobalGhostOn = !AppState.isGlobalGhostOn;
  document.getElementById('global-ghost-toggle').classList.toggle('on', AppState.isGlobalGhostOn);
  document.getElementById('topbar-ghost-chip').textContent = AppState.isGlobalGhostOn ? '👻 GHOST ON' : '⚪ GHOST OFF';
}

// ------------------------------------------------ Foggy AI Assistant Drawer
function toggleAiDrawer() {
  const drawer = document.getElementById('ai-drawer');
  drawer.classList.toggle('hidden');
}

function runAiCommand(command) {
  const box = document.getElementById('ai-response-box');
  const chat = AppState.chats.find(c => c.id === AppState.activeChatId);

  if (command === 'summarize') {
    box.textContent = `📊 Foggy Summary for ${chat ? chat.name : 'this chat'}:\n• Active discussion regarding Foggygram Web release.\n• Key achievement: Zero-accent monochrome glass styling verified.\n• Deleted messages are captured and kept in local cache.\n• No action items pending.`;
  } else if (command === 'reply') {
    const draft = `Thanks for testing! The glassmorphism and Session Vault look completely seamless.`;
    box.textContent = `✍️ Drafted Reply:\n"${draft}"\n\n(Click below or copy into composer)`;
    document.getElementById('message-input').value = draft;
  } else if (command === 'ghost') {
    toggleGhostProtocol();
    box.textContent = AppState.isGlobalGhostOn
      ? `🌫️ Ghost Protocol activated! Read receipts intercepted and dropped. Online presence hidden.`
      : `⚪ Ghost Protocol deactivated. Standard Telegram read receipts active.`;
  } else if (command === 'vault') {
    exportVaultPayload();
    box.textContent = `🔐 Session Vault payload encrypted with AES-256 and backed up! Zero OTPs needed on any device.`;
  } else if (command === 'recover') {
    box.textContent = `🔍 Recovered Messages Scan:\n• Message #6 from Alex Chen: "Secret prototype credentials: api_id 38612801" [Sender deleted at 2:46 PM]\n• Preserved permanently in local storage.`;
  }
}

function executeCustomAiPrompt() {
  const input = document.getElementById('ai-prompt-input');
  const text = input.value.trim();
  if (!text) return;
  input.value = '';

  const box = document.getElementById('ai-response-box');
  if (text.toLowerCase().includes('ghost')) {
    runAiCommand('ghost');
  } else if (text.toLowerCase().includes('vault') || text.toLowerCase().includes('backup')) {
    runAiCommand('vault');
  } else if (text.toLowerCase().includes('summar')) {
    runAiCommand('summarize');
  } else {
    box.textContent = `☁️ Foggy executed: "${text}"\n\nContext analyzed across ${AppState.accounts.length} linked accounts. All settings and caches verified.`;
  }
}

// ------------------------------------------------ Session Vault Export
function exportVaultPayload() {
  const payload = {
    version: '1.0',
    app: 'Foggygram Web',
    exportedAt: new Date().toISOString(),
    accounts: AppState.accounts.map(a => ({
      id: a.id,
      name: a.name,
      phone: a.phone,
      authKeyHash: 'mtproto_session_auth_key_' + a.id
    }))
  };

  const blob = new Blob([JSON.stringify(payload, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'foggygram_vault_backup.foggyvault';
  a.click();
  URL.revokeObjectURL(url);
}

// ------------------------------------------------ Modals & Info Pane
function toggleInfoPane() {
  document.getElementById('chat-info-pane').classList.toggle('hidden');
}

function toggleSettingsModal() {
  document.getElementById('settings-modal').classList.toggle('hidden');
}
