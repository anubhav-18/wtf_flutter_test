# 100ms Token Server

Local Express token server for the assessment.

## Setup

```bash
npm install
copy .env.example .env
npm start
```

Fill `.env` with 100ms credentials:

```text
HMS_ACCESS_KEY=
HMS_SECRET=
HMS_ROOM_ID=
PORT=4000
```

## Endpoint

```text
GET http://localhost:4000/token?userId=dk&role=member
GET http://localhost:4000/token?userId=aarav&role=trainer
```

## Notes

- Do not commit `.env`.
- The Flutter apps should call the emulator host address `http://10.0.2.2:4000`.
- Role mapping is `member` and `trainer`.
