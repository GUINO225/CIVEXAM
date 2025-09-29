# Migration arcadeLevel / badge

Ce dépôt stocke désormais le niveau arcade de l’utilisateur dans les champs `arcadeLevel` et `badge` des documents Firestore (`users` et `competition_scores`). Pour rétro-initialiser les données existantes, vous pouvez utiliser le script Node.js ci-dessous avec le SDK `firebase-admin`.

```bash
npm install firebase-admin
```

Créez ensuite un fichier `migrate-arcade-level.js` :

```js
const admin = require('firebase-admin');
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

const DEFAULT_LEVEL = 'Niveau 1';

async function run() {
  const db = admin.firestore();

  // 1) Mise à jour des profils utilisateurs.
  const usersSnap = await db.collection('users').get();
  for (const doc of usersSnap.docs) {
    const data = doc.data();
    const current = (data.arcadeLevel || data.badge || '').toString().trim();
    if (!current) {
      await doc.ref.set({ arcadeLevel: DEFAULT_LEVEL, badge: DEFAULT_LEVEL }, { merge: true });
    }
  }

  // 2) Mise à jour des entrées du classement.
  const scoresSnap = await db.collection('competition_scores').get();
  for (const doc of scoresSnap.docs) {
    const data = doc.data();
    const current = (data.arcadeLevel || data.badge || '').toString().trim();
    if (!current) {
      await doc.ref.set({ arcadeLevel: DEFAULT_LEVEL, badge: DEFAULT_LEVEL }, { merge: true });
    }
  }

  console.log('Migration terminée.');
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
```

Exécutez enfin :

```bash
node migrate-arcade-level.js
```

> Astuce : si vous préférez utiliser la console Firebase, vous pouvez également créer une règle Cloud Firestore temporaire qui définit `arcadeLevel` via un déclencheur Cloud Functions lors de la première écriture, mais le script ci-dessus permet de migrer l’historique en une seule fois.
