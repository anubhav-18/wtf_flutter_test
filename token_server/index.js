require('dotenv').config();

const cors = require('cors');
const express = require('express');
const jwt = require('jsonwebtoken');

const app = express();
const port = Number(process.env.PORT || 4000);

app.use(cors());
app.use(express.json({ limit: '10mb' })); // allow image payloads

// ─── In-memory shared data store ─────────────────────────────────────────────

const store = {
  messages: {},
  callRequests: {},
  sessionLogs: {},
  users: {
    dk: {
      id: 'dk',
      role: 'member',
      name: 'DK',
      email: 'dk@wtf.local',
      avatarUrl: 'DK',
      assignedTrainerId: 'aarav',
    },
    aarav: {
      id: 'aarav',
      role: 'trainer',
      name: 'Aarav',
      email: 'aarav@wtf.local',
      avatarUrl: 'A',
    },
  },
};

// ─── Helpers ──────────────────────────────────────────────────────────────────

function requireEnv(name) {
  const value = process.env[name];
  if (!value) throw new Error(`${name} is required`);
  return value;
}

function mapRole(role) {
  return role === 'trainer' ? 'host' : 'guest';
}

function nowIso() {
  return new Date().toISOString();
}

// ─── Health ───────────────────────────────────────────────────────────────────

app.get('/health', (_req, res) => {
  res.json({ ok: true, messages: Object.keys(store.messages).length, users: Object.keys(store.users).length });
});

// ─── Users API ────────────────────────────────────────────────────────────────

// GET /users
app.get('/users', (_req, res) => {
  res.json(Object.values(store.users));
});

// PATCH /users/:id  → update name etc
app.patch('/users/:id', (req, res) => {
  const { id } = req.params;
  if (!store.users[id]) return res.status(404).json({ error: 'Not found' });
  Object.assign(store.users[id], req.body);
  res.json(store.users[id]);
});

// ─── 100ms Token ──────────────────────────────────────────────────────────────

app.get('/token', (req, res) => {
  try {
    const accessKey = requireEnv('HMS_ACCESS_KEY');
    const secret = requireEnv('HMS_SECRET');
    const roomId = requireEnv('HMS_ROOM_ID');
    const userId = String(req.query.userId || '').trim();
    const role = mapRole(String(req.query.role || 'member').trim());

    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }

    const now = Math.floor(Date.now() / 1000);
    const payload = {
      access_key: accessKey,
      room_id: roomId,
      user_id: userId,
      role,
      type: 'app',
      version: 2,
      iat: now,
      exp: now + 60 * 60,
      jti: `${userId}-${role}-${now}`,
    };

    const token = jwt.sign(payload, secret, { algorithm: 'HS256' });
    res.json({ token, roomId, role });
  } catch (error) {
    res.status(500).json({ error: 'Unable to create token', detail: error.message });
  }
});

// ─── Messages API ─────────────────────────────────────────────────────────────

// GET /messages?chatId=dk_aarav  → sorted by createdAt asc
app.get('/messages', (req, res) => {
  const { chatId } = req.query;
  let msgs = Object.values(store.messages);
  if (chatId) msgs = msgs.filter(m => m.chatId === chatId);
  msgs.sort((a, b) => new Date(a.createdAt) - new Date(b.createdAt));
  res.json(msgs);
});

// POST /messages  → body: { id, chatId, senderId, receiverId, text, isSystem?, imageData?, fileName? }
app.post('/messages', (req, res) => {
  const { id, chatId, senderId, receiverId, text, isSystem, imageData, fileName } = req.body;
  if (!id || !senderId) {
    return res.status(400).json({ error: 'id and senderId required' });
  }
  const msg = {
    id,
    chatId: chatId || 'dk_aarav',
    senderId,
    receiverId,
    text: text || '',
    createdAt: nowIso(),
    status: 'sent',
    isSystem: isSystem || false,
    imageData: imageData || null,
    fileName: fileName || null,
  };
  store.messages[id] = msg;
  console.log(`[CHAT] ${senderId}: ${(text || '[attachment]').substring(0, 40)}`);
  res.status(201).json(msg);
});

// PATCH /messages/mark-read?receiverId=dk  → mark all received as read
app.patch('/messages/mark-read', (req, res) => {
  const { receiverId } = req.query;
  let count = 0;
  for (const msg of Object.values(store.messages)) {
    if (msg.receiverId === receiverId && msg.status !== 'read') {
      msg.status = 'read';
      count++;
    }
  }
  res.json({ marked: count });
});

// ─── Call Requests API ────────────────────────────────────────────────────────

// GET /call-requests
app.get('/call-requests', (_req, res) => {
  const list = Object.values(store.callRequests);
  list.sort((a, b) => new Date(b.scheduledFor) - new Date(a.scheduledFor));
  res.json(list);
});

// POST /call-requests  → body: CallRequest object
app.post('/call-requests', (req, res) => {
  const body = req.body;
  if (!body.id || !body.scheduledFor) {
    return res.status(400).json({ error: 'id and scheduledFor required' });
  }
  // Conflict check: any approved within 60 min?
  const proposed = new Date(body.scheduledFor);
  const conflict = Object.values(store.callRequests).find(r => {
    if (r.status !== 'approved') return false;
    return Math.abs(new Date(r.scheduledFor) - proposed) < 60 * 60 * 1000;
  });
  if (conflict) {
    return res.status(409).json({ error: 'Slot already approved — pick a different time.' });
  }
  store.callRequests[body.id] = { ...body, status: 'pending' };
  console.log(`[SCHEDULE] Request created ${body.id}`);
  res.status(201).json(store.callRequests[body.id]);
});

// PATCH /call-requests/:id  → body: { status, declineReason? }
app.patch('/call-requests/:id', (req, res) => {
  const { id } = req.params;
  const existing = store.callRequests[id];
  if (!existing) return res.status(404).json({ error: 'Not found' });

  const { status, declineReason } = req.body;

  if (status === 'approved') {
    // Re-check conflict (excluding self)
    const conflict = Object.values(store.callRequests).find(r => {
      if (r.id === id || r.status !== 'approved') return false;
      return Math.abs(new Date(r.scheduledFor) - new Date(existing.scheduledFor)) < 60 * 60 * 1000;
    });
    if (conflict) {
      return res.status(409).json({ error: 'Slot already approved — conflict detected.' });
    }
    existing.status = 'approved';
    // Auto-send system message: approval notice
    const approvalMsgId = `sys-approve-${id}`;
    const dt = new Date(existing.scheduledFor).toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' });
    store.messages[approvalMsgId] = {
      id: approvalMsgId,
      chatId: 'dk_aarav',
      senderId: 'aarav',
      receiverId: 'dk',
      text: `Call approved for ${dt}.`,
      createdAt: nowIso(),
      status: 'sent',
      isSystem: true,
    };
    console.log(`[SCHEDULE] Approved ${id}`);
  } else if (status === 'declined') {
    existing.status = 'declined';
    existing.declineReason = declineReason || '';
    const declineMsgId = `sys-decline-${id}`;
    store.messages[declineMsgId] = {
      id: declineMsgId,
      chatId: 'dk_aarav',
      senderId: 'aarav',
      receiverId: 'dk',
      text: `Call request declined. Reason: ${existing.declineReason}.`,
      createdAt: nowIso(),
      status: 'sent',
      isSystem: true,
    };
    console.log(`[SCHEDULE] Declined ${id}`);
  } else if (status === 'completed') {
    existing.status = 'completed';
    console.log(`[SCHEDULE] Completed ${id}`);
  }

  res.json(existing);
});

// ─── Session Logs API ─────────────────────────────────────────────────────────

// GET /session-logs
app.get('/session-logs', (_req, res) => {
  const list = Object.values(store.sessionLogs);
  list.sort((a, b) => new Date(b.startedAt) - new Date(a.startedAt));
  res.json(list);
});

// POST /session-logs
app.post('/session-logs', (req, res) => {
  const body = req.body;
  if (!body.id) return res.status(400).json({ error: 'id required' });
  store.sessionLogs[body.id] = body;
  console.log(`[LOG] Session created ${body.id} duration=${body.durationSec}s`);
  res.status(201).json(body);
});

// PATCH /session-logs/:id  → body: { rating?, memberNotes?, trainerNotes? }
app.patch('/session-logs/:id', (req, res) => {
  const { id } = req.params;
  const existing = store.sessionLogs[id];
  if (!existing) return res.status(404).json({ error: 'Not found' });
  Object.assign(existing, req.body);
  res.json(existing);
});

// ─── Start ────────────────────────────────────────────────────────────────────

app.listen(port, () => {
  console.log(`✅ WTF backend + 100ms token server on http://localhost:${port}`);
  console.log(`   /health  /token  /users  /messages  /call-requests  /session-logs`);
});
