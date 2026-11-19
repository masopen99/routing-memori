# routing-memori

Memori Claude Code yang **cepat, pintar, dan bisa dilihat di Obsidian**, dipasang dengan satu baris perintah.

```bash
curl -fsSL https://raw.githubusercontent.com/masopen99/routing-memori/main/install.sh | bash
```

Kalau bermanfaat, kasih ⭐ di repo ini.

## Masalahnya

Banyak orang memasang beberapa tool memori dan pencarian kode sekaligus untuk Claude Code, misalnya Obsidian, OpenViking, graphify, code-review-graph, serena, dan codebase-memory-mcp. Akibatnya:

- Memori tersimpan di beberapa tempat, lalu isinya saling beda.
- Claude menjalankan dua atau tiga tool untuk satu pertanyaan, jadi lambat dan boros token.
- Aturan di `CLAUDE.md` saling bertentangan ("pakai A dulu" vs "WAJIB pakai B dulu").

## Solusinya

1. **Satu sumber kebenaran.** Memori tetap berupa file Markdown di folder bawaan Claude Code (`~/.claude/projects/<slug>/memory/`).
2. **Obsidian hanya jendela.** Vault Obsidian berisi symlink ke folder itu. Tidak ada salinan, tidak ada sinkronisasi, tidak ada proses di latar belakang.
3. **Routing.** Satu tabel di `CLAUDE.md` menentukan satu tool untuk satu jenis pertanyaan, jadi tool tidak saling tabrakan.

## Apa yang dilakukan installer

- **Linux:** mengunduh AppImage resmi Obsidian versi terbaru (x86_64 atau arm64), mengekstraknya ke `~/Applications/obsidian` (tidak butuh `libfuse2`), lalu membuat launcher `~/bin/obsidian` dan entri menu aplikasi.
- **macOS:** memakai Obsidian yang sudah terpasang, atau memasangnya lewat `brew install --cask obsidian`.
- Membuat vault `~/Documents/Obsidian/Claude-Memory` dengan folder `memory/` yang terhubung ke memori Claude.
- Aman dijalankan berulang kali. Kalau Obsidian sudah terpasang, installer tidak mengunduh ulang.

Installer tidak mengubah `CLAUDE.md` milikmu. Bagian routing kamu salin sendiri (lihat di bawah).

## Pasang routing di CLAUDE.md

Salin isi [`templates/CLAUDE.md`](templates/CLAUDE.md) ke `CLAUDE.md` milikmu. Hapus baris tool yang tidak kamu pakai.

| Kebutuhan | Tool |
| --- | --- |
| Mengingat fakta antar sesi | File memori Claude |
| Mengingat topik yang sudah jelas | `MEMORY.md`, lalu satu file memori |
| Mencari yang samar di banyak catatan | Indeks semantik vault (misalnya OpenViking) |
| Relasi kode: pemanggil, alur, arsitektur | Graph kode (misalnya `codebase-memory-mcp`) |
| Edit atau rename simbol | `serena` |
| Review diff atau PR | `code-review-graph` |
| Teks persis: string, nama env, log | Grep |

Aturan supaya memori tetap pintar:

- Satu file memori berisi satu fakta, dihubungkan dengan `[[nama-memori]]`.
- `MEMORY.md` pendek saja: satu baris per memori.
- Perbarui atau hapus memori yang sudah basi. Jangan menambah duplikat.

Contoh format ada di [`templates/memory/`](templates/memory/).

## Pengaturan

Semua opsional, lewat variabel lingkungan:

| Variabel | Bawaan |
| --- | --- |
| `VAULT` | `~/Documents/Obsidian/Claude-Memory` |
| `APP_DIR` | `~/Applications/obsidian` (Linux) |
| `BIN_DIR` | `~/bin` |
| `CLAUDE_PROJECT_SLUG` | path home dengan semua karakter non-alfanumerik diganti `-` (misalnya `-home-budi`) |
| `MEMORY_DIR` | `~/.claude/projects/$CLAUDE_PROJECT_SLUG/memory` |

Contoh untuk memori proyek lain:

```bash
curl -fsSL https://raw.githubusercontent.com/masopen99/routing-memori/main/install.sh \
  | CLAUDE_PROJECT_SLUG=-home-budi-proyek-toko VAULT=~/Documents/Obsidian/Toko bash
```

Windows: pasang Obsidian biasa, lalu buat link folder memori ke dalam vault dengan `mklink /D`.

## Catatan keamanan

- Di Linux, launcher menjalankan Obsidian dengan `--no-sandbox`, karena AppImage yang diekstrak tidak bisa memakai sandbox setuid. Buka hanya vault dan plugin yang kamu percaya.
- Jangan commit atau bagikan folder memori aslimu. Isinya bisa memuat data pribadi.
- Mau baca dulu sebelum menjalankan? Unduh script-nya: `curl -fsSL https://raw.githubusercontent.com/masopen99/routing-memori/main/install.sh -o install.sh`, baca, lalu jalankan `bash install.sh`.

## Lisensi

MIT
