const express = require('express');
const app = express();
const PORT = 3001;
app.use(express.json());

const services = {
  "payments-api": {
    serviceId: "payments-api",
    name: "Payments API",
    ownerEmail: "payments-team@company.com",
    tier: "critical",
  },
  "accounts-api": {
    serviceId: "accounts-api",
    name: "Accounts API",
    ownerEmail: "accounts-team@company.com",
    tier: "critical",
  },
  "notifications-api": {
    serviceId: "notifications-api",
    name: "Notifications API",
    ownerEmail: "notifications-team@company.com",
    tier: "standard",
  },
  "auth-api": {
    serviceId: "auth-api",
    name: "Auth API",
    ownerEmail: "security-team@company.com",
    tier: "critical",
  },
  "reports-api": {
    serviceId: "reports-api",
    name: "Reports API",
    ownerEmail: "data-team@company.com",
    tier: "standard",
  },
};

function logEvent(type, payload) {
  console.log(JSON.stringify({ event: type, ts: new Date().toISOString(), ...payload }));
}

app.get('/services/:serviceId', (req, res) => {
  const { serviceId } = req.params;
  const service = services[serviceId];

  if (!service) {
    logEvent('service_catalog_snapshot', {
      serviceId,
      outcome: 'not_found',
    });
    return res.status(404).json({ error: 'Service not found', serviceId });
  }

  logEvent('service_catalog_snapshot', {
    serviceId,
    outcome: 'found',
    tier: service.tier,
  });

  return res.status(200).json({ serviceId, ...service });
});

app.get('/health', (_req, res) => res.json({ status: 'ok' }));

app.listen(PORT, () => {
  console.log(JSON.stringify({ event: 'server_started', port: PORT, ts: new Date().toISOString() }));
});
