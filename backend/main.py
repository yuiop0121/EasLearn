from fastapi import FastAPI, HTTPException, BackgroundTasks, Request
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import firebase_admin
from firebase_admin import credentials, firestore
import google.generativeai as genai
import os
import requests
from pypdf import PdfReader
from io import BytesIO
from .models import *
from typing import List, Dict
import logging
from dotenv import load_dotenv
import re
import json

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv()
logger.info(f"DEBUG: CWD is {os.getcwd()}")
key_status = bool(os.environ.get('GOOGLE_API_KEY'))
logger.info(f"DEBUG: GOOGLE_API_KEY present in env: {key_status}")

def convert_gdrive_url(url: str) -> str:
    """Converts a Google Drive view/open URL to a direct download URL."""
    file_id_match = re.search(r'/d/([a-zA-Z0-9_-]+)', url)
    if file_id_match:
        file_id = file_id_match.group(1)
        return f'https://drive.google.com/uc?export=download&id={file_id}'
    return url

app = FastAPI(title="CikguAI Backend")

# 1. Environment & Setup
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
STATIC_DIR = os.path.join(BASE_DIR, "static")
os.makedirs(STATIC_DIR, exist_ok=True)

SERVICE_ACCOUNT_KEY = os.path.join(BASE_DIR, "serviceAccountKey.json")
# Multi-Textbook Configuration
TEXTBOOKS = {} # {textbook_id: {page_num: text}}
CHAPTER_MAPS = {} # {textbook_id: {"Bab 1": 1, ...}}

# Backend Shadow Data (Used when Firestore is unreachable)
TEXTBOOK_METADATA = {
    "sejarah_f4": {
        "title": "Sejarah Tingkatan 4",
        "level": "Form 4",
        "subject": "Sejarah",
        "pdf_url": "https://drive.google.com/file/d/1X5XzqS_Lz79G4hL0pSg2Yl6VfR6X9j9K/view" 
    },
    "physics_f5": {
        "title": "Physics Form 5",
        "level": "Form 5",
        "subject": "Physics",
        "pdf_url": "https://drive.google.com/file/d/1IPqXd1p3RxzGkSVVLfKKaYZKHxQkqzK/view"
    }
}
db = None
model = None 

# Track if database is actually usable
DB_AVAILABLE = False

# ...

from fastapi.staticfiles import StaticFiles

# Mount static files to serve the PDF
app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")

# 2. Core Functions Implementation
# A. Startup & RAG Initialization
import asyncio

PDF_LOADING_STATUS = "pending"

import gc

async def load_pdf_background():
    global TEXTBOOKS, PDF_LOADING_STATUS, CHAPTER_MAPS, TEXTBOOK_METADATA
    if not DB_AVAILABLE:
        logger.info("Skipping background sync: Database currently restricted/quota exceeded.")
        PDF_LOADING_STATUS = "quota_restricted"
        return

    PDF_LOADING_STATUS = "loading"

        # Load all textbooks from "textbooks" collection
        logger.info("Syncing all textbooks from Firestore...")
        textbooks_ref = db.collection("textbooks")
        docs = textbooks_ref.stream()
        
        found_any = False
        for doc in docs:
            found_any = True
            textbook_id = doc.id
            data = doc.to_dict()
            
            TEXTBOOK_METADATA[textbook_id] = {
                "title": data.get("title", "Untitled"),
                "level": data.get("level", "Unknown"),
                "subject": data.get("subject", "Unknown"),
                "pdf_url": data.get("pdf_drive_link")
            }
            
            pages_ref = doc.reference.collection("pages")
            existing_pages = pages_ref.limit(500).get()
            
            if len(existing_pages) > 0:
                logger.info(f"Loading {len(existing_pages)} pages for {textbook_id} from cache...")
                content = {}
                for p_doc in existing_pages:
                    content[int(p_doc.id)] = p_doc.to_dict().get("text", "")
                
                TEXTBOOKS[textbook_id] = content
                CHAPTER_MAPS[textbook_id] = data.get("chapters_map", {})
                
                # Ensure local PDF for static viewer (using ID in filename)
                local_path = os.path.join(STATIC_DIR, f"{textbook_id}.pdf")
                if not os.path.exists(local_path):
                    pdf_url = data.get("pdf_drive_link")
                    if pdf_url:
                        logger.info(f"Restoring PDF file for {textbook_id}...")
                        download_url = convert_gdrive_url(pdf_url)
                        try:
                            # Added timeout to avoid hanging the task
                            with requests.get(download_url, stream=True, timeout=30) as r:
                                 r.raise_for_status()
                                 with open(local_path, "wb") as f:
                                     for chunk in r.iter_content(chunk_size=8192):
                                         f.write(chunk)
                        except Exception as e:
                            logger.error(f"Failed to restore PDF for {textbook_id}: {e}")
            else:
                # NEW BOOK: Download and Extract
                pdf_url = data.get("pdf_drive_link")
                if pdf_url:
                    logger.info(f"New textbook detected: {textbook_id}. Starting extraction...")
                    local_path = os.path.join(STATIC_DIR, f"{textbook_id}.pdf")
                    download_url = convert_gdrive_url(pdf_url)
                    
                    try:
                        # 1. Download
                        with requests.get(download_url, stream=True, timeout=60) as r:
                            r.raise_for_status()
                            with open(local_path, "wb") as f:
                                for chunk in r.iter_content(chunk_size=8192):
                                    f.write(chunk)
                        
                        # 2. Extract
                        reader = PdfReader(local_path)
                        batch = db.batch()
                        content = {}
                        ch_map = {}
                        count = 0
                        
                        for i, page in enumerate(reader.pages):
                            text = page.extract_text()
                            if text:
                                pg_num = i + 1
                                content[pg_num] = text
                                ch_match = re.search(r'(?i)Bab\s+([1-9]|10)\b', text[:500])
                                if ch_match:
                                    ch_name = f"Bab {ch_match.group(1)}"
                                    if ch_name not in ch_map:
                                        ch_map[ch_name] = pg_num
                                
                                batch.set(pages_ref.document(str(pg_num)), {"text": text})
                                count += 1
                                if count % 50 == 0:
                                    batch.commit()
                                    batch = db.batch()
                        
                        batch.commit()
                        doc.reference.update({"chapters_map": ch_map})
                        
                        TEXTBOOKS[textbook_id] = content
                        CHAPTER_MAPS[textbook_id] = ch_map
                        logger.info(f"Extraction complete for {textbook_id}: {count} pages.")
                    except Exception as e:
                        logger.error(f"Failed to extract {textbook_id}: {e}")

        if not found_any:
            # Migration/Bootstrap: If "textbooks" is empty, move "textbook_v1" into it
            logger.info("No textbooks found in new collection. Bootstrapping from legacy...")
            legacy_ref = db.collection("content").document("textbook_v1")
            legacy_data = legacy_ref.get()
            if legacy_data.exists:
                # Move to textbooks/sejarah_f4
                db.collection("textbooks").document("sejarah_f4").set({
                    "title": "Sejarah Tingkatan 4",
                    "level": "Form 4",
                    "subject": "Sejarah",
                    **legacy_data.to_dict()
                })
                # Re-run after bootstrap
                return await load_pdf_background()

        PDF_LOADING_STATUS = "completed"
        logger.info(f"Multi-Textbook Sync Complete. Loaded {len(TEXTBOOKS)} books.")
        return
    except Exception as e:
        logger.error(f"Background PDF Sync Failed: {e}")
        PDF_LOADING_STATUS = f"failed_error: {str(e)}"


@app.on_event("startup")
async def startup_event():
    global db, model, TEXTBOOK_CONTENT, DB_AVAILABLE
    
    # Init Firebase
    try:
        if not firebase_admin._apps:
            firebase_creds = os.environ.get("FIREBASE_CREDENTIALS")
            if firebase_creds:
                cred_dict = json.loads(firebase_creds)
                cred = credentials.Certificate(cred_dict)
                firebase_admin.initialize_app(cred)
                logger.info("Firebase Initialized with Environment Variable Credentials")
            elif os.path.exists(SERVICE_ACCOUNT_KEY):
                cred = credentials.Certificate(SERVICE_ACCOUNT_KEY)
                firebase_admin.initialize_app(cred)
                logger.info("Firebase Initialized with File Credentials")
            else:
                logger.warning("serviceAccountKey.json not found and FIREBASE_CREDENTIALS not set. Using default creds (Application Default Credentials).")
                firebase_admin.initialize_app()
        db = firestore.client()
        
        # Fast check if DB is quota-blocked
        try:
            db.collection("health").document("check").get(timeout=2)
            DB_AVAILABLE = True
            logger.info("Firebase Initialized and Reachable")
        except Exception as qe:
            logger.warning(f"Firebase quota reached or unreachable: {qe}")
            DB_AVAILABLE = False
            
    except Exception as e:
        logger.error(f"Firebase Init Failed: {e}")
        DB_AVAILABLE = False

    # Init Gemini
    logger.info(f"Initializing Gemini with Key: {GEMINI_API_KEY[:5]}... if present")
    if GEMINI_API_KEY:
        try:
            genai.configure(api_key=GEMINI_API_KEY)
            # Upgrade to 2.5-flash for massive 1000 RPM capacity
            model = genai.GenerativeModel('gemini-2.5-flash')
            logger.info("Gemini Initialized Successfully (2.5-Flash Model)")
        except Exception as e:
             logger.error(f"Gemini Init Failed: {e}")
    else:
        logger.warning("GOOGLE_API_KEY not set.")

    # Start PDF loading in background - Run in a separate thread to avoid blocking the main loop
    import threading
    threading.Thread(target=lambda: asyncio.run(load_pdf_background()), daemon=True).start()

# B. Adaptive Logic
def get_system_prompt(uid: str) -> str:
    """
    Fetches user's learning mode and returns appropriate system prompt.
    """
    mode = LearningMode.STANDARD
    
    # If we are in demo mode or firebase is acting up, bypass completely
    if uid != "demo_user" and db:
        try:
            # Note: Removal of timeout=5 as it may not be supported in all SDK versions
            user_ref = db.collection("users").document(uid)
            doc = user_ref.get() 
            if doc.exists:
                mode = doc.to_dict().get("learning_mode", LearningMode.STANDARD)
        except Exception as e:
            logger.warning(f"Firebase fetch failed (quota?): {e}")
    
    if mode == LearningMode.REMEDIAL:
        return (
            "You are a friendly senior student ('Abang'). The user is confused. "
            "Explain using simple English. Use analogies involving Football, Food, or Traffic."
        )
    else:
        return (
            "You are EasLearn. Explain concepts formally and strictly based on the syllabus. "
            "Be encouraging but academic. "
            "DEFAULT LANGUAGE: ENGLISH. Only use Malay if the user asks in Malay."
        )


def get_relevant_context(query: str, textbook_id: str, chapter_name: Optional[str] = None) -> str:
    """
    Enhanced RAG with Multi-Textbook support.
    """
    if textbook_id not in TEXTBOOKS:
        logger.warning(f"Textbook ID {textbook_id} not loaded.")
        return ""

    content_dict = TEXTBOOKS[textbook_id]
    ch_map = CHAPTER_MAPS.get(textbook_id, {})
    
    raw_keywords = query.split()
    keywords = []
    for k in raw_keywords:
        k = k.lower()
        if len(k) > 3 or any(char.isdigit() for char in k):
            keywords.append(k)
        
        subparts = re.split(r'(\d+\.\d+)', k)
        for part in subparts:
            if part and part != k:
                 if len(part) > 3 or any(char.isdigit() for char in part):
                      keywords.append(part)
    
    hits = []
    
    target_page = 0
    if chapter_name:
        short_name_match = re.search(r'(?i)Bab\s+(\d+)', chapter_name)
        if short_name_match:
            short_name = f"Bab {short_name_match.group(1)}"
            target_page = ch_map.get(short_name, 0)
    
    for page_num, text in content_dict.items():
        score = 0
        text_lower = text.lower()
        
        for k in keywords:
            if k in text_lower:
                score += 5
                if re.search(rf'\b{re.escape(k)}\b', text_lower):
                    score += 10
            
            if "." in k and all(c.isdigit() or c == "." for c in k):
                parts = k.split(".")
                fuzzy_re = r'\s*'.join(parts[0]) + r'\s*\.\s*' + r'\s*'.join(parts[1])
                if re.search(fuzzy_re, text_lower):
                    score += 15

        if target_page > 0 and target_page <= page_num < target_page + 30:
             score += 5
             
        if chapter_name and chapter_name.lower() in text_lower:
             score += 15
             
        if score > 0:
            hits.append((score, page_num, text))
    
    hits.sort(key=lambda x: x[0], reverse=True)
    
    if not hits and target_page > 0:
        for p in range(target_page, target_page + 3):
            if p in content_dict:
                hits.append((1, p, content_dict[p]))

    top_hits = hits[:3]
    logger.info(f"RAG Found {len(hits)} hits. Top pages: {[h[1] for h in top_hits]}")
    return "\n---\n".join([f"Page {h[1]}: {h[2]}" for h in top_hits])

def bucket_page(page, start):
    # Assume chapter length ~20 pages
    return start <= page < start + 20

@app.get("/")
def home():
    return {
        "status": "EasLearn Backend Running", 
        "pdf_status": PDF_LOADING_STATUS,
        "textbooks_loaded": list(TEXTBOOKS.keys())
    }

@app.get("/debug/rag")
def debug_rag(query: str, textbook_id: str, chapter: Optional[str] = None):
    context = get_relevant_context(query, textbook_id, chapter)
    return {
        "query": query,
        "textbook_id": textbook_id,
        "chapter": chapter,
        "context_preview": context[:1000] + "..." if context else "EMPTY",
        "extracted_keywords": [k.lower() for k in query.split() if len(k) > 3 or any(char.isdigit() for char in k)],
        "target_page": CHAPTER_MAPS.get(textbook_id, {}).get(chapter, "Not Found") if chapter else "N/A"
    }

@app.post("/auth/login")
def auth_login(request: LoginRequest):
    if request.uid == "demo_user":
        return {"status": "success", "message": "Demo mode active"}

    if not db:
        raise HTTPException(status_code=503, detail="Database unavailable")
    
    try:
        user_ref = db.collection("users").document(request.uid)
        doc = user_ref.get()
        
        if not doc.exists:
            data = {
                "uid": request.uid,
                "email": request.email,
                "name": request.name,
                "learning_mode": LearningMode.STANDARD,
                "quiz_history": []
            }
            user_ref.set(data)
            return {"status": "success", "message": "User created"}
        else:
            return {"status": "success", "message": "User exists"}
    except Exception as e:
        logger.error(f"Login failed (quota?): {e}")
        return {"status": "success", "message": "Proceeding offline (DB restricted)"}

# ... (rest of endpoints)

@app.get("/textbooks")
def get_all_textbooks():
    """Returns hierarchy of Level -> Subject -> TextbookID."""
    hierarchy = {}
    
    # Use live metadata if available, otherwise fallback to shadow metadata
    source_meta = TEXTBOOK_METADATA
    
    for tid, meta in source_meta.items():
        level = meta["level"]
        subject = meta["subject"]
        if level not in hierarchy:
            hierarchy[level] = {}
        if subject not in hierarchy[level]:
            hierarchy[level][subject] = tid
    return hierarchy

@app.get("/chapters")
def get_chapters(textbook_id: str, request: Request):
    if not db:
        raise HTTPException(status_code=503, detail="Database unavailable")
    
    if textbook_id not in TEXTBOOK_METADATA:
        raise HTTPException(status_code=404, detail="Textbook not found")

    base_url = str(request.base_url).rstrip("/")
    if "rend" in base_url or "https" not in base_url and "localhost" not in base_url:
         base_url = base_url.replace("http://", "https://")
         
    pdf_link = f"{base_url}/static/{textbook_id}.pdf"
    
    return {
        "chapters": CHAPTER_MAPS.get(textbook_id, {}),
        "pdf_drive_link": pdf_link,
        "title": TEXTBOOK_METADATA[textbook_id]["title"]
    }

@app.post("/chat")
def chat(request: ChatRequest):
    logger.info(f"Chat request received for {request.textbook_id} from {request.uid}")
    if not model:
        raise HTTPException(status_code=503, detail="AI Model unavailable")
    
    system_prompt = get_system_prompt(request.uid)
    logger.info("System prompt generated")
    
    # RAG with specific textbook
    try:
        context_text = get_relevant_context(request.message, request.textbook_id, request.current_chapter_name)
    except Exception as e:
        logger.warning(f"RAG Context fetch failed: {e}")
        context_text = "[SYSTEM: DATABASE CURRENTLY UNAVAILABLE (Quota Exceeded). Responding with General Knowledge.]"
    
    logger.info("Context retrieved")
    if PDF_LOADING_STATUS == "loading" and not context_text:
        context_text = "[SYSTEM: SYNC IN PROGRESS. Please wait a minute.]"
    elif not context_text:
        context_text = "[SYSTEM: NO CONTEXT FOUND relevant to your question in this textbook.]"

    history_text = ""
    for msg in request.history:
        role_label = "USER" if msg.role == "user" else "EasLearn"
        history_text += f"{role_label}: {msg.content}\n"

    meta = TEXTBOOK_METADATA.get(request.textbook_id, {})
    subject = meta.get("subject", "General")

    full_prompt = f"""
    SYSTEM: {system_prompt}
    SUBJECT: {subject}
    
    CURRENT CHAPTER: {request.current_chapter_name}
    IMPORTANT: You are an expert tutor for {subject}. 
    1. EXPLAIN ONLY what is in the provided context for this textbook.
    2. IF the user asks about the chapter title, USE THE EXACT TITLE provided above ({request.current_chapter_name}).
    3. SUBCONTEXT: If the text provided is insufficient, acknowledge it, but do NOT invent a different chapter title.
    
    CONTEXT FROM TEXTBOOK:
    {context_text}
    
    CHAT HISTORY:
    {history_text}
    
    USER QUESTION: {request.message}
    """
    import time
    for attempt in range(3):
        try:
            logger.info(f"Generating AI content (Attempt {attempt+1})...")
            response = model.generate_content(full_prompt)
            
            # Safe text extraction
            try:
                 ai_text = response.text
            except:
                 ai_text = "I apologize, but I could not generate a response for this query. It might be due to safety filters or a temporary glitch."
                 
            mode = "Remedial" if "Abang" in system_prompt or "Buddy" in system_prompt else "Standard"
            return {"response": ai_text, "mode_used": mode}
            
        except Exception as e:
            err_msg = str(e)
            if "429" in err_msg and attempt < 2:
                logger.warning(f"Gemini 429 Quota reached. Retrying in 2s... (Attempt {attempt+1})")
                time.sleep(2)
                continue
            
            logger.error(f"Chat Error on attempt {attempt+1}: {e}")
            if attempt == 2:
                raise HTTPException(status_code=500, detail=f"AI Engine Error (Final Attempt): {err_msg}")

@app.post("/quiz/generate")
def quiz_generate(request: QuizGenerationRequest):
    if not model:
        raise HTTPException(status_code=503, detail="AI Model unavailable")

    # Fetch context for chapter - Fix: pass common textbook ID if unknown
    # In quiz generation, we usually know the textbook. Let's assume a generic search across loaded ones if not specified.
    # For now, let's just pass any textbook_id that is loaded or a dummy one.
    textbook_id = list(TEXTBOOKS.keys())[0] if TEXTBOOKS else "sejarah_f4"
    context_text = get_relevant_context(request.chapter_name, textbook_id)
    
    prompt = f"""
    SUBJECT: Sejarah Tingkatan 4 (KSSM)
    Generate 3 Multiple Choice Questions (MCQ) based on this text:
    "{context_text[:2000]}..." 
    
    Target Audience: Malaysian Form 4 Students.
    Return ONLY valid JSON array:
    [
        {{"question": "...", "options": ["A", "B", "C", "D"], "answer": "A"}},
        ...
    ]
    Do not add markdown formatting like ```json.
    """
    
    try:
        response = model.generate_content(prompt)
        cleaned_text = response.text.replace("```json", "").replace("```", "").strip()
        import json
        questions = json.loads(cleaned_text)
        return {"questions": questions}
    except Exception as e:
        print(f"Quiz Gen Error: {e}")
        # Fallback
        return {
            "questions": [
                {"question": "Example Question?", "options": ["A", "B", "C", "D"], "answer": "A"}
            ]
        }

@app.post("/quiz/submit")
def quiz_submit(request: QuizSubmissionRequest):
    if request.uid == "demo_user":
        return {"new_mode": LearningMode.STANDARD}

    if not db:
        raise HTTPException(status_code=503, detail="Database unavailable")
    
    try:
        user_ref = db.collection("users").document(request.uid)
        
        # 1. Update History
        new_record = {
            "score": request.score_percent,
            "timestamp": firestore.SERVER_TIMESTAMP
        }
        user_ref.update({
            "quiz_history": firestore.ArrayUnion([new_record])
        })
        
        # 2. Adaptation Rule
        new_mode = None
        if request.score_percent < 50:
            new_mode = LearningMode.REMEDIAL
        elif request.score_percent >= 80:
            new_mode = LearningMode.STANDARD
        
        if new_mode:
            user_ref.update({"learning_mode": new_mode})
            return {"new_mode": new_mode}
        
        # No change
        doc = user_ref.get()
        current_mode = doc.to_dict().get("learning_mode", LearningMode.STANDARD)
        return {"new_mode": current_mode}
    except Exception as e:
        logger.warning(f"Quiz submit failed (quota?): {e}")
        return {"new_mode": LearningMode.STANDARD}

if __name__ == "__main__":
    uvicorn.run("backend.main:app", host="0.0.0.0", port=8000, reload=True)
