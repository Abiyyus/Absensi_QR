// Mengisi Firebase: 2 dosen, 10 mahasiswa, 2 mata kuliah.
// Aman dijalankan berulang kali (data yang sama akan diperbarui, bukan dobel).
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const auth = admin.auth();
const db = admin.firestore();

const PASSWORD = '123456';

const DOSEN = [
  { id: '1980001', nama: 'Dr. Budi Santoso' },
  { id: '1980002', nama: 'Dr. Rina Wulandari' },
];

const MAHASISWA = [
  { id: '2021001', nama: 'Andi Pratama' },
  { id: '2021002', nama: 'Sari Lestari' },
  { id: '2021003', nama: 'Budi Hartono' },
  { id: '2021004', nama: 'Dewi Anggraini' },
  { id: '2021005', nama: 'Eko Prasetyo' },
  { id: '2021006', nama: 'Fitri Handayani' },
  { id: '2021007', nama: 'Gilang Ramadhan' },
  { id: '2021008', nama: 'Hana Permata' },
  { id: '2021009', nama: 'Indra Wijaya' },
  { id: '2021010', nama: 'Julia Putri' },
];

async function buatAkun(nimNidn, nama, role) {
  const email = `${nimNidn}@absensi.app`;
  let user;
  try {
    user = await auth.getUserByEmail(email);
    await auth.updateUser(user.uid, { password: PASSWORD, displayName: nama });
  } catch (e) {
    if (e.code === 'auth/user-not-found') {
      user = await auth.createUser({ email, password: PASSWORD, displayName: nama });
    } else {
      throw e;
    }
  }
  await db.collection('users').doc(user.uid).set({ nama, nim_nidn: nimNidn, role });
  console.log(`  ${role.padEnd(9)} ${nimNidn}  ${nama}`);
  return user.uid;
}

async function main() {
  console.log('Membuat akun dosen & mahasiswa...');
  const uidDosen = [];
  for (const d of DOSEN) uidDosen.push(await buatAkun(d.id, d.nama, 'dosen'));
  const uidMhs = [];
  for (const m of MAHASISWA) uidMhs.push(await buatAkun(m.id, m.nama, 'mahasiswa'));

  console.log('Membuat mata kuliah...');
  await db.collection('matkul').doc('pemrograman-mobile').set({
    nama: 'Pemrograman Mobile',
    dosenId: uidDosen[0],
    mahasiswaIds: uidMhs, // semua 10 mahasiswa
  });
  await db.collection('matkul').doc('basis-data').set({
    nama: 'Basis Data',
    dosenId: uidDosen[1],
    mahasiswaIds: uidMhs.slice(0, 6), // 6 mahasiswa pertama
  });
  console.log('  Pemrograman Mobile -> Dr. Budi Santoso (10 mahasiswa)');
  console.log('  Basis Data         -> Dr. Rina Wulandari (6 mahasiswa)');

  console.log('\nSelesai. Password semua akun: ' + PASSWORD);
}

main().catch((e) => {
  console.error('GAGAL:', e.message);
  process.exit(1);
});
