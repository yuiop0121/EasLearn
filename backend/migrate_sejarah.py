import firebase_admin
from firebase_admin import credentials, firestore
import os

# Setup
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SERVICE_ACCOUNT_KEY = os.path.join(BASE_DIR, "serviceAccountKey.json")

def migrate_sejarah():
    if not os.path.exists(SERVICE_ACCOUNT_KEY):
        print("Error: serviceAccountKey.json not found!")
        return

    # Init Firebase
    cred = credentials.Certificate(SERVICE_ACCOUNT_KEY)
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)
    db = firestore.client()

    # Legacy Source
    legacy_ref = db.collection("content").document("textbook_v1")
    legacy_doc = legacy_ref.get()

    if not legacy_doc.exists:
        print("Legacy Sejarah textbook not found in 'content/textbook_v1'. Checking if already migrated...")
        if db.collection("textbooks").document("sejarah_f4").get().exists:
            print("Sejarah Tingkatan 4 is already in the 'textbooks' collection.")
        else:
            print("Could not find Sejarah ANYWHERE. Please check your Firestore collections.")
        return

    # Migration Destination
    sejarah_id = "sejarah_f4"
    data = legacy_doc.to_dict()
    
    # Add new metadata required for multi-textbook support
    data["title"] = "Sejarah Tingkatan 4"
    data["level"] = "Form 4"
    data["subject"] = "Sejarah"

    print(f"Migrating {sejarah_id} to 'textbooks' collection...")
    db.collection("textbooks").document(sejarah_id).set(data)
    
    # Also move the sub-collection 'pages'
    print("Migrating pages sub-collection...")
    pages_ref = legacy_ref.collection("pages")
    docs = pages_ref.stream()
    
    batch = db.batch()
    new_pages_ref = db.collection("textbooks").document(sejarah_id).collection("pages")
    count = 0
    for doc in docs:
        batch.set(new_pages_ref.document(doc.id), doc.to_dict())
        count += 1
        if count % 100 == 0:
            batch.commit()
            batch = db.batch()
    
    batch.commit()
    print(f"Success! Migrated {count} pages. Sejarah is now in the 'textbooks' collection.")

if __name__ == "__main__":
    migrate_sejarah()
