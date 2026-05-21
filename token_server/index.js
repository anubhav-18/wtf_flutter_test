require('dotenv').config();

const cors = require('cors');
const express = require('express');
const jwt = require('jsonwebtoken');

const app = express();
const port = Number(process.env.PORT || 4000);

app.use(cors());

function requireEnv(name) {
  const value = process.env[name];
  if (!value) {
    throw new Error(`${name} is required`);
  }
  return value;
}

function mapRole(role) {
  if (role === 'trainer') {
    return 'trainer';
  }
  return 'member';
}

app.get('/health', (_request, response) => {
  response.json({ ok: true });
});

app.get('/token', (request, response) => {
  try {
    const accessKey = requireEnv('HMS_ACCESS_KEY');
    const secret = requireEnv('HMS_SECRET');
    const roomId = requireEnv('HMS_ROOM_ID');
    const userId = String(request.query.userId || '').trim();
    const role = mapRole(String(request.query.role || 'member').trim());

    if (!userId) {
      response.status(400).json({ error: 'userId is required' });
      return;
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

    const token = jwt.sign(payload, secret, {
      algorithm: 'HS256',
    });

    response.json({ token, roomId, role });
  } catch (error) {
    response.status(500).json({
      error: 'Unable to create token',
      detail: error.message,
    });
  }
});

app.listen(port, () => {
  console.log(`100ms token server listening on http://localhost:${port}`);
});
