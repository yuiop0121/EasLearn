import os
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import google.generativeai as genai
import PyPDF2
from uuid import uuid4

# Initialize Firebase
cred = credentials.Certificate('serviceAccountKey.json') # User needs to provide this
firebase_admin.initialize_app(cred)
db = firestore.client()

# Configure Gemini
GENAI_API_KEY = os.environ.get("GOOGLE_API_KEY") # User needs to set this env var
if GENAI_API_KEY:
    genai.configure(api_key=GENAI_API_KEY)
    model = genai.GenerativeModel('gemini-1.5-pro')

def chunk_text(text, chunk_size=1000, overlap=200):
    chunks = []
    start = 0
    while start < len(text):
        end = start + chunk_size
        chunks.append(text[start:end])
        start += (chunk_size - overlap)
    return chunks

def summarize_chunk(text):
    if not GENAI_API_KEY:
        return "Summary unavailable (No API Key)"
    try:
        response = model.generate_content(f"Summarize this text in one sentence: {text}")
        return response.text.strip()
    except Exception as e:
        print(f"Error summarizing: {e}")
        return "Summary failed"

def process_pdf(pdf_path, textbook_name):
    print(f"Processing {pdf_path}...")
    try:
        with open(pdf_path, 'rb') as file:
            reader = PyPDF2.PdfReader(file)
            full_text = ""
            for page in reader.pages:
                full_text += page.extract_text() + "\n"
            
            chunks = chunk_text(full_text)
            
            batch = db.batch()
            count = 0
            
            for i, chunk in enumerate(chunks):
                summary = summarize_chunk(chunk)
                doc_ref = db.collection('textbook_chunks').document()
                batch.set(doc_ref, {
                    'textbook_name': textbook_name,
                    'text': chunk,
                    'summary': summary,
                    'chunk_index': i,
                    'id': doc_ref.id
                })
                count += 1
                if count >= 400: # Firestore batch limit is 500
                    batch.commit()
                    batch = db.batch()
                    count = 0
                    print("Committed batch")
            
            if count > 0:
                batch.commit()
                print("Committed final batch")
                
            print("PDF processing complete.")
            
    except Exception as e:
        print(f"Error processing PDF: {e}")

if __name__ == "__main__":
    # Example usage:
    # process_pdf('path/to/textbook.pdf', 'KPM Science Form 4')
    print("PDF Processor ready. Configure serviceAccountKey.json and GOOGLE_API_KEY first.")
