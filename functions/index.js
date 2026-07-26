const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

admin.initializeApp();
const db = admin.firestore();

// Define secret for Anthropic API Key managed via Firebase Secret Manager
const anthropicApiKey = defineSecret("ANTHROPIC_API_KEY");

/**
 * Cloud Function HTTPS Endpoint: chatProxy
 * Proxies user questions to Claude API with real-time Firestore context.
 */
exports.chatProxy = onRequest(
  { secrets: [anthropicApiKey], cors: true },
  async (req, res) => {
    // Handle CORS preflight
    if (req.method === "OPTIONS") {
      res.set("Access-Control-Allow-Origin", "*");
      res.set("Access-Control-Allow-Methods", "POST");
      res.set("Access-Control-Allow-Headers", "Content-Type");
      res.status(204).send("");
      return;
    }

    if (req.method !== "POST") {
      res.status(405).json({ error: "Method Not Allowed" });
      return;
    }

    try {
      const { message, userId } = req.body || {};
      if (!message || message.trim() === "") {
        res.status(400).json({ error: "Message content cannot be empty." });
        return;
      }

      // 1. Fetch live Court & Booking context from Firestore
      const courtsSnap = await db.collection("courts").get();
      const courtsData = courtsSnap.docs.map((doc) => ({
        id: doc.id,
        name: doc.data().nama || doc.data().name,
        pricePerHour: doc.data().harga_per_jam || doc.data().pricePerHour,
        openTime: doc.data().jam_buka || "07:00",
        closeTime: doc.data().jam_tutup || "23:00",
        isActive: doc.data().is_active ?? true,
      }));

      // Fetch today's active bookings
      const today = new Date();
      const formattedToday = today.toISOString().split("T")[0];

      const bookingsSnap = await db
        .collection("bookings")
        .where("status", "in", ["pending", "confirmed", "completed", "blocked"])
        .get();

      const activeBookings = bookingsSnap.docs.map((doc) => ({
        courtName: doc.data().courtName || doc.data().nama_lapangan,
        date: doc.data().tanggal,
        startTime: doc.data().jam_mulai,
        endTime: doc.data().jam_selesai,
        status: doc.data().status,
      }));

      // 2. Build System Prompt with Scope Boundary & Real-Time Context
      const systemPrompt = `
Anda adalah Padel AI Assistant 🤖, asisten pelanggan resmi untuk aplikasi Padel Booking.
Tugas Anda adalah membantu pengguna dengan sopan, ramah, dan profesional mengenai:
1. Ketersediaan slot & pemesanan lapangan padel.
2. Harga sewa & jam operasional lapangan.
3. Aturan dasar permainan padel & rekomendasi raket.
4. Metode pembayaran (Midtrans Snap: QRIS & Virtual Account) serta syarat pembatalan (H-1 / 24 jam).

DATA LAPANGAN REAL-TIME SAAT INI:
${JSON.stringify(courtsData, null, 2)}

SUMMARY BOOKING TERISI SAAT INI:
${JSON.stringify(activeBookings.slice(0, 15), null, 2)}

BATASAN SCOPE SANGAT PENTING:
Jika pengguna menanyakan hal di LUAR topik booking lapangan, padel, pembayaran, atau jam operasional (misalnya pertanyaan seputar resep masakan, pemrograman, politik, cuaca umum), TOLAK DENGAN SOPAN dan arahkan pengguna untuk menghubungi Customer Service Admin kami secara langsung via WhatsApp: 0812-3456-7890.
Gunakan Bahasa Indonesia yang ramah, jelas, dan komunikatif dengan emoji yang relevan.
`;

      // 3. Secure Call to Anthropic Claude API
      const apiKey = process.env.ANTHROPIC_API_KEY || anthropicApiKey.value();

      if (!apiKey) {
        res.status(500).json({
          error: "ANTHROPIC_API_KEY is not configured in Firebase Secret Manager.",
        });
        return;
      }

      const response = await fetch("https://api.anthropic.com/v1/messages", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "anthropic-version": "2023-06-01",
        },
        body: JSON.stringify({
          model: "claude-3-5-sonnet-20241022",
          max_tokens: 600,
          system: systemPrompt,
          messages: [
            {
              role: "user",
              content: message,
            },
          ],
        }),
      });

      if (!response.ok) {
        const errText = await response.text();
        console.error("Anthropic API Error:", errText);
        res.status(502).json({ error: "Failed to communicate with Claude API proxy." });
        return;
      }

      const data = await response.json();
      const replyText = data.content?.[0]?.text || "Maaf, tidak ada respons yang dihasilkan.";

      res.status(200).json({
        reply: replyText,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      console.error("ChatProxy Exception:", error);
      res.status(500).json({ error: error.message || "Internal Server Error" });
    }
  }
);
