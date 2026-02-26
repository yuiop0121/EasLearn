const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { google } = require("googleapis");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const pdf = require("pdf-parse");

admin.initializeApp();
const db = admin.firestore();

// Initialize Gemini
// Note: In production, use Cloud Secret Manager for the API key
const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY || "YOUR_API_KEY");
const model = genAI.getGenerativeModel({ model: "text-embedding-004" });

/**
 * Fetches a file from Google Drive, chunks it, generates embeddings, and stores in Firestore.
 */
exports.fetchAndProcessDriveFile = functions.https.onCall(async (data, context) => {
    const fileId = data.fileId || "1T3Kpr5VMMgNSX7jzpKHNSnbuxEh42H4v2pugR3-4Wmc";
    const textbookName = data.textbookName || "EduPulse Textbook";

    try {
        // 1. Fetch from Google Drive
        // This assumes the service account has access or a valid token is provided
        const auth = new google.auth.GoogleAuth({
            scopes: ["https://www.googleapis.com/auth/drive.readonly"],
        });
        const drive = google.drive({ version: "v3", auth });

        const response = await drive.files.get(
            { fileId: fileId, alt: "media" },
            { responseType: "arraybuffer" }
        );

        const buffer = Buffer.from(response.data);

        // 2. Extract text (assuming PDF for textbooks)
        const pdfData = await pdf(buffer);
        const text = pdfData.text;

        // 3. Chunk text (Simple overlap strategy)
        const chunks = chunkText(text, 1000, 200);
        console.log(`Processing ${chunks.length} chunks...`);

        // 4. Generate Embeddings and Save to Firestore
        const batch = db.batch();
        for (let i = 0; i < chunks.length; i++) {
            const chunk = chunks[i];

            // Generate embedding
            const result = await model.embedContent(chunk);
            const embedding = result.embedding.values;

            const docRef = db.collection("textbook_chunks").document();
            batch.set(docRef, {
                textbook_name: textbookName,
                text: chunk,
                chunk_index: i,
                embedding: admin.firestore.VectorValue.fromArray(embedding),
                created_at: admin.firestore.FieldValue.serverTimestamp(),
            });

            // Batch limit check
            if ((i + 1) % 400 === 0) {
                await batch.commit();
                console.log(`Committed batch ${Math.ceil((i + 1) / 400)}`);
            }
        }

        await batch.commit();
        return { success: true, message: `Processed ${chunks.length} chunks.` };

    } catch (error) {
        console.error("Error processing Drive file:", error);
        throw new functions.https.HttpsError("internal", error.message);
    }
});

/**
 * Performs vector search to find nearest textbook chunks.
 */
exports.searchSimilarTextbookChunks = functions.https.onCall(async (data, context) => {
    const queryVector = data.queryVector;
    const limit = data.limit || 5;

    if (!queryVector || !Array.isArray(queryVector)) {
        throw new functions.https.HttpsError("invalid-argument", "queryVector must be an array of doubles.");
    }

    try {
        const querySnapshot = await db.collection("textbook_chunks")
            .findNearest({
                vectorField: "embedding",
                queryVector: admin.firestore.VectorValue.fromArray(queryVector),
                limit: limit,
                distanceMeasure: "COSINE",
            })
            .get();

        const results = querySnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));

        return { success: true, results: results };

    } catch (error) {
        console.error("Error searching similar chunks:", error);
        throw new functions.https.HttpsError("internal", error.message);
    }
});

function chunkText(text, size, overlap) {
    const chunks = [];
    let start = 0;
    while (start < text.length) {
        let end = start + size;
        chunks.push(text.substring(start, end));
        start += size - overlap;
    }
    return chunks;
}
