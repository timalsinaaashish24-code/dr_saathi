const express = require('express');
const { query: dbQuery } = require('../config/database');
const logger = require('../config/logger');

const router = express.Router();

// POST /api/v1/sync/pull — pull latest data since last sync
router.post('/pull', async (req, res) => {
  try {
    const { last_sync_at, tables } = req.body;
    const since = last_sync_at || '1970-01-01T00:00:00Z';
    const data = {};

    const tablesToSync = tables || ['appointments', 'prescriptions', 'patients', 'doctors'];

    for (const table of tablesToSync) {
      let result;
      if (table === 'appointments') {
        if (req.user.role === 'doctor') {
          const dr = await dbQuery('SELECT id FROM doctors WHERE user_id = $1', [req.user.id]);
          result = await dbQuery('SELECT * FROM appointments WHERE doctor_id = $1 AND updated_at > $2 ORDER BY updated_at DESC LIMIT 500', [dr.rows[0]?.id, since]);
        } else if (req.user.role === 'patient') {
          const pt = await dbQuery('SELECT id FROM patients WHERE user_id = $1', [req.user.id]);
          result = await dbQuery('SELECT * FROM appointments WHERE patient_id = $1 AND updated_at > $2 ORDER BY updated_at DESC LIMIT 500', [pt.rows[0]?.id, since]);
        } else {
          result = await dbQuery('SELECT * FROM appointments WHERE updated_at > $1 ORDER BY updated_at DESC LIMIT 500', [since]);
        }
      } else if (table === 'doctors') {
        result = await dbQuery('SELECT * FROM doctors WHERE updated_at > $1 AND is_active = true ORDER BY updated_at DESC LIMIT 500', [since]);
      } else if (table === 'patients' && req.user.role === 'admin') {
        result = await dbQuery('SELECT * FROM patients WHERE updated_at > $1 ORDER BY updated_at DESC LIMIT 500', [since]);
      } else if (table === 'prescriptions') {
        if (req.user.role === 'doctor') {
          const dr = await dbQuery('SELECT id FROM doctors WHERE user_id = $1', [req.user.id]);
          result = await dbQuery('SELECT * FROM prescriptions WHERE doctor_id = $1 AND updated_at > $2 ORDER BY updated_at DESC LIMIT 500', [dr.rows[0]?.id, since]);
        } else {
          result = await dbQuery('SELECT * FROM prescriptions WHERE updated_at > $1 ORDER BY updated_at DESC LIMIT 500', [since]);
        }
      }
      if (result) data[table] = result.rows;
    }

    res.json({ data, synced_at: new Date().toISOString() });
  } catch (error) { logger.error('Sync pull error:', error); res.status(500).json({ error: 'Sync failed' }); }
});

// POST /api/v1/sync/push — push local changes to server
router.post('/push', async (req, res) => {
  try {
    const { changes } = req.body;
    const results = { created: 0, updated: 0, errors: [] };

    // Process each change
    for (const change of (changes || [])) {
      try {
        if (change.operation === 'create') {
          await dbQuery(`INSERT INTO ${change.table} (${Object.keys(change.data).join(',')}) VALUES (${Object.keys(change.data).map((_, i) => `$${i + 1}`).join(',')})`, Object.values(change.data));
          results.created++;
        } else if (change.operation === 'update') {
          const setClauses = Object.keys(change.data).filter(k => k !== 'id').map((k, i) => `${k} = $${i + 2}`).join(', ');
          await dbQuery(`UPDATE ${change.table} SET ${setClauses} WHERE id = $1`, [change.data.id, ...Object.values(change.data).filter((_, i) => Object.keys(change.data)[i] !== 'id')]);
          results.updated++;
        }
      } catch (e) { results.errors.push({ change, error: e.message }); }
    }

    res.json({ message: 'Sync complete', results, synced_at: new Date().toISOString() });
  } catch (error) { logger.error('Sync push error:', error); res.status(500).json({ error: 'Sync failed' }); }
});

module.exports = router;
