// sqflite web worker
// This file is required for sqflite_common_ffi_web to work properly

importScripts("https://cdn.jsdelivr.net/npm/sql.js@1.6.2/dist/sql-wasm.js");

let db;
let SQL;

self.addEventListener('message', async function(e) {
  const { id, method, params } = e.data;
  
  try {
    if (method === 'init') {
      // Initialize SQL.js
      SQL = await initSqlJs({
        locateFile: file => `https://cdn.jsdelivr.net/npm/sql.js@1.6.2/dist/${file}`
      });
      self.postMessage({ id, result: 'initialized' });
    } else if (method === 'open') {
      db = new SQL.Database();
      self.postMessage({ id, result: 'opened' });
    } else if (method === 'execute') {
      const result = db.exec(params.sql);
      self.postMessage({ id, result });
    } else if (method === 'close') {
      if (db) {
        db.close();
        db = null;
      }
      self.postMessage({ id, result: 'closed' });
    }
  } catch (error) {
    self.postMessage({ id, error: error.message });
  }
});
